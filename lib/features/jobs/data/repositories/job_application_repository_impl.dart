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
      company: current.company,
      position: current.position,
      location: current.location,
      status: status,
      appliedDate: current.appliedDate,
      jobUrl: current.jobUrl,
      notes: current.notes,
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
}
