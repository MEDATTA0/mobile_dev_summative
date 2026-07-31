import 'package:mobile_dev_summative/features/community/models/community_post.dart';

abstract class CommunityPostRepository {
  Stream<List<CommunityPost>> watchAll();
  Stream<CommunityPost?> watchById(String id);
  Future<String> createPost(CommunityPost post);
  Future<void> updatePost(CommunityPost post);
  Future<void> deletePost(String id);
}
