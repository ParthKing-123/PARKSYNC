import 'package:flutter/material.dart';

/// Global theme mode notifier — allows switching between Dark and Light mode.
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.dark);

void toggleThemeMode() {
  if (appThemeMode.value == ThemeMode.dark) {
    appThemeMode.value = ThemeMode.light;
  } else {
    appThemeMode.value = ThemeMode.dark;
  }
}
