import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/jobs/domain/entities/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/domain/entities/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/domain/entities/job_status.dart';
import 'package:mobile_dev_summative/features/jobs/jobs_providers.dart';
import 'package:mobile_dev_summative/features/jobs/screens/widgets/job_posting_widgets.dart';

class JobPostingDetailScreen extends ConsumerWidget {
  const JobPostingDetailScreen({super.key, required this.posting});

  final JobPosting posting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(posting.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CompanyAvatar(company: posting.company),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(posting.title, style: textTheme.titleLarge),
                        Text(
                          posting.company,
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
              EmploymentTypeChip(type: posting.employmentType),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(posting.location, style: textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Posted on ${_formatDate(posting.postedAt)}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const Divider(height: 32),
              Text('Description', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(posting.description, style: textTheme.bodyMedium),
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
              onPressed: () => _apply(context, ref),
              child: const Text('Apply'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _apply(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final now = DateTime.now();
      final application = JobApplication(
        id: '',
        createdAt: now,
        updatedAt: now,
        company: posting.company,
        position: posting.title,
        location: posting.location,
        status: JobStatus.applied,
        appliedDate: now,
      );
      await ref.read(jobApplicationRepositoryProvider).apply(application);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Applied to ${posting.title} at ${posting.company}'),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to apply: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
