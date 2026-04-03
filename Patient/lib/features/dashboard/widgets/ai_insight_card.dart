import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum InsightCategory { nutrition, sleep, vitals, medication, recovery, warning }

class AiInsightCard extends StatelessWidget {
  final String insight;
  final InsightCategory category;
  final String? timeAgo;

  const AiInsightCard({
    super.key,
    required this.insight,
    this.category = InsightCategory.vitals,
    this.timeAgo,
  });

  _InsightMeta _meta() {
    switch (category) {
      case InsightCategory.nutrition:
        return _InsightMeta(
          icon: Icons.restaurant_outlined,
          color: const Color(0xFFF59E0B),
          label: 'Nutrition',
          gradient: [const Color(0xFFFFF7ED), const Color(0xFFFEF3C7)],
          darkGradient: [const Color(0xFF292524), const Color(0xFF1C1917)],
        );
      case InsightCategory.sleep:
        return _InsightMeta(
          icon: Icons.bedtime_outlined,
          color: const Color(0xFF8B5CF6),
          label: 'Sleep',
          gradient: [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
          darkGradient: [const Color(0xFF1E1B4B), const Color(0xFF1A1040)],
        );
      case InsightCategory.medication:
        return _InsightMeta(
          icon: Icons.medication_outlined,
          color: const Color(0xFF2A7FFF),
          label: 'Medication',
          gradient: [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          darkGradient: [const Color(0xFF1E2D45), const Color(0xFF172035)],
        );
      case InsightCategory.recovery:
        return _InsightMeta(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF10B981),
          label: 'Recovery',
          gradient: [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
          darkGradient: [const Color(0xFF0A2818), const Color(0xFF071E12)],
        );
      case InsightCategory.warning:
        return _InsightMeta(
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEF4444),
          label: 'Alert',
          gradient: [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)],
          darkGradient: [const Color(0xFF2D1515), const Color(0xFF1F0F0F)],
        );
      case InsightCategory.vitals:
        return _InsightMeta(
          icon: Icons.monitor_heart_outlined,
          color: const Color(0xFF06B6D4),
          label: 'Vitals',
          gradient: [const Color(0xFFECFEFF), const Color(0xFFCFFAFE)],
          darkGradient: [const Color(0xFF0C2B33), const Color(0xFF081B20)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _meta();
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? meta.darkGradient : meta.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: meta.color.withValues(alpha: isDark ? 0.2 : 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: meta.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(meta.icon, color: meta.color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                meta.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: meta.color,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 8, color: meta.color),
                    const SizedBox(width: 3),
                    Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: meta.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textPrimary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (timeAgo != null) ...[
            const SizedBox(height: 10),
            Text(
              timeAgo!,
              style: TextStyle(fontSize: 11, color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightMeta {
  final IconData icon;
  final Color color;
  final String label;
  final List<Color> gradient;
  final List<Color> darkGradient;

  const _InsightMeta({
    required this.icon,
    required this.color,
    required this.label,
    required this.gradient,
    required this.darkGradient,
  });
}
