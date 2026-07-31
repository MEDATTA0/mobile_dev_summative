import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';

abstract class JobPostingRepository {
  Future<String> create(JobPosting posting);
  Future<List<JobPosting>> getAll();
  Future<JobPosting?> getById(String id);
}
