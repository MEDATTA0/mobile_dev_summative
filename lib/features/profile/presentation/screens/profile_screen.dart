import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/theme/app_colors.dart';
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
    final details = <Widget>[
      if (profile.location != null && profile.location!.isNotEmpty)
        _DetailRow(icon: Icons.place_outlined, value: profile.location!),
      if (profile.phone != null && profile.phone!.isNotEmpty)
        _DetailRow(icon: Icons.phone_outlined, value: profile.phone!),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentityCard(profile: profile),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Card(child: Column(children: _withDividers(details))),
          ],
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'About',
              child: Text(
                profile.bio!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.4),
              ),
            ),
          ],
          if (profile.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Skills',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final skill in profile.skills) _SkillChip(skill),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> rows) {
    final result = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      result.add(rows[i]);
      if (i != rows.length - 1) {
        result.add(const Divider(height: 20));
      }
    }
    return result;
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = profile.photoUrl?.isNotEmpty ?? false;

    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: hasPhoto ? NetworkImage(profile.photoUrl!) : null,
            child: hasPhoto
                ? null
                : Text(
                    _initials(profile.name),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (profile.headline != null && profile.headline!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.headline!,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  profile.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
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

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
