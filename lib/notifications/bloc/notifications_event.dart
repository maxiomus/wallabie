part of 'notifications_bloc.dart';

/// Base class for notifications events.
sealed class NotificationsEvent extends Equatable {
  /// Creates a [NotificationsEvent].
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load notifications for a user.
final class NotificationsStarted extends NotificationsEvent {
  /// Creates a [NotificationsStarted] event.
  const NotificationsStarted({required this.userId});

  /// The user ID to load notifications for.
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event when notifications are received from the stream.
final class NotificationsReceived extends NotificationsEvent {
  /// Creates a [NotificationsReceived] event.
  const NotificationsReceived(this.notifications);

  /// The list of notifications received.
  final List<NotificationItem> notifications;

  @override
  List<Object?> get props => [notifications];
}

/// Event to mark a single notification as read.
final class NotificationMarkedAsRead extends NotificationsEvent {
  /// Creates a [NotificationMarkedAsRead] event.
  const NotificationMarkedAsRead({
    required this.userId,
    required this.notificationId,
  });

  /// The user ID who owns the notification.
  final String userId;

  /// The ID of the notification to mark as read.
  final String notificationId;

  @override
  List<Object?> get props => [userId, notificationId];
}

/// Event to mark all notifications as read.
final class AllNotificationsMarkedAsRead extends NotificationsEvent {
  /// Creates an [AllNotificationsMarkedAsRead] event.
  const AllNotificationsMarkedAsRead({required this.userId});

  /// The user ID whose notifications should be marked as read.
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event when a push notification is tapped.
final class NotificationTapped extends NotificationsEvent {
  /// Creates a [NotificationTapped] event.
  const NotificationTapped({this.roomId});

  /// The room ID to navigate to (if present).
  final String? roomId;

  @override
  List<Object?> get props => [roomId];
}
