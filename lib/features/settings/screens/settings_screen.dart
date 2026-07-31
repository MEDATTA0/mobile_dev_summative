import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/preferences/app_preferences.dart';
import 'package:mobile_dev_summative/core/preferences/preferences_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs =
        ref.watch(preferencesControllerProvider).value ?? const AppPreferences();
    final controller = ref.read(preferencesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {prefs.themeMode},
            onSelectionChanged: (selection) =>
                controller.setThemeMode(selection.first),
          ),
          const SizedBox(height: 28),
          Text('Text size', style: theme.textTheme.titleMedium),
          Slider(
            value: prefs.textScale,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            label: '${(prefs.textScale * 100).round()}%',
            onChanged: controller.setTextScale,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'The quick brown fox jumps over the lazy dog.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
