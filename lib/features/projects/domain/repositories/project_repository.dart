import 'package:mobile_dev_summative/features/projects/models/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAll();
  Future<Project?> getById(String id);
}