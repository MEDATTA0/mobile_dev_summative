import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/presentation/screens/profile_screen.dart';
import 'package:mobile_dev_summative/features/profile/profile_providers.dart';

Widget _wrap(Stream<Profile?> profileStream) {
  return ProviderScope(
    overrides: [currentProfileProvider.overrideWith((ref) => profileStream)],
    child: const MaterialApp(home: ProfileScreen()),
  );
}

void main() {
  testWidgets('renders profile details when a profile exists', (tester) async {
    final profile = Profile(
      uid: 'u1',
      name: 'Amina Bello',
      email: 'amina@example.com',
      headline: 'Founder',
      skills: const ['Flutter', 'ERP'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(_wrap(Stream.value(profile)));
    await tester.pumpAndSettle();

    expect(find.text('Amina Bello'), findsOneWidget);
    expect(find.text('Founder'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('shows empty state when there is no profile', (tester) async {
    await tester.pumpWidget(_wrap(Stream.value(null)));
    await tester.pumpAndSettle();

    expect(find.text('No profile yet'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
  });
}
