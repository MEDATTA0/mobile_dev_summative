import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';
import 'package:mobile_dev_summative/features/profile/domain/usecases/delete_profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/usecases/save_profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/usecases/update_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// Live profile of the signed-in user; emits null when signed out or unset.
final currentProfileProvider = StreamProvider.autoDispose<Profile?>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});

/// Drives create/update/delete writes and exposes their loading/error state.
class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Future<bool> save(Profile profile) =>
      _run(() => SaveProfile(_repository)(profile));

  Future<bool> updateProfile(Profile profile) =>
      _run(() => UpdateProfile(_repository)(profile));

  Future<bool> delete(String uid) => _run(() => DeleteProfile(_repository)(uid));

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);
