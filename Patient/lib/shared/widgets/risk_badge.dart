import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RiskBadge extends StatelessWidget {
  final String risk;

  const RiskBadge({super.key, required this.risk});

  Color _getRiskColor() {
    final lower = risk.toLowerCase();
    if (lower.contains('high')) return AppColors.danger;
    if (lower.contains('med')) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    Color color = _getRiskColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        risk.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

