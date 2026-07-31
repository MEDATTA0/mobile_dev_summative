import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_application_repository.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';

class JobApplicationRepositoryImpl extends BaseRepository<JobApplication>
    implements JobApplicationRepository {
  JobApplicationRepositoryImpl() : super('jobs', JobApplication.fromMap);

  @override
  Future<String> apply(JobApplication job) {
    return create(job);
  }

  @override
  Future<void> withdraw(String id) {
    return delete(id);
  }

  @override
  Future<void> updateStatus(String id, JobStatus status) async {
    final current = await findById(id);
    if (current == null) {
      throw StateError('Job application $id not found');
    }
    final updated = JobApplication(
      id: current.id,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      userId: current.userId,
      jobPostingId: current.jobPostingId,
      company: current.company,
      position: current.position,
      location: current.location,
      status: status,
      appliedDate: current.appliedDate,
      cvUrl: current.cvUrl,
      coverLetter: current.coverLetter,
    );
    await update(updated);
  }

  @override
  Future<List<JobApplication>> getAll() {
    return findAll();
  }

  @override
  Future<JobApplication?> getById(String id) {
    return findById(id);
  }

  @override
  Future<List<JobApplication>> getByJobPostingId(String jobPostingId) async {
    final snapshot = await collectionRef
        .where('jobPostingId', isEqualTo: jobPostingId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
