import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/preferences/app_preferences.dart';
import 'package:mobile_dev_summative/core/preferences/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads preferences on start and persists every change immediately.
class PreferencesController extends AsyncNotifier<AppPreferences> {
  PreferencesService? _service;

  @override
  Future<AppPreferences> build() async {
    final prefs = await SharedPreferences.getInstance();
    final service = PreferencesService(prefs);
    _service = service;
    return service.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _service?.saveThemeMode(mode);
    _update((prefs) => prefs.copyWith(themeMode: mode));
  }

  Future<void> setTextScale(double scale) async {
    await _service?.saveTextScale(scale);
    _update((prefs) => prefs.copyWith(textScale: scale));
  }

  Future<void> setOnboardingSeen(bool seen) async {
    await _service?.saveOnboardingSeen(seen);
    _update((prefs) => prefs.copyWith(onboardingSeen: seen));
  }

  void _update(AppPreferences Function(AppPreferences) change) {
    final current = state.value ?? const AppPreferences();
    state = AsyncData(change(current));
  }
}

final preferencesControllerProvider =
    AsyncNotifierProvider<PreferencesController, AppPreferences>(
  PreferencesController.new,
);
