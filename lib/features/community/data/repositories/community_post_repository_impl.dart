import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/community_post_repository.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';

class CommunityPostRepositoryImpl extends BaseRepository<CommunityPost>
    implements CommunityPostRepository {
  CommunityPostRepositoryImpl()
    : super('community_posts', CommunityPost.fromMap);

  Future<void> _seedIfEmpty() async {
    final existing = await collectionRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    await create(
      CommunityPost(
        id: '',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        authorId: 'seed-grace',
        authorName: 'Grace M.',
        title: 'My first Doctype is live!',
        body:
            'Just completed my first Doctype project! The sandbox was so '
            'helpful.',
        tag: 'Beginner',
      ),
    );
    final helpPostId = await create(
      CommunityPost(
        id: '',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        authorId: 'seed-diane',
        authorName: 'Diane K.',
        title: 'Custom script error in the sales module',
        body:
            'Can someone help me with custom scripts for the sales module? '
            "I'm getting an error on line 12.",
        tag: 'Help',
      ),
    );
    await create(
      CommunityPost(
        id: '',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        authorId: 'seed-ange',
        authorName: 'Ange N.',
        title: 'Study group tomorrow at 3pm',
        body: 'Our study group meets tomorrow at 3pm! All welcome.',
        tag: 'Group',
      ),
    );

    final replies = FirebaseFirestore.instance.collection('replies');
    await replies.add(
      PostReply(
        id: '',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        postId: helpPostId,
        authorId: 'seed-chantal',
        authorName: 'Chantal U.',
        body:
            'Usually that is a typo in the field name. Compare line 12 '
            'with the field list in your Doctype.',
      ).toMap()!,
    );
    await replies.add(
      PostReply(
        id: '',
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        postId: helpPostId,
        authorId: 'seed-grace',
        authorName: 'Grace M.',
        body:
            'I hit the same error in the sandbox. Re-running the setup '
            'step fixed it for me.',
      ).toMap()!,
    );
  }

  @override
  Stream<List<CommunityPost>> watchAll() async* {
    // First subscription seeds demo content so a fresh project is never empty.
    // Seeding failures are swallowed (e.g. once security rules reject writes
    // that lack a signed-in owner) — an empty feed beats a broken one.
    try {
      await _seedIfEmpty();
    } catch (_) {}
    yield* collectionRef
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
