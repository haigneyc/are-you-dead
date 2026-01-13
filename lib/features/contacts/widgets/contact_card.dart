import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/emergency_contact.dart';

/// Card widget displaying an emergency contact
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onDelete,
  });

  final EmergencyContact contact;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// Mask a phone number to show only last 4 digits
  /// Example: +15551234567 -> ***-***-4567
  String _maskPhone(String phone) {
    if (phone.length < 4) return phone;
    final lastFour = phone.substring(phone.length - 4);
    return '***-***-$lastFour';
  }

  /// Mask an email to show only first char and domain
  /// Example: john@email.com -> j***@email.com
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final firstChar = parts[0].isNotEmpty ? parts[0][0] : '';
    return '$firstChar***@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with contact initial
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _maskPhone(contact.phone),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (contact.email != null && contact.email!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _maskEmail(contact.email!),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Popup menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onTap();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppColors.error),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
