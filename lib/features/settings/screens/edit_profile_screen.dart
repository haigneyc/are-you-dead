import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

/// Screen for editing user profile (display name and phone)
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load existing profile data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeFromProfile() {
    if (_isInitialized) return;

    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile != null) {
      setState(() {
        _nameController.text = profile.displayName ?? '';
        _phoneController.text = profile.phone ?? '';
        _isInitialized = true;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(userProfileNotifierProvider.notifier).updateProfile(
              displayName: _nameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _cleanPhone(_phoneController.text),
            );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(userProfileNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to update profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Clean phone number by removing formatting characters
  String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileNotifierProvider);
    final isLoading = profileState.isSaving;

    // Re-initialize if profile data becomes available
    ref.listen(currentUserProfileProvider, (previous, next) {
      if (next.hasValue && !_isInitialized) {
        _initializeFromProfile();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _handleSave,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Display Name',
              hint: 'Enter your name',
              prefixIcon: const Icon(Icons.person_outline),
              validator: Validators.validateName,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number (optional)',
              hint: '+1 555 123 4567',
              prefixIcon: const Icon(Icons.phone_outlined),
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              onFieldSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 24),
            Text(
              'Your phone number can be used for account recovery.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            AppButton(
              onPressed: _handleSave,
              isLoading: isLoading,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
