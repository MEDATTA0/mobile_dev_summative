import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/core/preferences/app_preferences.dart';
import 'package:mobile_dev_summative/core/preferences/preferences_providers.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/profile/profile_providers.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_application_repository.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_posting_repository.dart';
import 'package:mobile_dev_summative/features/jobs/job_postings_providers.dart';
import 'package:mobile_dev_summative/features/jobs/jobs_providers.dart';
import 'package:mobile_dev_summative/features/community/community_providers.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/community_post_repository.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/post_reply_repository.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';
import 'package:mobile_dev_summative/main.dart';

class FakeCommunityPostRepository implements CommunityPostRepository {
  @override
  Stream<List<CommunityPost>> watchAll() => Stream.value(const []);

  @override
  Stream<CommunityPost?> watchById(String id) => Stream.value(null);

  @override
  Future<String> createPost(CommunityPost post) async => 'fake-id';

  @override
  Future<void> updatePost(CommunityPost post) async {}

  @override
  Future<void> deletePost(String id) async {}
}

class FakePostReplyRepository implements PostReplyRepository {
  @override
  Stream<List<PostReply>> watchForPost(String postId) => Stream.value(const []);

  @override
  Future<String> createReply(PostReply reply) async => 'fake-id';

  @override
  Future<void> deleteReply(String id) async {}
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
}

class FakeJobApplicationRepository implements JobApplicationRepository {
  @override
  Future<String> apply(JobApplication job) async => 'fake-id';

  @override
  Future<List<JobApplication>> getAll() async => [];

  @override
  Future<JobApplication?> getById(String id) async => null;

  @override
  Future<void> updateStatus(String id, JobStatus status) async {}

  @override
  Future<void> withdraw(String id) async {}

  @override
  Future<List<JobApplication>> getByJobPostingId(String jobPostingId) async =>
      [];
}

class FakeJobPostingRepository implements JobPostingRepository {
  @override
  Future<String> create(JobPosting posting) async => 'fake-id';

  @override
  Future<List<JobPosting>> getAll() async => [];

  @override
  Future<JobPosting?> getById(String id) async => null;
}

/// Skips onboarding so the test lands directly on the main shell.
class _SeenPrefsController extends PreferencesController {
  @override
  Future<AppPreferences> build() async =>
      const AppPreferences(onboardingSeen: true);
}

void main() {
  testWidgets('shows the empty state when there are no job postings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesControllerProvider.overrideWith(_SeenPrefsController.new),
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(FakeUser()),
          ),
          currentProfileProvider.overrideWith((ref) => Stream.value(null)),
          jobApplicationRepositoryProvider.overrideWithValue(
            FakeJobApplicationRepository(),
          ),
          jobPostingRepositoryProvider.overrideWithValue(
            FakeJobPostingRepository(),
          ),
          communityPostRepositoryProvider.overrideWithValue(
            FakeCommunityPostRepository(),
          ),
          postReplyRepositoryProvider.overrideWithValue(
            FakePostReplyRepository(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();

    expect(find.text('No job postings yet'), findsOneWidget);
  });
}
