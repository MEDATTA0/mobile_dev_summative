import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/core/repositories/auth_repository.dart';
import 'package:mobile_dev_summative/features/profile/domain/entities/profile.dart';
import 'package:mobile_dev_summative/features/profile/profile_providers.dart';

/// Create (when [existing] is null) or edit a profile.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, this.existing});

  final Profile? existing;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _headline;
  late final TextEditingController _bio;
  late final TextEditingController _location;
  late final TextEditingController _phone;
  late final TextEditingController _skills;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    final authEmail = ref.read(authRepositoryProvider).currentUser?.email;
    _name = TextEditingController(text: p?.name ?? '');
    _email = TextEditingController(text: p?.email ?? authEmail ?? '');
    _headline = TextEditingController(text: p?.headline ?? '');
    _bio = TextEditingController(text: p?.bio ?? '');
    _location = TextEditingController(text: p?.location ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _skills = TextEditingController(text: p?.skills.join(', ') ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _headline, _bio, _location, _phone, _skills]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.existing;
    final uid = existing?.uid ?? ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) {
      _showSnack('You must be signed in to save a profile.');
      return;
    }

    final now = DateTime.now();
    final profile = Profile(
      uid: uid,
      name: _name.text.trim(),
      email: _email.text.trim(),
      headline: _nullIfEmpty(_headline.text),
      bio: _nullIfEmpty(_bio.text),
      location: _nullIfEmpty(_location.text),
      phone: _nullIfEmpty(_phone.text),
      photoUrl: existing?.photoUrl,
      skills: _parseSkills(_skills.text),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final controller = ref.read(profileControllerProvider.notifier);
    final ok = existing == null
        ? await controller.save(profile)
        : await controller.updateProfile(profile);

    if (!mounted) return;
    if (ok) {
      _showSnack('Profile saved.');
      Navigator.of(context).pop();
    } else {
      final error = ref.read(profileControllerProvider).error;
      _showSnack('Could not save: $error');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileControllerProvider).isLoading;
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit profile' : 'Create profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(_name, 'Full name', required: true),
              _field(
                _email,
                'Email',
                required: true,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              _field(_headline, 'Headline'),
              _field(_bio, 'About', maxLines: 4),
              _field(_location, 'Location'),
              _field(_phone, 'Phone', keyboardType: TextInputType.phone),
              _field(_skills, 'Skills (comma separated)'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (required
                ? (value) => (value == null || value.trim().isEmpty)
                    ? '$label is required'
                    : null
                : null),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    return pattern.hasMatch(text) ? null : 'Enter a valid email';
  }

  static String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _parseSkills(String value) {
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
