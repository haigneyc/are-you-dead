import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/check_in_interval_sheet.dart';

/// Settings screen with profile and preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProfileProvider);
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(userProfileNotifierProvider);
    final isLoading = authState.isLoading;
    final isSaving = profileState.isSaving;

    // Derived state
    final checkInDays = ref.watch(checkInIntervalDaysProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    // Listen for profile operation errors
    ref.listen(userProfileNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(userProfileNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: userProfile.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile section - now tappable
            Card(
              child: InkWell(
                onTap: () => context.push('/settings/profile'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          (user?.displayName ?? user?.email ?? '?')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'No name set',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            if (user?.phone != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                user!.phone!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Settings options
            Card(
              child: Column(
                children: [
                  // Check-in Interval - opens bottom sheet
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Check-in Interval'),
                    subtitle: Text(
                      checkInDays == 1 ? '1 day' : '$checkInDays days',
                    ),
                    trailing: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    enabled: !isSaving,
                    onTap: () => _showIntervalPicker(context, ref, checkInDays),
                  ),
                  const Divider(height: 1),

                  // Notifications toggle - inline switch
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('Push Notifications'),
                    subtitle: Text(
                      notificationsEnabled
                          ? 'Receive check-in reminders'
                          : 'Notifications disabled',
                    ),
                    value: notificationsEnabled,
                    onChanged: isSaving
                        ? null
                        : (enabled) => _toggleNotifications(ref, enabled),
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: false, // Coming later
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign out button
            AppButton(
              variant: AppButtonVariant.secondary,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 16),

            // App version
            Center(
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }

  void _showIntervalPicker(
      BuildContext context, WidgetRef ref, int currentDays) {
    showCheckInIntervalSheet(
      context,
      currentDays: currentDays,
      onSelect: (days) async {
        await ref
            .read(userProfileNotifierProvider.notifier)
            .updateCheckInInterval(days);
      },
    );
  }

  void _toggleNotifications(WidgetRef ref, bool enabled) {
    ref.read(userProfileNotifierProvider.notifier).setNotificationsEnabled(enabled);
  }
}
