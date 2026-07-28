import 'package:flutter/material.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';

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