import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/user_repository.dart';
import 'package:mobile_dev_summative/features/jobs/jobs_providers.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';
import 'package:mobile_dev_summative/features/jobs/screens/widgets/job_posting_widgets.dart';

class JobApplicantsScreen extends ConsumerWidget {
  const JobApplicantsScreen({super.key, required this.posting});

  final JobPosting posting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(jobApplicantsProvider(posting.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: applicantsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(child: Text('No applicants yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: applications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ApplicantCard(application: applications[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load applicants: $error')),
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  const _ApplicantCard({required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final userAsync = ref.watch(userByIdProvider(application.userId));
    final (name, email) = userAsync.when(
      data: (user) => (user?.name ?? application.userId, user?.email ?? ''),
      loading: () => (application.userId, ''),
      error: (error, stackTrace) => (application.userId, ''),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyAvatar(company: name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusChip(status: application.status),
              const SizedBox(width: 8),
              Text(
                'Applied ${_formatDate(application.appliedDate)}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'CV: '),
                      TextSpan(
                        text: application.cvUrl,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            application.coverLetter,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
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
      ref.invalidate(jobApplicantsProvider(application.jobPostingId));
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      JobStatus.applied => (Colors.blue.shade50, Colors.blue.shade700),
      JobStatus.interviewing => (Colors.amber.shade50, Colors.amber.shade800),
      JobStatus.offered => (Colors.green.shade50, Colors.green.shade700),
      JobStatus.accepted => (Colors.teal.shade50, Colors.teal.shade700),
      JobStatus.rejected => (Colors.red.shade50, Colors.red.shade700),
      JobStatus.withdrawn => (Colors.grey.shade200, Colors.grey.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
