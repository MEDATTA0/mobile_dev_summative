
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/projects/data/repositories/project_repository_impl.dart';
import 'package:mobile_dev_summative/features/projects/domain/repositories/project_repository.dart';
import 'package:mobile_dev_summative/features/projects/models/project.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl();
});

final projectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).getAll();
});