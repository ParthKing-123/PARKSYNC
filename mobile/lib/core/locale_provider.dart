import 'package:flutter/material.dart';

/// Global locale notifier — allows any screen to change the app language.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
