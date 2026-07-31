import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';

abstract class EnrollmentRepository {
  Future<String> enroll(Enrollment enrollment);
  Future<void> unenroll(String id);
  Future<void> updateProgress(String id, int completedSteps);
  Future<void> updateStatus(String id, EnrollmentStatus status);
  Future<List<Enrollment>> getAllForUser(String userId);
  Future<Enrollment?> getById(String id);
  Future<void> submitWork(String id, String submissionUrl); 
}