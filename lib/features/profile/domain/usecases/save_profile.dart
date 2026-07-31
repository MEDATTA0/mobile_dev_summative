import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';

/// Creates or overwrites a profile; throws [ArgumentError] on invalid input.
class SaveProfile {
  final ProfileRepository _repository;

  const SaveProfile(this._repository);

  Future<void> call(Profile profile) {
    if (profile.uid.trim().isEmpty) {
      throw ArgumentError('Profile uid must not be empty.');
    }
    if (profile.name.trim().isEmpty) {
      throw ArgumentError('Profile name must not be empty.');
    }
    if (profile.email.trim().isEmpty) {
      throw ArgumentError('Profile email must not be empty.');
    }
    return _repository.saveProfile(profile);
  }
}
