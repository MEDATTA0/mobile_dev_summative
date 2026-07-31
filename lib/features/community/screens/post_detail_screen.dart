import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/community/community_providers.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/models/post_reply.dart';
import 'package:mobile_dev_summative/features/community/screens/create_post_screen.dart';
import 'package:mobile_dev_summative/features/community/screens/widgets/community_widgets.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _replyController = TextEditingController();
  bool _sendingReply = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  // Falls back to a guest identity until the auth feature lands; the
  // Firestore rules will still enforce real ownership server-side.
  String get _currentUid =>
      ref.read(authRepositoryProvider).currentUser?.uid ?? 'guest';

  String get _currentName {
    final user = ref.read(authRepositoryProvider).currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'Guest';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendReply() async {
    final body = _replyController.text.trim();
    if (body.isEmpty) {
      _showSnack('Please write a reply first');
      return;
    }
    setState(() => _sendingReply = true);
    final now = DateTime.now();
    try {
      await ref
          .read(postReplyRepositoryProvider)
          .createReply(
            PostReply(
              id: '',
              createdAt: now,
              updatedAt: now,
              postId: widget.postId,
              authorId: _currentUid,
              authorName: _currentName,
              body: body,
            ),
          );
      _replyController.clear();
    } catch (error) {
      _showSnack('Could not send your reply: $error');
    } finally {
      if (mounted) setState(() => _sendingReply = false);
    }
  }

  Future<void> _deletePost(CommunityPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This will also remove all of its replies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(communityPostRepositoryProvider).deletePost(post.id);
      if (mounted) {
        Navigator.of(context).pop();
        _showSnack('Post deleted');
      }
    } catch (error) {
      _showSnack('Could not delete the post: $error');
    }
  }

  Future<void> _deleteReply(PostReply reply) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(postReplyRepositoryProvider).deleteReply(reply.id);
      _showSnack('Reply deleted');
    } catch (error) {
      _showSnack('Could not delete the reply: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(communityPostProvider(widget.postId));
    final repliesAsync = ref.watch(postRepliesProvider(widget.postId));

    return Scaffold(
      backgroundColor: CommunityColors.background,
      body: SafeArea(
        child: postAsync.when(
          data: (post) {
            if (post == null) {
              return const Center(child: Text('This post was deleted'));
            }
            final isOwner = post.authorId == _currentUid;

            return Column(
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: CommunityColors.green,
                      ),
                    ),
                    const Spacer(),
                    if (isOwner)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreatePostScreen(post: post),
                              ),
                            );
                          } else if (value == 'delete') {
                            _deletePost(post);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    children: [
                      _PostBody(post: post),
                      const SizedBox(height: 24),
                      repliesAsync.when(
                        data: (replies) => _RepliesSection(
                          replies: replies,
                          currentUid: _currentUid,
                          onDeleteReply: _deleteReply,
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stackTrace) =>
                            Text('Failed to load replies: $error'),
                      ),
                    ],
                  ),
                ),
                _ReplyComposer(
                  controller: _replyController,
                  sending: _sendingReply,
                  onSend: _sendReply,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Failed to load the post: $error')),
        ),
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
              PostTagChip(tag: post.tag),
            ],
          ),
          const SizedBox(height: 14),
          Text(post.title, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(post.body, style: textTheme.bodyMedium?.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

class _RepliesSection extends StatelessWidget {
  const _RepliesSection({
    required this.replies,
    required this.currentUid,
    required this.onDeleteReply,
  });

  final List<PostReply> replies;
  final String currentUid;
  final void Function(PostReply reply) onDeleteReply;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Replies (${replies.length})',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (replies.isEmpty)
          Text(
            'No replies yet. Be the first to help!',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          )
        else
          ...replies.map(
            (reply) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReplyCard(
                reply: reply,
                isOwn: reply.authorId == currentUid,
                onDelete: () => onDeleteReply(reply),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({
    required this.reply,
    required this.isOwn,
    required this.onDelete,
  });

  final PostReply reply;
  final bool isOwn;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostAvatar(name: reply.authorName, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.authorName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTimeAgo(reply.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reply.body,
                  style: textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          if (isOwn)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.grey.shade600,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Delete reply',
            ),
        ],
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                filled: true,
                fillColor: CommunityColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: sending ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: CommunityColors.green,
              foregroundColor: Colors.white,
            ),
            icon: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
