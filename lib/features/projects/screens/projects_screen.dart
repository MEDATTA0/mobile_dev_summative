import 'package:flutter/material.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';
import 'package:mobile_dev_summative/features/projects/screens/project_detail_screen.dart';
import 'package:mobile_dev_summative/features/projects/screens/widgets/project_widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectLevel? _selectedLevel; // null == All

  static const _sampleProjects = <_SampleProject>[
    _SampleProject(
      title: 'Build your first Doctype',
      subtitle: 'Frappe Framework basics',
      level: ProjectLevel.beginner,
      status: 'In progress',
    ),
    _SampleProject(
      title: 'ERPNext Sales Module',
      subtitle: 'Quotations, sales orders, invoices',
      level: ProjectLevel.beginner,
      status: 'Not started',
    ),
    _SampleProject(
      title: 'Custom Client Scripts',
      subtitle: 'Automate forms with client-side logic',
      level: ProjectLevel.intermediate,
      status: 'Not started',
    ),
    _SampleProject(
      title: 'Workflow Automation',
      subtitle: 'Approval flows and server scripts',
      level: ProjectLevel.intermediate,
      status: 'Locked',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filtered = _selectedLevel == null
        ? _sampleProjects
        : _sampleProjects
              .where((project) => project.level == _selectedLevel)
              .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text('Projects', style: textTheme.headlineSmall),
            ),
            _LevelFilterBar(
              selected: _selectedLevel,
              onSelected: (level) => setState(() => _selectedLevel = level),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No projects at this level yet'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _ProjectCard(project: filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelFilterBar extends StatelessWidget {
  const _LevelFilterBar({required this.selected, required this.onSelected});

  final ProjectLevel? selected;
  final ValueChanged<ProjectLevel?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          for (final level in ProjectLevel.values) ...[
            _FilterChip(
              label: projectLevelLabel(level),
              isSelected: selected == level,
              onTap: () => onSelected(level),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final _SampleProject project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLocked = project.status == 'Locked';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isLocked
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProjectDetailScreen(
                    title: project.title,
                    subtitle: project.subtitle,
                    level: project.level,
                  ),
                ),
              );
            },
      child: Opacity(
        opacity: isLocked ? 0.5 : 1,
        child: Container(
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
                children: [
                  const ProjectIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: textTheme.titleMedium),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  ProjectLevelBadge(level: project.level),
                  const Spacer(),
                  _StatusLabel(status: project.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      'In progress' => (Icons.play_circle_outline, Colors.indigo),
      'Locked' => (Icons.lock_outline, Colors.grey),
      _ => (Icons.circle_outlined, Colors.grey),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SampleProject {
  const _SampleProject({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.status,
  });

  final String title;
  final String subtitle;
  final ProjectLevel level;
  final String status;
}