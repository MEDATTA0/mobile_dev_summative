import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';

void main() {
  test('Project survives a toMap/fromMap round trip', () {
    final now = DateTime(2024, 1, 2, 3, 4, 5);
    final project = Project(
      id: 'p1',
      createdAt: now,
      updatedAt: now,
      title: 'Build your first Doctype',
      subtitle: 'Frappe basics',
      description: 'A description',
      level: ProjectLevel.intermediate,
      objectives: const ['Objective A', 'Objective B'],
      steps: [
        ProjectStep(title: 'Step 1', detail: 'Detail 1'),
        ProjectStep(title: 'Step 2', detail: 'Detail 2'),
      ],
    );

    final restored = Project.fromMap(project.toMap()!);

    expect(restored.id, 'p1');
    expect(restored.title, project.title);
    expect(restored.level, ProjectLevel.intermediate);
    expect(restored.objectives, project.objectives);
    expect(restored.steps.length, 2);
    expect(restored.steps.first.title, 'Step 1');
  });

  test('Enrollment survives a toMap/fromMap round trip', () {
    final now = DateTime(2024, 5, 6, 7, 8, 9);
    final enrollment = Enrollment(
      id: 'e1',
      createdAt: now,
      updatedAt: now,
      projectId: 'p1',
      userId: 'u1',
      status: EnrollmentStatus.submitted,
      completedSteps: 3,
      totalSteps: 4,
      enrolledAt: now,
    );

    final restored = Enrollment.fromMap(enrollment.toMap()!);

    expect(restored.projectId, 'p1');
    expect(restored.userId, 'u1');
    expect(restored.status, EnrollmentStatus.submitted);
    expect(restored.completedSteps, 3);
    expect(restored.totalSteps, 4);
  });
}