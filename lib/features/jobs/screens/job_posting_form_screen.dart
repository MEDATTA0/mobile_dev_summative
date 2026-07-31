import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/jobs/job_postings_providers.dart';
import 'package:mobile_dev_summative/features/jobs/models/employment_type.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';

class JobPostingFormScreen extends ConsumerStatefulWidget {
  const JobPostingFormScreen({super.key});

  @override
  ConsumerState<JobPostingFormScreen> createState() =>
      _JobPostingFormScreenState();
}

class _JobPostingFormScreenState extends ConsumerState<JobPostingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  EmploymentType _employmentType = EmploymentType.fullTime;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New job posting')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: _required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company'),
                  validator: _required,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EmploymentType>(
                  initialValue: _employmentType,
                  decoration: const InputDecoration(
                    labelText: 'Employment type',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: EmploymentType.fullTime,
                      child: Text('Full-time'),
                    ),
                    DropdownMenuItem(
                      value: EmploymentType.contract,
                      child: Text('Contract'),
                    ),
                    DropdownMenuItem(
                      value: EmploymentType.internship,
                      child: Text('Internship'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _employmentType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: _required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 3,
                  maxLines: 6,
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
                        : const Text('Post job'),
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
    try {
      final now = DateTime.now();
      final userId = ref.read(authRepositoryProvider).currentUser!.uid;
      final posting = JobPosting(
        id: '',
        createdAt: now,
        updatedAt: now,
        userId: userId,
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        employmentType: _employmentType,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        postedAt: now,
      );
      await ref.read(jobPostingRepositoryProvider).create(posting);
      ref.invalidate(jobPostingsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Posted ${posting.title}')),
      );
      navigator.pop();
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Failed to post job: $e')));
      setState(() => _submitting = false);
    }
  }
}
