import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class UrgencyBadge extends StatelessWidget {
  final String urgency; // "High", "Medium", "Low"

  const UrgencyBadge({super.key, required this.urgency});

  Color _getColor() {
    final lower = urgency.toLowerCase();
    if (lower.contains('high')) return AppColors.danger;
    if (lower.contains('med')) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    Color color = _getColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        urgency.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

