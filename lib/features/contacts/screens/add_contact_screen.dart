import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/emergency_contact.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../providers/contacts_provider.dart';

/// Screen for adding or editing an emergency contact
class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({
    super.key,
    this.contactId,
  });

  /// If provided, we're editing an existing contact
  final String? contactId;

  bool get isEditing => contactId != null;

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  EmergencyContact? _existingContact;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      // Load existing contact data after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingContact();
      });
    }
  }

  void _loadExistingContact() {
    final contact = ref.read(contactByIdProvider(widget.contactId!));
    if (contact != null) {
      setState(() {
        _existingContact = contact;
        _nameController.text = contact.name;
        _phoneController.text = contact.phone;
        _emailController.text = contact.email ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final notifier = ref.read(contactsNotifierProvider.notifier);

    bool success;
    if (widget.isEditing) {
      success = await notifier.updateContact(
        contactId: widget.contactId!,
        name: _nameController.text.trim(),
        phone: _cleanPhone(_phoneController.text),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
    } else {
      success = await notifier.addContact(
        name: _nameController.text.trim(),
        phone: _cleanPhone(_phoneController.text),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      final error = ref.read(contactsNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to save contact'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
          'Are you sure you want to remove ${_existingContact?.name ?? 'this contact'} as an emergency contact?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(contactsNotifierProvider.notifier)
        .deleteContact(widget.contactId!);

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.pop();
    }
  }

  /// Clean phone number by removing formatting characters
  String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Validate email only if provided (optional field)
  String? _validateOptionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    return Validators.validateEmail(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Contact' : 'Add Contact'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
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
              label: 'Name',
              hint: 'Enter contact name',
              prefixIcon: const Icon(Icons.person_outline),
              validator: Validators.validateName,
              textInputAction: TextInputAction.next,
              autofocus: !widget.isEditing,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+1 555 123 4567',
              prefixIcon: const Icon(Icons.phone_outlined),
              validator: Validators.validatePhoneRequired,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Email (optional)',
              hint: 'contact@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              validator: _validateOptionalEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 24),
            Text(
              'This contact will receive an SMS and email if you miss a check-in.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            AppButton(
              onPressed: _handleSave,
              isLoading: _isLoading,
              child: Text(widget.isEditing ? 'Save Changes' : 'Add Contact'),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 16),
              AppButton(
                variant: AppButtonVariant.danger,
                onPressed: _handleDelete,
                isLoading: _isLoading,
                child: const Text('Delete Contact'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
