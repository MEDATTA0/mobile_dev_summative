import 'package:mobile_dev_summative/core/models/base_model.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';

/// Firestore representation of a profile at `users/{uid}` ([id] is the uid).
class ProfileModel extends BaseModel {
  final String name;
  final String email;
  final String? headline;
  final String? bio;
  final String? location;
  final String? phone;
  final String? photoUrl;
  final List<String> skills;

  ProfileModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.email,
    this.headline,
    this.bio,
    this.location,
    this.phone,
    this.photoUrl,
    this.skills = const [],
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      name: map["name"],
      email: map["email"],
      headline: map["headline"],
      bio: map["bio"],
      location: map["location"],
      phone: map["phone"],
      photoUrl: map["photoUrl"],
      skills: (map["skills"] as List?)?.cast<String>() ?? const [],
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.uid,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      name: profile.name,
      email: profile.email,
      headline: profile.headline,
      bio: profile.bio,
      location: profile.location,
      phone: profile.phone,
      photoUrl: profile.photoUrl,
      skills: profile.skills,
    );
  }

  Profile toEntity() {
    return Profile(
      uid: id,
      name: name,
      email: email,
      headline: headline,
      bio: bio,
      location: location,
      phone: phone,
      photoUrl: photoUrl,
      skills: skills,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "name": name,
      "email": email,
      "headline": headline,
      "bio": bio,
      "location": location,
      "phone": phone,
      "photoUrl": photoUrl,
      "skills": skills,
    };
  }
}
