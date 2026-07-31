import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';

// Contract for reading and writing profiles.

abstract class ProfileRepository {
  /// One-shot read; null when no profile exists yet.
  Future<Profile?> getProfile(String uid);

  /// Live stream so the UI updates on change; null when no profile exists.
  Stream<Profile?> watchProfile(String uid);

  /// Creates or fully overwrites the profile document for [profile].uid.
  Future<void> saveProfile(Profile profile);

  /// Applies partial edits to an existing profile.
  Future<void> updateProfile(Profile profile);

  /// Removes the profile document at `users/{uid}`.
  Future<void> deleteProfile(String uid);
}
