import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VitalsStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color color;
  final bool? trending;

  const VitalsStatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    required this.color,
    this.trending,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    unit!,
                    style: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trending != null)
                Icon(
                  trending! ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 11,
                  color: trending! ? const Color(0xFF10B981) : AppColors.danger,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
