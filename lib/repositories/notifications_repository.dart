import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler for FCM.
///
/// Must be a top-level function (not a class method) for Firebase to invoke.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message if needed
  debugPrint('Handling background message: ${message.messageId}');
}

/// Repository for managing Firebase Cloud Messaging notifications.
///
/// Handles FCM initialization, permission requests, token management,
/// and foreground notification display via flutter_local_notifications.
class NotificationsRepository {
  /// Creates a [NotificationsRepository] with optional dependencies for testing.
  NotificationsRepository({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;

  /// Android notification channel for chat messages.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages',
    'Chat Messages',
    description: 'Notifications for new chat messages',
    importance: Importance.high,
  );

  /// Initializes the notification system.
  ///
  /// Sets up local notifications, creates Android channel, and configures
  /// foreground presentation options for iOS.
  Future<void> initialize() async {
    // Initialize local notifications for foreground display
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // Configure foreground presentation for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    _foregroundMessageSub = FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  /// Requests notification permissions from the user.
  ///
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Gets the current FCM token.
  ///
  /// Returns null if token unavailable (e.g., web without VAPID key).
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Stores the FCM token in Firestore for the given user.
  ///
  /// Tokens are stored in a subcollection to support multiple devices.
  Future<void> saveToken(String userId, String token) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fcmTokens')
        .doc(token)
        .set({
      'token': token,
      'platform': _getPlatform(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes an FCM token from Firestore.
  ///
  /// Call this when signing out or when notifications are disabled.
  Future<void> deleteToken(String userId, String token) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fcmTokens')
        .doc(token)
        .delete();
  }

  /// Deletes all FCM tokens for a user.
  ///
  /// Call this on sign out to prevent notifications to signed-out devices.
  Future<void> deleteAllTokens(String userId) async {
    final tokensRef =
        _firestore.collection('users').doc(userId).collection('fcmTokens');
    final snapshot = await tokensRef.get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Subscribes to token refresh events and updates Firestore.
  ///
  /// Returns a stream subscription that should be cancelled on dispose.
  void listenToTokenRefresh(String userId) {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      await saveToken(userId, newToken);
    });
  }

  /// Stream of notification taps for navigation handling.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Gets the initial message if app was opened from a notification.
  ///
  /// Use this for cold start navigation to the correct chat room.
  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();

  /// Saves a notification to the user's notification history in Firestore.
  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams notification history for a user.
  Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Marks a notification as read.
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Marks all notifications as read for a user.
  Future<void> markAllAsRead(String userId) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
    final unread = await ref.where('isRead', isEqualTo: false).get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Cleans up resources.
  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundMessageSub?.cancel();
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['roomId'],
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Payload contains roomId for navigation
    final roomId = response.payload;
    if (roomId != null && roomId.isNotEmpty) {
      // Navigation will be handled by the bloc/app layer
      debugPrint('Notification tapped for room: $roomId');
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
