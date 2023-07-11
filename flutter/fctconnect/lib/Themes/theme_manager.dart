import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeManager() {
    // Load the themeMode when this class is instantiated.
    _loadThemeMode();
  }

  dynamic getThemeMode() {
    return _themeMode;
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedThemeMode = prefs.getString('themeMode');
    switch (storedThemeMode) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void toggleTheme(String theme) async {
    switch (theme) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners(); // Notify listeners about the change.

    // Save the chosen themeMode.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', theme);
  }
}
