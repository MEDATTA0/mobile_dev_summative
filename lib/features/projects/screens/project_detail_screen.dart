import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/projects/domain/usecases/enroll_in_project.dart';
import 'package:mobile_dev_summative/features/projects/enrollments_providers.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';
import 'package:mobile_dev_summative/features/projects/screens/project_sandbox_screen.dart';
import 'package:mobile_dev_summative/features/projects/screens/widgets/project_widgets.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  Enrollment? _enrollmentFor(List<Enrollment> enrollments) {
    final matches = enrollments.where((e) => e.projectId == project.id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final enrollmentsAsync = ref.watch(enrollmentsProvider);
    final enrollment = enrollmentsAsync.maybeWhen(
      data: _enrollmentFor,
      orElse: () => null,
    );

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
              Row(
                children: [
                  ProjectLevelBadge(level: project.level),
                  if (enrollment != null) ...[
                    const SizedBox(width: 8),
                    EnrollmentStatusBadge(status: enrollment.status),
                  ],
                ],
              ),
              if (enrollment != null) ...[
                const SizedBox(height: 16),
                ProjectProgressBar(value: enrollment.progress),
                if (enrollment.submissionUrl != null &&
                    enrollment.submissionUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: Colors.indigo),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Submitted: ${enrollment.submissionUrl}',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
              if (enrollment != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _unenroll(context, ref, enrollment),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Unenroll from project'),
                ),
              ],
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
              onPressed: enrollment == null
                  ? () => _enroll(context, ref)
                  : () => _openSandbox(context, enrollment.id),
              child: Text(enrollment == null ? 'Enroll and start' : 'Continue'),
            ),
          ),
        ),
      ),
    );
  }

  void _openSandbox(BuildContext context, String enrollmentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectSandboxScreen(
          project: project,
          enrollmentId: enrollmentId,
        ),
      ),
    );
  }

  Future<void> _enroll(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final enrollmentId = await EnrollInProject(
        ref.read(enrollmentRepositoryProvider),
      ).call(project: project, userId: kCurrentUserId);
      ref.invalidate(enrollmentsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Enrolled in ${project.title}')),
      );
      _openSandbox(context, enrollmentId);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Failed to enroll: $e')));
    }
  }

  Future<void> _unenroll(
    BuildContext context,
    WidgetRef ref,
    Enrollment enrollment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unenroll from project?'),
        content: Text(
          'This removes your progress on ${project.title}. You can enroll '
          'again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Unenroll'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(enrollmentRepositoryProvider).unenroll(enrollment.id);
      ref.invalidate(enrollmentsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Unenrolled from project')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to unenroll: $e')),
      );
    }
  }
}