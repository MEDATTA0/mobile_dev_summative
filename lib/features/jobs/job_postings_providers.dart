import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/jobs/data/repositories/job_posting_repository_impl.dart';
import 'package:mobile_dev_summative/features/jobs/domain/entities/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_posting_repository.dart';

final jobPostingRepositoryProvider = Provider<JobPostingRepository>((ref) {
  return JobPostingRepositoryImpl();
});

final jobPostingsProvider = FutureProvider<List<JobPosting>>((ref) {
  return ref.watch(jobPostingRepositoryProvider).getAll();
});
