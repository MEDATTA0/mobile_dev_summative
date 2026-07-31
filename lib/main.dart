import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_dev_summative/core/navigation/main_shell.dart';
import 'package:mobile_dev_summative/core/theme/app_theme.dart';
import 'package:mobile_dev_summative/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tracker',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // TODO(habeeb): drive this from the persisted theme preference (Day 4
      // SharedPrefs task) once it lands; default to light to match Figma.
      themeMode: ThemeMode.light,
      home: const MainShell(),
    );
  }
}
