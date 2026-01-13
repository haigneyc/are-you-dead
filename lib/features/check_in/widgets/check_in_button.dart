import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Large animated check-in button
class CheckInButton extends StatefulWidget {
  const CheckInButton({
    super.key,
    required this.onPressed,
    this.isShowingSuccess = false,
    this.isOverdue = false,
    this.isEnabled = true,
  });

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Whether to show success state (checkmark)
  final bool isShowingSuccess;

  /// Whether the user is overdue for check-in
  final bool isOverdue;

  /// Whether the button is enabled
  final bool isEnabled;

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(CheckInButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShowingSuccess && !oldWidget.isShowingSuccess) {
      _controller.forward();
    } else if (!widget.isShowingSuccess && oldWidget.isShowingSuccess) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (!widget.isEnabled) return;
    HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = widget.isShowingSuccess
              ? _scaleAnimation.value
              : (_isPressed ? 0.95 : 1.0);

          return Transform.scale(
            scale: scale,
            child: _buildButton(),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    final Color backgroundColor;
    final Widget content;

    if (widget.isShowingSuccess) {
      backgroundColor = AppColors.success;
      content = const Icon(
        Icons.check,
        color: AppColors.textOnPrimary,
        size: 64,
      );
    } else if (widget.isOverdue) {
      backgroundColor = AppColors.error;
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "I'M OK",
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'OVERDUE',
            style: TextStyle(
              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      backgroundColor = widget.isEnabled ? AppColors.primary : Colors.grey;
      content = Text(
        "I'M OK",
        style: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }
}
