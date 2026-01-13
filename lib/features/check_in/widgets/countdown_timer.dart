import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Countdown timer display for check-in deadline
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.nextDue,
  });

  /// When the next check-in is due
  final DateTime? nextDue;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updateRemaining();
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nextDue != oldWidget.nextDue) {
      _updateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    // Update every second when less than 1 hour, otherwise every minute
    final updateInterval = _remaining.inHours < 1
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);

    _timer?.cancel();
    _timer = Timer.periodic(updateInterval, (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.nextDue == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }

    final now = DateTime.now();
    final remaining = widget.nextDue!.difference(now);

    setState(() => _remaining = remaining);

    // Handle pulse animation for overdue
    if (remaining.isNegative) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Adjust timer frequency based on remaining time
    if (remaining.inHours < 1 && _timer?.tick != null) {
      _startTimer();
    }
  }

  Color _getColor() {
    if (_remaining.isNegative) {
      return AppColors.timerCritical;
    } else if (_remaining.inHours < 1) {
      return AppColors.timerCritical;
    } else if (_remaining.inHours < 6) {
      return AppColors.timerUrgent;
    } else {
      return AppColors.timerNormal;
    }
  }

  String _formatDuration() {
    if (_remaining.isNegative) {
      return 'OVERDUE';
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''}, $hours hour${hours > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}, $minutes min';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nextDue == null) {
      return const Text(
        'No check-in scheduled',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      );
    }

    final color = _getColor();
    final text = _formatDuration();
    final isOverdue = _remaining.isNegative;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isOverdue ? 'Check-in overdue!' : 'Next check-in due in',
          style: TextStyle(
            fontSize: 14,
            color: isOverdue ? color : AppColors.textSecondary,
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = isOverdue ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
