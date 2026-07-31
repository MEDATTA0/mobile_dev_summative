import 'package:mobile_dev_summative/features/community/models/post_reply.dart';

abstract class PostReplyRepository {
  Stream<List<PostReply>> watchForPost(String postId);
  Future<String> createReply(PostReply reply);
  Future<void> deleteReply(String id);
}
