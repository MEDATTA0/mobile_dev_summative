import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_dev_summative/core/navigation/main_shell.dart';
import 'package:mobile_dev_summative/core/preferences/app_preferences.dart';
import 'package:mobile_dev_summative/core/preferences/preferences_providers.dart';
import 'package:mobile_dev_summative/core/theme/app_theme.dart';
import 'package:mobile_dev_summative/features/onboarding/screens/onboarding_screen.dart';
import 'package:mobile_dev_summative/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(preferencesControllerProvider).value ?? const AppPreferences();

    return MaterialApp(
      title: 'EmpowerHER',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: prefs.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(prefs.textScale)),
          child: child!,
        );
      },
      home: prefs.onboardingSeen ? const MainShell() : const OnboardingScreen(),
    );
  }
}
