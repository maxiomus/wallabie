import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/user_profile/models/user_preference.dart';

/// Repository for user preferences with offline-first caching.
///
/// Handles persistence and real-time syncing of user preferences in Firestore.
/// Uses SharedPreferences for local caching to support offline usage.
class ProfileRepository {
  /// Creates a [ProfileRepository] with optional Firestore instance for testing.
  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection('user_preferences').doc(userId);

  /*    
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('user_preferences');
  */

  String _cacheKey(String userId) => 'user_pref:$userId';

  /// Streams user preferences from Firestore in real-time.
  ///
  /// Returns default preferences if no document exists.
  Stream<UserPreference> watchPreference(String userId) {
    return _doc(userId).snapshots().map((snap) {
      if(!snap.exists || snap.data() == null) {

        return UserPreference(
          userId: userId,          
        );        
      }

      return UserPreference.fromJson(snap.data()!, userId);
    });
  }

  /// Saves user preferences to Firestore with merge semantics.
  Future<void> savePreference(UserPreference pref) async {
    await _doc(pref.userId).set(pref.toJson(), SetOptions(merge: true));
  }

  /// Retrieves cached preferences from local storage.
  ///
  /// Returns null if no cached data exists.
  Future<UserPreference?> getCached(String userId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_cacheKey(userId));
    if (raw == null) return null;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserPreference.fromJson(map, userId);
  }

  /// Saves preferences to local cache for offline access.
  Future<void> saveCached(UserPreference pref) async {
    final sp = await SharedPreferences.getInstance();

    // Avoid storing serverTimestamp in cache. Make a cache-safe json:
    final cacheJson = <String, dynamic>{
      'userName' : pref.userName,
      'themeMode': pref.themeMode.name,
      'locale': pref.locale,
      'updatedAt': pref.updatedAt?.toIso8601String(),
    };

    await sp.setString(_cacheKey(pref.userId), jsonEncode(cacheJson));
  }
  
  /// Checks if a preferences document exists for the user.
  Future<bool> exists(String userId) async {
    final snap = await _doc(userId).get();
    return snap.exists;
  }
}
