import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/check_in_provider.dart';
import '../widgets/check_in_button.dart';
import '../widgets/countdown_timer.dart';

/// Main check-in screen with countdown timer and check-in button
class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInNotifierProvider);
    final isOverdue = ref.watch(isOverdueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Countdown timer
              CountdownTimer(nextDue: checkInState.nextDue),
              const Spacer(flex: 1),
              // Check-in button
              CheckInButton(
                onPressed: () {
                  ref.read(checkInNotifierProvider.notifier).checkIn();
                },
                isShowingSuccess: checkInState.isShowingSuccess,
                isOverdue: isOverdue,
              ),
              const Spacer(flex: 1),
              // Last check-in info
              _buildLastCheckInInfo(context, checkInState.lastCheckIn),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastCheckInInfo(BuildContext context, DateTime? lastCheckIn) {
    if (lastCheckIn == null) {
      return Text(
        "You haven't checked in yet",
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      );
    }

    final now = DateTime.now();
    final diff = now.difference(lastCheckIn);
    final timeAgo = _formatTimeAgo(diff);

    return Text(
      'Last check-in: $timeAgo',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }

  String _formatTimeAgo(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ago';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} ago';
    } else if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
