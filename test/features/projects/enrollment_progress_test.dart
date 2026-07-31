import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/features/projects/domain/enrollment_progress.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';

Enrollment _enrollment({required int completed, required int total}) {
  final now = DateTime(2024);
  return Enrollment(
    id: 'e1',
    createdAt: now,
    updatedAt: now,
    projectId: 'p1',
    userId: 'u1',
    status: EnrollmentStatus.inProgress,
    completedSteps: completed,
    totalSteps: total,
    enrolledAt: now,
  );
}

void main() {
  group('Enrollment.progress', () {
    test('is the fraction of completed steps', () {
      expect(_enrollment(completed: 2, total: 4).progress, 0.5);
    });

    test('is zero when there are no steps (no divide by zero)', () {
      expect(_enrollment(completed: 0, total: 0).progress, 0);
    });

    test('is one when all steps are done', () {
      expect(_enrollment(completed: 3, total: 3).progress, 1);
    });
  });

  group('enrollmentStatusForProgress', () {
    test('is inProgress before the last step', () {
      expect(enrollmentStatusForProgress(1, 4), EnrollmentStatus.inProgress);
    });

    test('is submitted when all steps are complete', () {
      expect(enrollmentStatusForProgress(4, 4), EnrollmentStatus.submitted);
    });

    test('stays inProgress when there are no steps', () {
      expect(enrollmentStatusForProgress(0, 0), EnrollmentStatus.inProgress);
    });
  });
}