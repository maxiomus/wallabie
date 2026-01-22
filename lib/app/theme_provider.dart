import 'package:flutter/material.dart';

/// Provider for app-wide theme mode (light/dark) management.
///
/// Uses [ChangeNotifier] to notify widgets when the theme changes.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;

  /// Creates a [ThemeProvider] with optional initial theme mode.
  ThemeProvider({ThemeMode initialThemeMode = ThemeMode.system})
      : _themeMode = initialThemeMode;

  /// The current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Toggles between light and dark theme modes.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Sets the theme mode to a specific value.
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
