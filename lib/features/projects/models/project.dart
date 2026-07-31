import 'package:mobile_dev_summative/core/models/base_model.dart';
import 'package:mobile_dev_summative/features/projects/models/project_level.dart';

class Project extends BaseModel {
  final String title;
  final String subtitle;
  final String description;
  final ProjectLevel level;
  final List<String> objectives;
  final List<ProjectStep> steps;

  Project({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.level,
    required this.objectives,
    required this.steps,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      title: map["title"],
      subtitle: map["subtitle"],
      description: map["description"],
      level: ProjectLevel.values.byName(map["level"]),
      objectives: List<String>.from(map["objectives"] ?? []),
      steps: (map["steps"] as List<dynamic>? ?? [])
          .map((step) => ProjectStep.fromMap(step as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "title": title,
      "subtitle": subtitle,
      "description": description,
      "level": level.name,
      "objectives": objectives,
      "steps": steps.map((step) => step.toMap()).toList(),
    };
  }
}

class ProjectStep {
  final String title;
  final String detail;

  ProjectStep({required this.title, required this.detail});

  factory ProjectStep.fromMap(Map<String, dynamic> map) {
    return ProjectStep(title: map["title"], detail: map["detail"]);
  }

  Map<String, dynamic> toMap() {
    return {"title": title, "detail": detail};
  }
}