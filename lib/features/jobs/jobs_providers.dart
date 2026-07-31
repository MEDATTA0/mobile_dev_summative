import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/jobs/data/repositories/job_application_repository_impl.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_application_repository.dart';

final jobApplicationRepositoryProvider = Provider<JobApplicationRepository>((
  ref,
) {
  return JobApplicationRepositoryImpl();
});

final jobApplicationsProvider = FutureProvider<List<JobApplication>>((ref) {
  return ref.watch(jobApplicationRepositoryProvider).getAll();
});

final jobApplicantsProvider = FutureProvider.family<List<JobApplication>, String>((
  ref,
  jobPostingId,
) {
  return ref
      .watch(jobApplicationRepositoryProvider)
      .getByJobPostingId(jobPostingId);
});
