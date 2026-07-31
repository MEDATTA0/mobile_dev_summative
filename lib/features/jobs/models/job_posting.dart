import 'package:mobile_dev_summative/core/models/base_model.dart';
import 'package:mobile_dev_summative/features/jobs/models/employment_type.dart';

class JobPosting extends BaseModel {
  final String userId;
  final String title;
  final String company;
  final EmploymentType employmentType;
  final String location;
  final String description;
  final DateTime postedAt;

  JobPosting({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.title,
    required this.company,
    required this.employmentType,
    required this.location,
    required this.description,
    required this.postedAt,
  });

  factory JobPosting.fromMap(Map<String, dynamic> map) {
    return JobPosting(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      userId: map["userId"],
      title: map["title"],
      company: map["company"],
      employmentType: EmploymentType.values.byName(map["employmentType"]),
      location: map["location"],
      description: map["description"],
      postedAt: DateTime.parse(map["postedAt"]),
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "userId": userId,
      "title": title,
      "company": company,
      "employmentType": employmentType.name,
      "location": location,
      "description": description,
      "postedAt": postedAt.toIso8601String(),
    };
  }
}
