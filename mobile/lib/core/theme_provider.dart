import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme mode notifier — allows switching between Dark and Light mode.
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> initThemeMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    if (saved == 'dark') {
      appThemeMode.value = ThemeMode.dark;
    } else if (saved == 'light') {
      appThemeMode.value = ThemeMode.light;
    }
  } catch (_) {}
}

void toggleThemeMode() async {
  if (appThemeMode.value == ThemeMode.dark) {
    appThemeMode.value = ThemeMode.light;
  } else {
    appThemeMode.value = ThemeMode.dark;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      appThemeMode.value == ThemeMode.dark ? 'dark' : 'light',
    );
  } catch (_) {}
}
