// theme_provider.dart
import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  String _locale;

  LocaleProvider({required String locale})
      : _locale = locale;

  Locale get locale => _parseLocale(_locale);

  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
  }

  Locale _parseLocale(String tag) {
    final parts = tag.split(RegExp('[-_]'));
    return parts.length == 1 ? Locale(parts[0]) : Locale(parts[0], parts[1]);
  }
}
