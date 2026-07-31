import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/projects/domain/repositories/enrollment_repository.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';
import 'package:mobile_dev_summative/features/projects/domain/enrollment_progress.dart';

class EnrollmentRepositoryImpl extends BaseRepository<Enrollment>
    implements EnrollmentRepository {
  EnrollmentRepositoryImpl() : super('enrollments', Enrollment.fromMap);

  @override
  Future<String> enroll(Enrollment enrollment) {
    return create(enrollment);
  }

  @override
  Future<void> unenroll(String id) {
    return delete(id);
  }

  @override
  Future<void> updateProgress(String id, int completedSteps) async {
    final current = await findById(id);
    if (current == null) {
      throw StateError('Enrollment $id not found');
    }
    final status = enrollmentStatusForProgress(completedSteps, current.totalSteps);
    await update(_copyWith(current, completedSteps: completedSteps, status: status));
  }

  @override
  Future<void> updateStatus(String id, EnrollmentStatus status) async {
    final current = await findById(id);
    if (current == null) {
      throw StateError('Enrollment $id not found');
    }
    await update(_copyWith(current, status: status));
  }

  @override
  Future<List<Enrollment>> getAllForUser(String userId) async {
    final all = await findAll();
    return all.where((enrollment) => enrollment.userId == userId).toList();
  }

  @override
  Future<Enrollment?> getById(String id) {
    return findById(id);
  }

  Enrollment _copyWith(
    Enrollment current, {
    int? completedSteps,
    EnrollmentStatus? status,
  }) {
    return Enrollment(
      id: current.id,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      projectId: current.projectId,
      projectTitle: current.projectTitle,
      userId: current.userId,
      status: status ?? current.status,
      completedSteps: completedSteps ?? current.completedSteps,
      totalSteps: current.totalSteps,
      enrolledAt: current.enrolledAt,
    );
  }
}