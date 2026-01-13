import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Bottom sheet for selecting check-in interval
class CheckInIntervalSheet extends StatefulWidget {
  const CheckInIntervalSheet({
    super.key,
    required this.currentDays,
    required this.onSelect,
  });

  final int currentDays;
  final void Function(int days) onSelect;

  @override
  State<CheckInIntervalSheet> createState() => _CheckInIntervalSheetState();
}

class _CheckInIntervalSheetState extends State<CheckInIntervalSheet> {
  late int _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.currentDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in Interval',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'How often should you check in?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          // Day options (1-7)
          ...List.generate(7, (index) {
            final days = index + 1;
            final label = days == 1 ? '1 day' : '$days days';
            final isSelected = _selectedDays == days;

            return RadioListTile<int>(
              value: days,
              groupValue: _selectedDays,
              onChanged: (value) {
                setState(() => _selectedDays = value!);
              },
              title: Text(label),
              activeColor: AppColors.primary,
              selected: isSelected,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onSelect(_selectedDays);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Show the check-in interval selection bottom sheet
Future<void> showCheckInIntervalSheet(
  BuildContext context, {
  required int currentDays,
  required void Function(int days) onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => CheckInIntervalSheet(
      currentDays: currentDays,
      onSelect: onSelect,
    ),
  );
}
