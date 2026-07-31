import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/features/profile/data/models/profile_model.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';

void main() {
  final profile = Profile(
    uid: 'u1',
    name: 'Amina Bello',
    email: 'amina@example.com',
    headline: 'Founder',
    bio: 'Building things.',
    location: 'Kigali',
    phone: '+250700000000',
    skills: const ['Flutter', 'ERP'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 2, 1),
  );

  test('round-trips entity -> model -> map -> entity', () {
    final map = ProfileModel.fromEntity(profile).toMap()!;
    final restored = ProfileModel.fromMap(map).toEntity();

    expect(restored, profile);
  });

  test('fromMap defaults skills to empty when absent', () {
    final map = {
      'id': 'u1',
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
      'name': 'Amina',
      'email': 'amina@example.com',
    };

    expect(ProfileModel.fromMap(map).skills, isEmpty);
  });
}
