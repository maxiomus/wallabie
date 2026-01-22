import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the application.
class AppUser {
  /// Creates an [AppUser] with required [id] and [name].
  const AppUser({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  /// Unique user identifier (Firebase Auth UID).
  final String id;

  /// Display name of the user.
  final String name;

  /// Optional profile image URL.
  final String? imageUrl;
}

/// Repository for user data with in-memory caching.
///
/// Maintains a real-time cache of all users via Firestore streaming.
/// Provides both cached lookups and one-off fetches for user data.
class UserRepository {
  /// Creates a [UserRepository] with optional Firestore instance for testing.
  UserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final Map<String, AppUser> _cache = {};
  StreamSubscription? _sub;

  /// Starts listening to the users collection and populates the cache.
  ///
  /// Call this once at app startup to ensure user data is available.
  void start() {
    _sub?.cancel();

    _sub = _db.collection('users').snapshots().listen((snap) {
      for(final d in snap.docs) {
        final data = d.data();
        final name = (data['name'] as String?)?.trim();
        _cache[d.id] = AppUser(
          id: d.id,
          name: (name == null || name.isEmpty) ? 'User ${d.id}' : name,
          imageUrl: data['imageUrl'] as String?
        );
      }
    });
  }

  /// Returns a cached user by [uid], or null if not in cache.
  AppUser? getCached(String uid) => _cache[uid];

  /// Streams all users for user picker screens.
  ///
  /// Returns real-time updates as users are added or modified.
  Stream<List<AppUser>> watchAllUsers() {
    return _db.collection('users').snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        final name = (data['name'] as String?)?.trim();
        return AppUser(
          id: d.id,
          name: (name == null || name.isEmpty) ? 'User ${d.id}' : name,
          imageUrl: data['imageUrl'] as String?,
        );
      }).toList();
    });
  }

  /// One-off fetch (used when cache isn't ready)
  Future<AppUser> getUser(String uid) async {
    final cached = _cache[uid];
    if (cached != null) return cached;

    final snap = await _db.collection('users').doc(uid).get();
    final data = snap.data();
    final name = (data?['name'] as String?)?.trim();

    final user = AppUser(
      id: uid,
      name: (name == null || name.isEmpty) ? 'User $uid' : name,
      imageUrl: data?['imageUrl'] as String?,
    );

    _cache[uid] = user;
    return user;
  }
  
  /// Cancels the Firestore subscription and cleans up resources.
  void dispose() {
    _sub?.cancel();
  }
}