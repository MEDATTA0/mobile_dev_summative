import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_summative/features/community/community_providers.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/community_post_repository.dart';
import 'package:mobile_dev_summative/features/community/domain/repositories/post_reply_repository.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';
import 'package:mobile_dev_summative/features/community/screens/community_screen.dart';

class FakeCommunityPostRepository implements CommunityPostRepository {
  FakeCommunityPostRepository(this.posts);

  final List<CommunityPost> posts;

  @override
  Stream<List<CommunityPost>> watchAll() => Stream.value(posts);

  @override
  Stream<CommunityPost?> watchById(String id) {
    for (final post in posts) {
      if (post.id == id) return Stream.value(post);
    }
    return Stream.value(null);
  }

  @override
  Future<String> createPost(CommunityPost post) async => 'fake-id';

  @override
  Future<void> updatePost(CommunityPost post) async {}

  @override
  Future<void> deletePost(String id) async {}
}

class FakePostReplyRepository implements PostReplyRepository {
  @override
  Stream<List<PostReply>> watchForPost(String postId) => Stream.value(const []);

  @override
  Future<String> createReply(PostReply reply) async => 'fake-id';

  @override
  Future<void> deleteReply(String id) async {}
}

void main() {
  final now = DateTime(2026, 7, 29, 10);
  final post = CommunityPost(
    id: 'post-1',
    createdAt: now,
    updatedAt: now,
    authorId: 'user-1',
    authorName: 'Grace M.',
    title: 'First Doctype done!',
    body:
        'Just completed my first Doctype project! The sandbox was so '
        'helpful.',
    tag: 'Beginner',
  );

  Widget buildScreen(List<CommunityPost> posts) {
    return ProviderScope(
      overrides: [
        communityPostRepositoryProvider.overrideWithValue(
          FakeCommunityPostRepository(posts),
        ),
        postReplyRepositoryProvider.overrideWithValue(
          FakePostReplyRepository(),
        ),
      ],
      child: const MaterialApp(home: CommunityScreen()),
    );
  }

  testWidgets('feed shows the posts streamed from the repository', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen([post]));
    await tester.pumpAndSettle();

    expect(find.text('Grace M.'), findsOneWidget);
    expect(find.text('First Doctype done!'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
  });

  testWidgets('feed shows the empty state when there are no posts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen(const []));
    await tester.pumpAndSettle();

    expect(find.text('No posts yet. Start the conversation!'), findsOneWidget);
  });
}
