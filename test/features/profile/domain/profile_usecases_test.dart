import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/repositories/profile_repository.dart';
import 'package:mobile_dev_summative/features/profile/domain/usecases/delete_profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/usecases/get_profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/usecases/save_profile.dart';
import 'package:mobile_dev_summative/features/profile/domain/usecases/update_profile.dart';

/// In-memory fake so the domain layer can be tested without Firebase.
class FakeProfileRepository implements ProfileRepository {
  final Map<String, Profile> store = {};
  int saveCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Profile?> getProfile(String uid) async => store[uid];

  @override
  Stream<Profile?> watchProfile(String uid) => Stream.value(store[uid]);

  @override
  Future<void> saveProfile(Profile profile) async {
    saveCalls++;
    store[profile.uid] = profile;
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    updateCalls++;
    store[profile.uid] = profile;
  }

  @override
  Future<void> deleteProfile(String uid) async {
    deleteCalls++;
    store.remove(uid);
  }
}

void main() {
  late FakeProfileRepository repository;

  setUp(() => repository = FakeProfileRepository());

  Profile sample({String uid = 'u1'}) => Profile.initial(
        uid: uid,
        name: 'Amina',
        email: 'amina@example.com',
        now: DateTime(2026, 1, 1),
      );

  group('SaveProfile', () {
    test('persists a valid profile through the repository', () async {
      await SaveProfile(repository)(sample());

      expect(repository.saveCalls, 1);
      expect(repository.store['u1']?.name, 'Amina');
    });

    test('rejects a profile with a blank name', () {
      final invalid = sample().copyWith(name: '   ');

      expect(() => SaveProfile(repository)(invalid), throwsArgumentError);
      expect(repository.saveCalls, 0);
    });
  });

  group('GetProfile', () {
    test('returns null when no profile exists', () async {
      final result = await GetProfile(repository)('missing');
      expect(result, isNull);
    });

    test('returns a stored profile', () async {
      await repository.saveProfile(sample());
      final result = await GetProfile(repository)('u1');
      expect(result?.email, 'amina@example.com');
    });
  });

  group('UpdateProfile', () {
    test('stamps a fresh updatedAt on save', () async {
      final fixedNow = DateTime(2026, 6, 1, 12);

      await UpdateProfile(repository)(
        sample().copyWith(bio: 'Founder'),
        now: fixedNow,
      );

      expect(repository.store['u1']?.updatedAt, fixedNow);
      expect(repository.store['u1']?.bio, 'Founder');
    });
  });

  group('DeleteProfile', () {
    test('removes the stored profile', () async {
      await repository.saveProfile(sample());
      await DeleteProfile(repository)('u1');

      expect(repository.store.containsKey('u1'), isFalse);
      expect(repository.deleteCalls, 1);
    });

    test('rejects a blank uid', () {
      expect(() => DeleteProfile(repository)(''), throwsArgumentError);
    });
  });
}