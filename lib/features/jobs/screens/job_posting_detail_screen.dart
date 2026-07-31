import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/screens/job_applicants_screen.dart';
import 'package:mobile_dev_summative/features/jobs/screens/job_application_form_screen.dart';
import 'package:mobile_dev_summative/features/jobs/screens/widgets/job_posting_widgets.dart';

class JobPostingDetailScreen extends ConsumerWidget {
  const JobPostingDetailScreen({super.key, required this.posting});

  final JobPosting posting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentUserId = ref.watch(authRepositoryProvider).currentUser?.uid;
    final isOwner = currentUserId != null && currentUserId == posting.userId;

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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => isOwner
                        ? JobApplicantsScreen(posting: posting)
                        : JobApplicationFormScreen(posting: posting),
                  ),
                );
              },
              child: Text(isOwner ? 'View applicants' : 'Apply'),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
