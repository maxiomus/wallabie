// firestore_repository/lib/src/user_profile_repository.dart
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/user_profile/models/user_preference.dart';

/// Handles persistence and real-time syncing of user preferences in Firestore.
class ProfileRepository {  
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

  // --- Remote ---
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

  Future<void> savePreference(UserPreference pref) async {
    await _doc(pref.userId).set(pref.toJson(), SetOptions(merge: true));
  }

  // --- Cache ---
  Future<UserPreference?> getCached(String userId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_cacheKey(userId));
    if (raw == null) return null;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserPreference.fromJson(map, userId);
  }

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
  
  Future<bool> exists(String userId) async {
    final snap = await _doc(userId).get();
    return snap.exists;
  }

}
