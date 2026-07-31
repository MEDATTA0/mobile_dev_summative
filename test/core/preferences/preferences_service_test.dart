import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/core/preferences/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('load returns defaults when nothing is stored', () async {
    final service = PreferencesService(await SharedPreferences.getInstance());
    final prefs = service.load();

    expect(prefs.themeMode, ThemeMode.system);
    expect(prefs.textScale, 1.0);
    expect(prefs.onboardingSeen, false);
  });

  test('saved values survive a reload', () async {
    final service = PreferencesService(await SharedPreferences.getInstance());
    await service.saveThemeMode(ThemeMode.dark);
    await service.saveTextScale(1.2);
    await service.saveOnboardingSeen(true);

    final reloaded = service.load();

    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.textScale, 1.2);
    expect(reloaded.onboardingSeen, true);
  });
}
