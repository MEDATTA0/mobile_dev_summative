import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/community/data/repositories/community_post_repository_impl.dart';
import 'package:mobile_dev_summative/features/community/data/repositories/post_reply_repository_impl.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/community_post_repository.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/post_reply_repository.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';

final communityPostRepositoryProvider = Provider<CommunityPostRepository>((
  ref,
) {
  return CommunityPostRepositoryImpl();
});

final postReplyRepositoryProvider = Provider<PostReplyRepository>((ref) {
  return PostReplyRepositoryImpl();
});

final communityPostsProvider = StreamProvider<List<CommunityPost>>((ref) {
  return ref.watch(communityPostRepositoryProvider).watchAll();
});

final communityPostProvider = StreamProvider.family<CommunityPost?, String>((
  ref,
  postId,
) {
  return ref.watch(communityPostRepositoryProvider).watchById(postId);
});

final postRepliesProvider = StreamProvider.family<List<PostReply>, String>((
  ref,
  postId,
) {
  return ref.watch(postReplyRepositoryProvider).watchForPost(postId);
});
