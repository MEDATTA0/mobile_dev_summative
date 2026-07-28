import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/models/user_model.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/core/repositories/base_repository.dart';

class UserRepository extends BaseRepository<UserModel> {
  UserRepository() : super("users", UserModel.fromMap);

  Future<UserModel?> findByEmail(String email) async {
    final snapshot = await super.collectionRef
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return snapshot.docs.first.data();
  }

  Future<void> createWithId(String id, UserModel entity) {
    return collectionRef.doc(id).set(entity);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final currentUserModelProvider = FutureProvider<UserModel?>((ref) async {
  final authState = await ref.watch(authStateChangesProvider.future);
  final uid = authState?.uid;
  if (uid == null) return null;
  return ref.watch(userRepositoryProvider).findById(uid);
});
