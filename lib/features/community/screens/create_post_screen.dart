import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/community/community_providers.dart';
import 'package:mobile_dev_summative/features/community/models/community_post.dart';
import 'package:mobile_dev_summative/features/community/screens/widgets/community_widgets.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.post});

  /// When non-null the screen edits this post instead of creating a new one.
  final CommunityPost? post;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  static const _tags = ['Beginner', 'Help', 'Group'];

  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.post?.title);
  late final _bodyController = TextEditingController(text: widget.post?.body);
  late String _tag = widget.post?.tag ?? _tags.first;
  bool _saving = false;

  bool get _isEditing => widget.post != null;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repository = ref.read(communityPostRepositoryProvider);
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final now = DateTime.now();

    try {
      if (_isEditing) {
        await repository.updatePost(
          widget.post!.copyWith(
            title: title,
            body: body,
            tag: _tag,
            updatedAt: now,
          ),
        );
      } else {
        // Falls back to a guest identity until the auth feature lands; the
        // Firestore rules will still enforce real ownership server-side.
        final user = ref.read(authRepositoryProvider).currentUser;
        await repository.createPost(
          CommunityPost(
            id: '',
            createdAt: now,
            updatedAt: now,
            authorId: user?.uid ?? 'guest',
            authorName:
                user?.displayName ?? user?.email?.split('@').first ?? 'Guest',
            title: title,
            body: body,
            tag: _tag,
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Post updated' : 'Posted!')),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your post: $error')),
        );
      }
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CommunityColors.green),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CommunityColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: CommunityColors.green,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Edit post' : 'New post',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ask a question or share your progress',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Title', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: _fieldDecoration(
                          'What is your post about?',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please add a title before posting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Message', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bodyController,
                        decoration: _fieldDecoration(
                          'Share the details with the community...',
                        ),
                        minLines: 5,
                        maxLines: 10,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please write a message before posting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Tag', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _tags.map((tag) {
                          final selected = tag == _tag;
                          return ChoiceChip(
                            label: Text(tag),
                            selected: selected,
                            onSelected: (_) => setState(() => _tag = tag),
                            selectedColor: CommunityColors.greenLight,
                            labelStyle: TextStyle(
                              color: selected
                                  ? CommunityColors.green
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            checkmarkColor: CommunityColors.green,
                            side: BorderSide(
                              color: selected
                                  ? CommunityColors.green
                                  : Colors.grey.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: CommunityColors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isEditing ? 'Save changes' : 'Post'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
