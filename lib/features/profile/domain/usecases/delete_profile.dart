import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';

/// Deletes the profile document at `users/{uid}`.
class DeleteProfile {
  final ProfileRepository _repository;

  const DeleteProfile(this._repository);

  Future<void> call(String uid) {
    if (uid.trim().isEmpty) {
      throw ArgumentError('uid must not be empty.');
    }
    return _repository.deleteProfile(uid);
  }
}
