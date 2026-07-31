import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';

void main() {
  final postMap = {
    "id": "post-1",
    "createdAt": "2026-07-29T10:00:00.000",
    "updatedAt": "2026-07-29T10:00:00.000",
    "authorId": "user-1",
    "authorName": "Amina",
    "title": "How do I create my first Doctype?",
    "body": "I finished the sandbox intro but I am stuck on adding fields.",
    "tag": "Help",
  };

  group('CommunityPost', () {
    test('fromMap and toMap round-trip preserves every field', () {
      final post = CommunityPost.fromMap(postMap);
      expect(post.toMap(), postMap);
    });

    test('isEdited is false when the post was never edited', () {
      final post = CommunityPost.fromMap(postMap);
      expect(post.isEdited, isFalse);
    });

    test('isEdited is true once updatedAt is after createdAt', () {
      final post = CommunityPost.fromMap(postMap);
      final edited = post.copyWith(
        body: 'Solved it, leaving the fix here for others.',
        updatedAt: post.createdAt.add(const Duration(minutes: 5)),
      );
      expect(edited.isEdited, isTrue);
    });

    test('copyWith replaces only the given fields', () {
      final post = CommunityPost.fromMap(postMap);
      final edited = post.copyWith(title: 'Doctype creation — solved');

      expect(edited.title, 'Doctype creation — solved');
      expect(edited.body, post.body);
      expect(edited.tag, post.tag);
      expect(edited.id, post.id);
      expect(edited.authorId, post.authorId);
    });
  });

  group('PostReply', () {
    test('fromMap and toMap round-trip preserves every field', () {
      final replyMap = {
        "id": "reply-1",
        "createdAt": "2026-07-29T11:30:00.000",
        "updatedAt": "2026-07-29T11:30:00.000",
        "postId": "post-1",
        "authorId": "user-2",
        "authorName": "Chantal",
        "body": "Open the Doctype list and use the plus button on fields.",
      };

      final reply = PostReply.fromMap(replyMap);
      expect(reply.toMap(), replyMap);
    });
  });
}
