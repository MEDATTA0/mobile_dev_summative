import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/projects/enrollments_providers.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';

class ProjectSandboxScreen extends ConsumerStatefulWidget {
  const ProjectSandboxScreen({
    super.key,
    required this.project,
    required this.enrollmentId,
  });

  final Project project;
  final String enrollmentId;

  @override
  ConsumerState<ProjectSandboxScreen> createState() =>
      _ProjectSandboxScreenState();
}

class _ProjectSandboxScreenState extends ConsumerState<ProjectSandboxScreen> {
  int _currentStep = 0;
  final _linkController = TextEditingController();

  List<ProjectStep> get _steps => widget.project.steps;

  bool get _isLastStep => _currentStep == _steps.length - 1;

  Future<void> _saveProgress(int completedSteps) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(enrollmentRepositoryProvider)
          .updateProgress(widget.enrollmentId, completedSteps);
      ref.invalidate(enrollmentsProvider);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save progress: $e')),
      );
    }
  }

  void _onContinue() {
    setState(() => _currentStep += 1);
    _saveProgress(_currentStep);
  }

Future<void> _onSubmit() async {
    await _saveProgress(_steps.length);

    if (!mounted) return;
    final link = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit your work'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste a link to your work (a screenshot, your Frappe site, '
                'or a shared doc) so it can be reviewed.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_linkController.text.trim()),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (link == null || link.isEmpty) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(enrollmentRepositoryProvider)
          .submitWork(widget.enrollmentId, link);
      ref.invalidate(enrollmentsProvider);
      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    }
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.workspace_premium,
          color: Colors.green,
          size: 40,
        ),
        title: const Text('Project submitted'),
        content: const Text(
          'Nice work. Once your submission passes review you will earn a '
          'portfolio credential for this project.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.project.title)),
      body: SafeArea(
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: !_currentStepConfirmed ? null: (_isLastStep ? _onSubmit : _onContinue)
          onStepCancel: _currentStep == 0
              ? null
              : () => setState(() => _currentStep -= 1),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: Text(_isLastStep ? 'Submit project' : 'Next'),
                  ),
                  const SizedBox(width: 8),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: [
            for (var i = 0; i < _steps.length; i++)
              Step(
                title: Text(_steps[i].title),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_steps[i].detail),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('I completed this step'),
                      value: _confirmedSteps.contains(i),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _confirmedSteps.add(i);
                          } else {
                            _confirmedSteps.remove(i);
                          }
                        });
                      },
                    ),
                  ],
                ),
                isActive: i <= _currentStep,
              ),
          ],
        ),
      ),
    );
  }
}