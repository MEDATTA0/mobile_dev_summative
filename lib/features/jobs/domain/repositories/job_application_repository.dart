import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';

abstract class JobApplicationRepository {
  Future<String> apply(JobApplication job);
  Future<void> withdraw(String id);
  Future<void> updateStatus(String id, JobStatus status);
  Future<List<JobApplication>> getAll();
  Future<JobApplication?> getById(String id);
  Future<List<JobApplication>> getByJobPostingId(String jobPostingId);
}
