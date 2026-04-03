import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum StatusVariant { success, warning, danger, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusVariant variant;

  const StatusChip({
    super.key,
    required this.label,
    this.variant = StatusVariant.neutral,
  });

  Color _getColor() {
    switch (variant) {
      case StatusVariant.success:
        return AppColors.success;
      case StatusVariant.warning:
        return AppColors.warning;
      case StatusVariant.danger:
        return AppColors.danger;
      case StatusVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

