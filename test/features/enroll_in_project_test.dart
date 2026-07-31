import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_dev_summative/features/projects/domain/repositories/enrollment_repository.dart';
import 'package:mobile_dev_summative/features/projects/domain/usecases/enroll_in_project.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';

class MockEnrollmentRepository extends Mock implements EnrollmentRepository {}

class FakeEnrollment extends Fake implements Enrollment {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEnrollment());
  });

  test('enrolls with zeroed progress and inProgress status', () async {
    final repo = MockEnrollmentRepository();
    when(() => repo.enroll(any())).thenAnswer((_) async => 'enr-1');

    final now = DateTime(2024);
    final project = Project(
      id: 'proj-1',
      createdAt: now,
      updatedAt: now,
      title: 'Build your first Doctype',
      subtitle: 'Frappe basics',
      description: 'desc',
      level: ProjectLevel.beginner,
      objectives: const ['a', 'b'],
      steps: [
        ProjectStep(title: 's1', detail: 'd1'),
        ProjectStep(title: 's2', detail: 'd2'),
        ProjectStep(title: 's3', detail: 'd3'),
      ],
    );

    final id = await EnrollInProject(repo).call(project: project, userId: 'user-1');

    expect(id, 'enr-1');
    final captured =
        verify(() => repo.enroll(captureAny())).captured.single as Enrollment;
    expect(captured.projectId, 'proj-1');
    expect(captured.userId, 'user-1');
    expect(captured.completedSteps, 0);
    expect(captured.totalSteps, 3);
    expect(captured.status, EnrollmentStatus.inProgress);
  });
}