import 'package:mobile_dev_summative/core/models/base_model.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_status.dart';

class JobApplication extends BaseModel {
  final String company;
  final String position;
  final String? location;
  final JobStatus status;
  final DateTime appliedDate;
  final String? jobUrl;
  final String? notes;

  JobApplication({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.company,
    required this.position,
    this.location,
    required this.status,
    required this.appliedDate,
    this.jobUrl,
    this.notes,
  });

  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      company: map["company"],
      position: map["position"],
      location: map["location"],
      status: JobStatus.values.byName(map["status"]),
      appliedDate: DateTime.parse(map["appliedDate"]),
      jobUrl: map["jobUrl"],
      notes: map["notes"],
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "company": company,
      "position": position,
      "location": location,
      "status": status.name,
      "appliedDate": appliedDate.toIso8601String(),
      "jobUrl": jobUrl,
      "notes": notes,
    };
  }
}
