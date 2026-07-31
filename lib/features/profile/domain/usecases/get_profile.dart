import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';

/// One-shot fetch of a user's profile; null when none exists yet.
class GetProfile {
  final ProfileRepository _repository;

  const GetProfile(this._repository);

  Future<Profile?> call(String uid) => _repository.getProfile(uid);
}
