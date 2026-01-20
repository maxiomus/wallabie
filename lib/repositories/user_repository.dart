import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageUrl;
}

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final Map<String, AppUser> _cache = {};
  StreamSubscription? _sub;


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

  AppUser? getCached(String uid) => _cache[uid];

  // Stream all users for user picker screens
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
  
  void dispose() {
    _sub?.cancel();
  }
}