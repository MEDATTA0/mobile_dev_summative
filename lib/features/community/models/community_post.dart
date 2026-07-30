import 'package:mobile_dev_summative/core/models/base_model.dart';

class CommunityPost extends BaseModel {
  final String authorId;
  final String authorName;
  final String title;
  final String body;

  CommunityPost({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.body,
  });

  bool get isEdited => updatedAt.isAfter(createdAt);

  CommunityPost copyWith({String? title, String? body, DateTime? updatedAt}) {
    return CommunityPost(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId,
      authorName: authorName,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      authorId: map["authorId"],
      authorName: map["authorName"],
      title: map["title"],
      body: map["body"],
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "authorId": authorId,
      "authorName": authorName,
      "title": title,
      "body": body,
    };
  }
}
