import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/profile/data/models/profile_model.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';

/// Firestore-backed profiles stored at `users/{uid}`.
class ProfileRepositoryImpl extends BaseRepository<ProfileModel>
    implements ProfileRepository {
  ProfileRepositoryImpl() : super('users', ProfileModel.fromMap);

  @override
  Future<Profile?> getProfile(String uid) async {
    final model = await findById(uid);
    return model?.toEntity();
  }

  @override
  Stream<Profile?> watchProfile(String uid) {
    return collectionRef.doc(uid).snapshots().map(
          (snapshot) => snapshot.data()?.toEntity(),
        );
  }

  @override
  Future<void> saveProfile(Profile profile) {
    return collectionRef.doc(profile.uid).set(ProfileModel.fromEntity(profile));
  }

  @override
  Future<void> updateProfile(Profile profile) {
    return collectionRef
        .doc(profile.uid)
        .update(ProfileModel.fromEntity(profile).toMap()!);
  }

  @override
  Future<void> deleteProfile(String uid) => delete(uid);
}
