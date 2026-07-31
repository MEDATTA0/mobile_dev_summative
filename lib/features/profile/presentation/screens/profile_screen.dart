import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:mobile_dev_summative/features/profile/profile_providers.dart';
import 'package:mobile_dev_summative/features/settings/screens/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete profile',
              onPressed: () => _confirmDelete(context, ref, profile.uid),
            ),
        ],
      ),
      floatingActionButton: profileAsync.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileEditScreen(existing: profile),
                ),
              ),
              icon: Icon(profile == null ? Icons.person_add : Icons.edit),
              label: Text(profile == null ? 'Create' : 'Edit'),
            )
          : null,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ProfileMessage(
          icon: Icons.error_outline,
          title: 'Could not load profile',
          subtitle: '$error',
        ),
        data: (profile) {
          if (profile == null) {
            return const _ProfileMessage(
              icon: Icons.person_outline,
              title: 'No profile yet',
              subtitle: 'Tap Create to set up your profile.',
            );
          }
          return _ProfileView(profile: profile);
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete profile?'),
        content: const Text('This permanently removes your profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref.read(profileControllerProvider.notifier).delete(uid);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Profile deleted.' : 'Could not delete.')),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: (profile.photoUrl?.isNotEmpty ?? false)
                  ? NetworkImage(profile.photoUrl!)
                  : null,
              child: (profile.photoUrl?.isEmpty ?? true)
                  ? Text(
                      _initials(profile.name),
                      style: theme.textTheme.headlineMedium,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          if (profile.headline != null && profile.headline!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.headline!,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
          const SizedBox(height: 24),
          _InfoTile(icon: Icons.email_outlined, value: profile.email),
          if (profile.location != null && profile.location!.isNotEmpty)
            _InfoTile(icon: Icons.place_outlined, value: profile.location!),
          if (profile.phone != null && profile.phone!.isNotEmpty)
            _InfoTile(icon: Icons.phone_outlined, value: profile.phone!),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('About', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(profile.bio!, style: theme.textTheme.bodyMedium),
          ],
          if (profile.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Skills', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in profile.skills) Chip(label: Text(skill)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
