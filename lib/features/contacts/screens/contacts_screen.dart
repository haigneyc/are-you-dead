import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/contacts_provider.dart';
import '../widgets/contact_card.dart';

/// Screen displaying list of emergency contacts
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(contactsNotifierProvider.notifier).refresh(),
        child: _buildContent(context, ref, contactsState),
      ),
      floatingActionButton: ref.watch(canAddContactProvider)
          ? FloatingActionButton(
              onPressed: () => context.push('/contacts/add'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ContactsState state,
  ) {
    // Loading state
    if (state.isLoading && state.contacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.error != null && state.contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load contacts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(contactsNotifierProvider.notifier).refresh(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (state.contacts.isEmpty) {
      return _buildEmptyState(context);
    }

    // Contacts list
    return _buildContactsList(context, ref, state);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_outlined,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No Emergency Contacts',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add someone who should be notified\nif you miss a check-in.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.push('/contacts/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add First Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList(
    BuildContext context,
    WidgetRef ref,
    ContactsState state,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: state.contacts.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        // Footer with info text
        if (index == state.contacts.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'These contacts will receive an SMS and email if you miss a check-in.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final contact = state.contacts[index];
        return Dismissible(
          key: Key(contact.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: AppColors.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => _showDeleteConfirmation(context, contact.name),
          onDismissed: (_) =>
              ref.read(contactsNotifierProvider.notifier).deleteContact(contact.id),
          child: ContactCard(
            contact: contact,
            onTap: () => context.push('/contacts/edit/${contact.id}'),
            onDelete: () async {
              final confirmed =
                  await _showDeleteConfirmation(context, contact.name);
              if (confirmed == true) {
                ref.read(contactsNotifierProvider.notifier).deleteContact(contact.id);
              }
            },
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String contactName,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
          'Are you sure you want to remove $contactName as an emergency contact?',
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
  }
}
