import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';
import 'package:mobile_dev_summative/features/jobs/jobs_providers.dart';

class JobsListScreen extends ConsumerWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(jobApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Job Applications')),
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(child: Text('No applications yet'));
          }
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              return _JobApplicationTile(application: applications[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load applications: $error')),
      ),
    );
  }
}

class _JobApplicationTile extends ConsumerWidget {
  const _JobApplicationTile({required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text('${application.position} @ ${application.company}'),
      subtitle: Text(
        'Status: ${application.status.name} • Applied ${_formatDate(application.appliedDate)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<JobStatus>(
            tooltip: 'Update status',
            icon: const Icon(Icons.edit_outlined),
            onSelected: (status) => _updateStatus(context, ref, status),
            itemBuilder: (context) => JobStatus.values
                .map(
                  (status) => PopupMenuItem<JobStatus>(
                    value: status,
                    child: Text(status.name),
                  ),
                )
                .toList(),
          ),
          IconButton(
            tooltip: 'Withdraw application',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _withdraw(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    JobStatus status,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(jobApplicationRepositoryProvider)
          .updateStatus(application.id, status);
      ref.invalidate(jobApplicationsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Status updated to ${status.name}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: Text(
          'This will remove your application to ${application.position} at ${application.company}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(jobApplicationRepositoryProvider).withdraw(application.id);
      ref.invalidate(jobApplicationsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Application withdrawn')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to withdraw application: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
