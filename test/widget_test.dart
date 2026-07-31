import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/core/preferences/app_preferences.dart';
import 'package:mobile_dev_summative/core/preferences/preferences_providers.dart';
import 'package:mobile_dev_summative/features/profile/profile_providers.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_application_repository.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_posting_repository.dart';
import 'package:mobile_dev_summative/features/jobs/job_postings_providers.dart';
import 'package:mobile_dev_summative/features/jobs/jobs_providers.dart';

import 'package:mobile_dev_summative/main.dart';

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
}

class FakeJobPostingRepository implements JobPostingRepository {
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
          currentProfileProvider.overrideWith((ref) => Stream.value(null)),
          jobApplicationRepositoryProvider.overrideWithValue(
            FakeJobApplicationRepository(),
          ),
          jobPostingRepositoryProvider.overrideWithValue(
            FakeJobPostingRepository(),
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
