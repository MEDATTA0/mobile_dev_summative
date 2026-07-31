import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/core/theme/app_colors.dart';
import 'package:mobile_dev_summative/core/theme/app_theme.dart';
import 'package:mobile_dev_summative/features/home/screens/home_screen.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/profile_providers.dart';

void main() {
  testWidgets('home renders the dashboard sections under the brand theme', (
    tester,
  ) async {
    final profile = Profile(
      uid: 'u1',
      name: 'Amina Bello',
      email: 'amina@example.com',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith((ref) => Stream.value(profile)),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hi, Amina 👋'), findsOneWidget);
    expect(find.text('Your progress'), findsOneWidget);
    expect(find.text('Current project'), findsOneWidget);
    expect(find.text('Recommended for you'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });

  test('theme applies the brand green as its primary color', () {
    expect(AppColors.primary, const Color(0xFF177A56));
    expect(AppTheme.light.colorScheme.primary, AppColors.primary);
    expect(AppTheme.dark.colorScheme.primary, AppColors.primary);
  });
}
