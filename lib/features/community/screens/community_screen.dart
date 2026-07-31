import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/community/community_providers.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/screens/create_post_screen.dart';
import 'package:mobile_dev_summative/features/community/screens/post_detail_screen.dart';
import 'package:mobile_dev_summative/features/community/screens/widgets/community_widgets.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final postsAsync = ref.watch(communityPostsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CommunityColors.background,
        floatingActionButton: FloatingActionButton(
          backgroundColor: CommunityColors.orange,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text('Community', style: textTheme.headlineSmall),
                    ),
                    const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: CommunityColors.green,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'Feed'),
                        Tab(text: 'Groups'),
                        Tab(text: 'Mentors'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _FeedTab(postsAsync: postsAsync),
                    const _ComingSoonTab(
                      icon: Icons.group_outlined,
                      message: 'Groups are coming soon',
                    ),
                    const _ComingSoonTab(
                      icon: Icons.school_outlined,
                      message: 'Mentor matching is coming soon',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({required this.postsAsync});

  final AsyncValue<List<CommunityPost>> postsAsync;

  @override
  Widget build(BuildContext context) {
    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const _ComingSoonTab(
            icon: Icons.forum_outlined,
            message: 'No posts yet. Start the conversation!',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
          itemCount: posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _PostCard(post: posts[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Failed to load posts: $error')),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: post.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PostAvatar(name: post.authorName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        post.isEdited
                            ? '${formatTimeAgo(post.createdAt)} · edited'
                            : formatTimeAgo(post.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.title, style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              post.body,
              style: textTheme.bodyMedium?.copyWith(height: 1.35),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            PostTagChip(tag: post.tag),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
