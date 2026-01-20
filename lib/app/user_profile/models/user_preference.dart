import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

//enum AppThemeMode { system, light, dark }

class UserPreference extends Equatable {
  final String userId;
  final String userName;
  final ThemeMode themeMode;
  final String locale;
  final DateTime? updatedAt;

  const UserPreference({
    required this.userId,
    this.userName = '',
    this.themeMode = ThemeMode.system,
    this.locale = 'en',
    this.updatedAt,
  });

  /// Default preference if nothing exists in Firestore.  

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'themeMode': themeMode.name,
      'locale': locale,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

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