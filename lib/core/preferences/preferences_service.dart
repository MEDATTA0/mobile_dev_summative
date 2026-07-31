import 'package:flutter/material.dart';
import 'package:mobile_dev_summative/core/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes [AppPreferences] to SharedPreferences.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'pref_theme_mode';
  static const _textScaleKey = 'pref_text_scale';
  static const _onboardingKey = 'pref_onboarding_seen';

  AppPreferences load() {
    return AppPreferences(
      themeMode: _readThemeMode(),
      textScale: _prefs.getDouble(_textScaleKey) ?? 1.0,
      onboardingSeen: _prefs.getBool(_onboardingKey) ?? false,
    );
  }

  ThemeMode _readThemeMode() {
    final name = _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  Future<void> saveTextScale(double scale) =>
      _prefs.setDouble(_textScaleKey, scale);

  Future<void> saveOnboardingSeen(bool seen) =>
      _prefs.setBool(_onboardingKey, seen);
}
