import 'package:mobile_dev_summative/core/models/base_model.dart';

class PostReply extends BaseModel {
  final String postId;
  final String authorId;
  final String authorName;
  final String body;

  PostReply({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.body,
  });

  factory PostReply.fromMap(Map<String, dynamic> map) {
    return PostReply(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
      postId: map["postId"],
      authorId: map["authorId"],
      authorName: map["authorName"],
      body: map["body"],
    );
  }

  @override
  Map<String, dynamic>? toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "postId": postId,
      "authorId": authorId,
      "authorName": authorName,
      "body": body,
    };
  }
}
