import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => true;

  void toggleTheme() {
    // Pure GitHub Dark enforced
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }
}
