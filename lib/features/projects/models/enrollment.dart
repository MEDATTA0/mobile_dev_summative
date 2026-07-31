import 'package:mobile_dev_summative/core/models/base_model.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';

class Enrollment extends BaseModel {
  final String projectId;
  final String projectTitle;
  final String userId;
  final EnrollmentStatus status;
  final int completedSteps;
  final int totalSteps;
  final String? submissionUrl;
  final DateTime enrolledAt;

  Enrollment({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.projectId,
    required this.projectTitle,
    required this.userId,
    required this.status,
    required this.completedSteps,
    required this.totalSteps,
    this.submissionUrl,
    required this.enrolledAt,
  });

  double get progress => totalSteps == 0 ? 0 : completedSteps / totalSteps;

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      projectId: map["projectId"],
      projectTitle: map["projectTitle"] ?? "",
      userId: map["userId"],
      status: EnrollmentStatus.values.byName(map["status"]),
      completedSteps: map["completedSteps"] ?? 0,
      totalSteps: map["totalSteps"] ?? 0,
      enrolledAt: DateTime.parse(map["enrolledAt"]),
      submissionUrl: map["submissionUrl"],
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "projectId": projectId,
      "projectTitle": projectTitle,
      "userId": userId,
      "status": status.name,
      "completedSteps": completedSteps,
      "totalSteps": totalSteps,
      "submissionUrl": submissionUrl,
      "enrolledAt": enrolledAt.toIso8601String(),
    };
  }
}