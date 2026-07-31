import 'package:mobile_dev_summative/features/projects/domain/repositories/enrollment_repository.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';

class EnrollInProject {
  const EnrollInProject(this._repository);

  final EnrollmentRepository _repository;

  Future<String> call({required Project project, required String userId}) {
    final now = DateTime.now();
    final enrollment = Enrollment(
      id: '',
      createdAt: now,
      updatedAt: now,
      projectId: project.id,
      userId: userId,
      status: EnrollmentStatus.inProgress,
      completedSteps: 0,
      totalSteps: project.steps.length,
      enrolledAt: now,
    );
    return _repository.enroll(enrollment);
  }
}