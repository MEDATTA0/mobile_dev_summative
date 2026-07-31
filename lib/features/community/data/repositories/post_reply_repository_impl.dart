import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/post_reply_repository.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';

class PostReplyRepositoryImpl extends BaseRepository<PostReply>
    implements PostReplyRepository {
  PostReplyRepositoryImpl() : super('replies', PostReply.fromMap);

  @override
  Stream<List<PostReply>> watchForPost(String postId) {
    // Sorted client-side: pairing where(postId) with a server-side
    // orderBy(createdAt) would require a composite Firestore index.
    return collectionRef.where('postId', isEqualTo: postId).snapshots().map((
      snapshot,
    ) {
      final replies = snapshot.docs.map((doc) => doc.data()).toList();
      replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return replies;
    });
  }

  @override
  Future<String> createReply(PostReply reply) {
    return create(reply);
  }

  @override
  Future<void> deleteReply(String id) {
    return delete(id);
  }
}
