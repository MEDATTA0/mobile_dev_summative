import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';

/// Edits an existing profile, stamping a fresh [Profile.updatedAt].
class UpdateProfile {
  final ProfileRepository _repository;

  const UpdateProfile(this._repository);

  Future<void> call(Profile profile, {DateTime? now}) {
    if (profile.uid.trim().isEmpty) {
      throw ArgumentError('Profile uid must not be empty.');
    }
    final stamped = profile.copyWith(updatedAt: now ?? DateTime.now());
    return _repository.updateProfile(stamped);
  }
}