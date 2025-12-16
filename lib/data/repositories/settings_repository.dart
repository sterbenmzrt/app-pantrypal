import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsRepository {
  static const String _themeKey = 'theme_mode';

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey);
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      return ThemeMode.values[index];
    }
    return ThemeMode.light; // Default
  }
}
