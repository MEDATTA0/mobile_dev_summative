import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';

/// Reactive stream of a user's profile so the UI can rebuild live on changes.
class WatchProfile {
  final ProfileRepository _repository;

  const WatchProfile(this._repository);

  Stream<Profile?> call(String uid) => _repository.watchProfile(uid);
}
