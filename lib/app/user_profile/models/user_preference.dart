import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents user preferences stored in Firestore.
///
/// Includes theme mode, locale, and other user-specific settings.
class UserPreference extends Equatable {
  /// Unique user identifier.
  final String userId;

  /// User's display name.
  final String userName;

  /// User's preferred theme mode (light, dark, or system).
  final ThemeMode themeMode;

  /// User's preferred locale tag (e.g., 'en', 'ko').
  final String locale;

  /// Timestamp of the last update.
  final DateTime? updatedAt;

  /// Creates a [UserPreference] with required [userId].
  const UserPreference({
    required this.userId,
    this.userName = '',
    this.themeMode = ThemeMode.system,
    this.locale = 'en',
    this.updatedAt,
  });

  /// Converts this preference to a JSON map for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'themeMode': themeMode.name,
      'locale': locale,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a [UserPreference] from a Firestore JSON map.
  factory UserPreference.fromJson(Map<String, dynamic> json, String userId) {
    
    return UserPreference(
      userId: userId,
      userName: json['userName'] as String? ?? '',
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == (json['themeMode'] as String? ?? 'system'),
        orElse: () => ThemeMode.system,
      ),
      locale: json['locale'] as String? ?? 'en',
      updatedAt: _parseUpdatedAt(json['updatedAt']),
    );
  }

  /// Creates a copy of this preference with the given fields replaced.
  UserPreference copyWith({
    String? userName,
    ThemeMode? themeMode,
    String? locale,
    DateTime? updatedAt,
  }) {
    return UserPreference(
      userId: userId,
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,      
      locale: locale ?? this.locale,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [userId, userName, themeMode, locale, updatedAt];
}

/// Parses an updatedAt field from Firestore or cache.
///
/// Handles both [Timestamp] (from Firestore) and [String] (from cache).
DateTime? _parseUpdatedAt(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}