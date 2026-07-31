import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/projects/enrollments_providers.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';
import 'package:mobile_dev_summative/features/projects/projects_providers.dart';
import 'package:mobile_dev_summative/features/projects/screens/project_detail_screen.dart';
import 'package:mobile_dev_summative/features/projects/screens/widgets/project_widgets.dart';

EnrollmentStatus? _statusFor(Project project, List<Enrollment> enrollments) {
  for (final enrollment in enrollments) {
    if (enrollment.projectId == project.id) return enrollment.status;
  }
  return null;
}

// A project is locked until the previous project in its level has been
// started, so each level unlocks sequentially while Beginner stays open.
Set<String> _lockedProjectIds(
  List<Project> projects,
  List<Enrollment> enrollments,
) {
  final byLevel = <ProjectLevel, List<Project>>{};
  for (final project in projects) {
    byLevel.putIfAbsent(project.level, () => []).add(project);
  }

  final locked = <String>{};
  for (final levelProjects in byLevel.values) {
    for (var i = 1; i < levelProjects.length; i++) {
      final previous = levelProjects[i - 1];
      final previousStarted = enrollments.any(
        (e) => e.projectId == previous.id,
      );
      if (!previousStarted) locked.add(levelProjects[i].id);
    }
  }
  return locked;
}

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  ProjectLevel? _selectedLevel; // null == All

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final projectsAsync = ref.watch(projectsProvider);
    final enrollments = ref.watch(enrollmentsProvider).maybeWhen(
      data: (e) => e,
      orElse: () => const <Enrollment>[],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Projects',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _LevelFilterBar(
              selected: _selectedLevel,
              onSelected: (level) => setState(() => _selectedLevel = level),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return _RetryView(
                      message: 'No projects yet',
                      onRetry: () => ref.invalidate(projectsProvider),
                    );
                  }

                  final lockedIds = _lockedProjectIds(projects, enrollments);

                  final filtered = _selectedLevel == null
                      ? projects
                      : projects
                            .where((project) => project.level == _selectedLevel)
                            .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No projects at this level yet'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(projectsProvider.future),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final project = filtered[index];
                        return _ProjectCard(
                          project: project,
                          status: _statusFor(project, enrollments),
                          locked: lockedIds.contains(project.id),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _RetryView(
                  message: 'Failed to load projects',
                  detail: '$error',
                  onRetry: () => ref.invalidate(projectsProvider),
                ),
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
    final primary = Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.status,
    required this.locked,
  });

  final Project project;
  final EnrollmentStatus? status;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: locked
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProjectDetailScreen(project: project),
                ),
              );
            },
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
            ProjectLevelBadge(level: project.level),
            const SizedBox(height: 10),
            Text(
              project.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ProjectStatusLine(status: status, locked: locked),
          ],
        ),
      ),
    );
  }
}

class _RetryView extends StatelessWidget {
  const _RetryView({required this.message, this.detail, required this.onRetry});

  final String message;
  final String? detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                detail!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}