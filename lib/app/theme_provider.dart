// theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeProvider({ThemeMode initialThemeMode = ThemeMode.system})
      : _themeMode = initialThemeMode;

  ThemeMode get themeMode => _themeMode;  

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
