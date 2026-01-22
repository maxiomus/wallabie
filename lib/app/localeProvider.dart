import 'package:flutter/material.dart';

/// Provider for app-wide locale (language) management.
///
/// Uses [ChangeNotifier] to notify widgets when the locale changes.
/// Supports locale tags like 'en', 'ko', 'en-US', etc.
class LocaleProvider with ChangeNotifier {
  String _locale;

  /// Creates a [LocaleProvider] with the given initial locale tag.
  LocaleProvider({required String locale})
      : _locale = locale;

  /// The current locale as a [Locale] object.
  Locale get locale => _parseLocale(_locale);

  /// Sets the locale to a new language tag.
  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
  }

  /// Parses a locale tag string (e.g., 'en-US') into a [Locale] object.
  Locale _parseLocale(String tag) {
    final parts = tag.split(RegExp('[-_]'));
    return parts.length == 1 ? Locale(parts[0]) : Locale(parts[0], parts[1]);
  }
}
