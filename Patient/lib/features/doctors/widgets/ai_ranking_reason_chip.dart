import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Micro AI ranking reason chip shown under each doctor card.
class AiRankingReasonChip extends StatelessWidget {
  final String reason;
  final IconData icon;
  final Color color;

  const AiRankingReasonChip({
    super.key,
    required this.reason,
    this.icon = Icons.auto_awesome,
    this.color = const Color(0xFF6366F1),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            reason,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? color.withValues(alpha: 0.90) : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns a contextual ranking reason + color for a given doctor map.
({String reason, IconData icon, Color color}) aiRankingReason(
    Map<String, dynamic> doctor, String? aiSpecialty) {
  final specialty = doctor['specialty']?.toString() ?? '';
  final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
  final slots = doctor['available_slots'] as List? ?? [];
  final hasToday = slots.any((s) => s.toString().startsWith('Today'));

  if (aiSpecialty != null &&
      specialty.toLowerCase() == aiSpecialty.toLowerCase()) {
    return (
      reason: 'Best AI match for your condition',
      icon: Icons.auto_awesome,
      color: const Color(0xFF6366F1),
    );
  }
  if (hasToday) {
    return (
      reason: 'Fastest available today',
      icon: Icons.flash_on_rounded,
      color: const Color(0xFFF59E0B),
    );
  }
  if (rating >= 4.8) {
    return (
      reason: 'Top-rated in your city',
      icon: Icons.star_rounded,
      color: const Color(0xFF10B981),
    );
  }
  return (
    reason: 'Highly experienced specialist',
    icon: Icons.workspace_premium_rounded,
    color: AppColors.primary,
  );
}
