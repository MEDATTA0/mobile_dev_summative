import 'package:flutter/material.dart';

class ProjectSandboxScreen extends StatefulWidget {
  const ProjectSandboxScreen({super.key, required this.title});

  final String title;

  @override
  State<ProjectSandboxScreen> createState() => _ProjectSandboxScreenState();
}

class _ProjectSandboxScreenState extends State<ProjectSandboxScreen> {
  int _currentStep = 0;

  static const _steps = [
    (
      title: 'Create the Doctype',
      detail:
          'In the Frappe desk, open the Doctype list and create a new '
          'Doctype named "Book". Give it a module and a naming series.',
    ),
    (
      title: 'Add fields',
      detail:
          'Add a Data field for the title and a Link field pointing to '
          'the Author doctype. Mark the title as mandatory.',
    ),
    (
      title: 'Configure views',
      detail:
          'Set the title field as the list-view label and reorder the '
          'form so the most important fields appear first.',
    ),
    (
      title: 'Save and verify',
      detail:
          'Create a sample record, save it, and confirm the document '
          'appears in the list view.',
    ),
  ];

  bool get _isLastStep => _currentStep == _steps.length - 1;

  void _onSubmit() {
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
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: _isLastStep
              ? _onSubmit
              : () => setState(() => _currentStep += 1),
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
                content: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_steps[i].detail),
                ),
                isActive: i <= _currentStep,
              ),
          ],
        ),
      ),
    );
  }
}