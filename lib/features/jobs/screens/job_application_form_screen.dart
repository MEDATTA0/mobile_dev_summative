import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/jobs/jobs_providers.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_application.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';
import 'package:mobile_dev_summative/features/jobs/screens/widgets/job_posting_widgets.dart';

class JobApplicationFormScreen extends ConsumerStatefulWidget {
  const JobApplicationFormScreen({super.key, required this.posting});

  final JobPosting posting;

  @override
  ConsumerState<JobApplicationFormScreen> createState() =>
      _JobApplicationFormScreenState();
}

class _JobApplicationFormScreenState
    extends ConsumerState<JobApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cvUrlController = TextEditingController();
  final _coverLetterController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _cvUrlController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final posting = widget.posting;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
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
                          Text(posting.title, style: textTheme.titleMedium),
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
                const SizedBox(height: 12),
                EmploymentTypeChip(type: posting.employmentType),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _cvUrlController,
                  decoration: const InputDecoration(
                    labelText: 'CV / Resume link',
                  ),
                  keyboardType: TextInputType.url,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _coverLetterController,
                  decoration: const InputDecoration(labelText: 'Cover letter'),
                  minLines: 4,
                  maxLines: 10,
                  validator: _required,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit application'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final posting = widget.posting;
    try {
      final now = DateTime.now();
      final userId = ref.read(authRepositoryProvider).currentUser!.uid;
      final application = JobApplication(
        id: '',
        createdAt: now,
        updatedAt: now,
        userId: userId,
        jobPostingId: posting.id,
        company: posting.company,
        position: posting.title,
        location: posting.location,
        status: JobStatus.applied,
        appliedDate: now,
        cvUrl: _cvUrlController.text.trim(),
        coverLetter: _coverLetterController.text.trim(),
      );
      await ref.read(jobApplicationRepositoryProvider).apply(application);
      ref.invalidate(jobApplicationsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Applied to ${posting.title} at ${posting.company}'),
        ),
      );
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Failed to apply: $e')));
      setState(() => _submitting = false);
    }
  }
}
