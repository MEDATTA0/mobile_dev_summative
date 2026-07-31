import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_dev_summative/features/community/community_providers.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/community_post_repository.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/post_reply_repository.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';

class MockCommunityPostRepository extends Mock
    implements CommunityPostRepository {}

class MockPostReplyRepository extends Mock implements PostReplyRepository {}

void main() {
  final now = DateTime(2026, 7, 29, 10);

  test('communityPostsProvider emits the posts from the repository', () async {
    final mockRepo = MockCommunityPostRepository();
    final post = CommunityPost(
      id: 'post-1',
      createdAt: now,
      updatedAt: now,
      authorId: 'user-1',
      authorName: 'Amina',
      title: 'How do I create my first Doctype?',
      body: 'I finished the sandbox intro but I am stuck on adding fields.',
      tag: 'Help',
    );
    when(() => mockRepo.watchAll()).thenAnswer((_) => Stream.value([post]));

    final container = ProviderContainer(
      overrides: [communityPostRepositoryProvider.overrideWithValue(mockRepo)],
    );
    addTearDown(container.dispose);

    // Riverpod 3 pauses providers nobody listens to, so subscribe first.
    container.listen(communityPostsProvider, (previous, next) {});
    final posts = await container.read(communityPostsProvider.future);

    expect(posts, [post]);
    verify(() => mockRepo.watchAll()).called(1);
  });

  test('postRepliesProvider requests the replies for that post', () async {
    final mockRepo = MockPostReplyRepository();
    final reply = PostReply(
      id: 'reply-1',
      createdAt: now,
      updatedAt: now,
      postId: 'post-1',
      authorId: 'user-2',
      authorName: 'Chantal',
      body: 'Open the Doctype list and use the plus button on fields.',
    );
    when(
      () => mockRepo.watchForPost('post-1'),
    ).thenAnswer((_) => Stream.value([reply]));

    final container = ProviderContainer(
      overrides: [postReplyRepositoryProvider.overrideWithValue(mockRepo)],
    );
    addTearDown(container.dispose);

    container.listen(postRepliesProvider('post-1'), (previous, next) {});
    final replies = await container.read(postRepliesProvider('post-1').future);

    expect(replies, [reply]);
    verify(() => mockRepo.watchForPost('post-1')).called(1);
  });
}
