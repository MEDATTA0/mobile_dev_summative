import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/community_post_repository.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';

class CommunityPostRepositoryImpl extends BaseRepository<CommunityPost>
    implements CommunityPostRepository {
  CommunityPostRepositoryImpl()
    : super('community_posts', CommunityPost.fromMap);

  @override
  Stream<List<CommunityPost>> watchAll() {
    return collectionRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<CommunityPost?> watchById(String id) {
    return collectionRef.doc(id).snapshots().map((snapshot) => snapshot.data());
  }

  @override
  Future<String> createPost(CommunityPost post) {
    return create(post);
  }

  @override
  Future<void> updatePost(CommunityPost post) {
    return update(post);
  }

  @override
  Future<void> deletePost(String id) async {
    // Batched so the post and its replies are removed atomically — deleting
    // them one by one could fail midway and leave orphaned replies behind.
    final firestore = FirebaseFirestore.instance;
    final replies = await firestore
        .collection('replies')
        .where('postId', isEqualTo: id)
        .get();
    final batch = firestore.batch();
    for (final doc in replies.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(collectionRef.doc(id));
    await batch.commit();
  }
}
