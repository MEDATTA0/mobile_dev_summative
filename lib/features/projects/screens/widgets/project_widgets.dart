import 'package:flutter/material.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';

class ProjectIcon extends StatelessWidget {
  const ProjectIcon({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.folder_special_outlined,
        color: Colors.indigo.shade700,
        size: size * 0.5,
      ),
    );
  }
}

class ProjectLevelBadge extends StatelessWidget {
  const ProjectLevelBadge({super.key, required this.level});

  final ProjectLevel level;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (level) {
      ProjectLevel.beginner => (Colors.green.shade100, Colors.green.shade800),
      ProjectLevel.intermediate => (
        Colors.orange.shade100,
        Colors.orange.shade800,
      ),
      ProjectLevel.advanced => (
        Colors.deepPurple.shade50,
        Colors.deepPurple.shade700,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        projectLevelLabel(level),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

String projectLevelLabel(ProjectLevel level) => switch (level) {
  ProjectLevel.beginner => 'Beginner',
  ProjectLevel.intermediate => 'Intermediate',
  ProjectLevel.advanced => 'Advanced',
};

class ProjectProgressBar extends StatelessWidget {
  const ProjectProgressBar({super.key, required this.value});

  final double value; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(value * 100).round()}% complete',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class EnrollmentStatusBadge extends StatelessWidget {
  const EnrollmentStatusBadge({super.key, required this.status});

  final EnrollmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (status) {
      EnrollmentStatus.notStarted => (
        Colors.grey.shade200,
        Colors.grey.shade700,
        'Not started',
      ),
      EnrollmentStatus.inProgress => (
        Colors.indigo.shade50,
        Colors.indigo.shade700,
        'In progress',
      ),
      EnrollmentStatus.submitted => (
        Colors.orange.shade100,
        Colors.orange.shade800,
        'Submitted',
      ),
      EnrollmentStatus.completed => (
        Colors.green.shade100,
        Colors.green.shade800,
        'Completed',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}