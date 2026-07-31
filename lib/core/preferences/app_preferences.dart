import 'package:flutter/material.dart';

/// User preferences persisted across launches via SharedPreferences.
class AppPreferences {
  final ThemeMode themeMode;
  final double textScale;
  final bool onboardingSeen;

  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.textScale = 1.0,
    this.onboardingSeen = false,
  });

  AppPreferences copyWith({
    ThemeMode? themeMode,
    double? textScale,
    bool? onboardingSeen,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    );
  }
}
