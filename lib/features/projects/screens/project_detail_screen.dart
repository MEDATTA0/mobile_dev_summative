import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';
import 'package:mobile_dev_summative/features/projects/enrollments_providers.dart';
import 'package:mobile_dev_summative/features/projects/screens/project_sandbox_screen.dart';
import 'package:mobile_dev_summative/features/projects/screens/widgets/project_widgets.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ProjectIcon(size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          project.subtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProjectLevelBadge(level: project.level),
              const SizedBox(height: 16),
              Text(project.description, style: textTheme.bodyMedium),
              const Divider(height: 32),
              Text('What you will build', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              for (final objective in project.objectives)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(objective, style: textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _enroll(context, ref),
              child: const Text('Enroll and start'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _enroll(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final now = DateTime.now();
      final enrollment = Enrollment(
        id: '',
        createdAt: now,
        updatedAt: now,
        projectId: project.id,
        userId: 'demo-user', // TODO: real authenticated uid
        status: EnrollmentStatus.inProgress,
        completedSteps: 0,
        totalSteps: project.steps.length,
        enrolledAt: now,
      );
      final enrollmentId = await ref
          .read(enrollmentRepositoryProvider)
          .enroll(enrollment);
      ref.invalidate(enrollmentsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Enrolled in ${project.title}')),
      );
      navigator.push(
        MaterialPageRoute(
          builder: (context) => ProjectSandboxScreen(
            project: project,
            enrollmentId: enrollmentId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to enroll: $e')),
      );
    }
  }
}