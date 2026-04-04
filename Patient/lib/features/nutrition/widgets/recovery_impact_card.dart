import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/meal_entity.dart';

/// Recovery impact card shown under food detail / scan result.
class RecoveryImpactCard extends StatelessWidget {
  final MealEntity meal;
  final double amountG;

  const RecoveryImpactCard({
    super.key,
    required this.meal,
    this.amountG = 100,
  });

  List<_ImpactItem> _computeImpacts() {
    final n = meal.nutriments;
    final factor = amountG / 100;
    final impacts = <_ImpactItem>[];

    final protein  = (n.proteins100 ?? 0) * factor;
    final sodium   = (n.sodium100 ?? 0) * factor * 1000; // mg
    final fiber    = (n.fiber100 ?? 0) * factor;
    final sugar    = (n.sugars100 ?? 0) * factor;
    final vitC     = (n.vitaminC100 ?? 0) * factor;
    final calcium  = (n.calcium100 ?? 0) * factor;
    final fat      = (n.fat100 ?? 0) * factor;
    final name     = meal.name?.toLowerCase() ?? '';

    // Hydration
    if (name.contains('water') || name.contains('coconut') || name.contains('juice')) {
      impacts.add(const _ImpactItem('+6', 'Hydration recovery', Color(0xFF0EA5E9)));
    }

    // Muscle recovery
    if (protein > 15) {
      impacts.add(_ImpactItem('+${(protein / 5).toInt()}', 'Muscle recovery', const Color(0xFF10B981)));
    }

    // Headache / migraine risk
    final spicyNames = ['chilli', 'chili', 'spicy', 'wine', 'cheese', 'chocolate', 'processed'];
    if (spicyNames.any((k) => name.contains(k)) || sodium > 500) {
      impacts.add(const _ImpactItem('-8', 'Headache trigger risk', Color(0xFFEF4444)));
    }

    // Digestion stress
    if (fat > 20 || name.contains('fried') || name.contains('oil')) {
      impacts.add(const _ImpactItem('-10', 'Digestion stress', Color(0xFFEF4444)));
    }

    // Gut health
    if (fiber > 3) {
      impacts.add(_ImpactItem('+${(fiber * 1.5).toInt()}', 'Gut health', const Color(0xFF10B981)));
    }

    // Immune support
    if (vitC > 20) {
      impacts.add(const _ImpactItem('+5', 'Immune support', Color(0xFF6366F1)));
    }

    // Bone health
    if (calcium > 100) {
      impacts.add(const _ImpactItem('+4', 'Bone health', Color(0xFF8B5CF6)));
    }

    // Blood sugar spike
    if (sugar > 15) {
      impacts.add(_ImpactItem('-${(sugar / 5).toInt()}', 'Blood sugar spike', const Color(0xFFF59E0B)));
    }

    // Sodium BP
    if (sodium > 600) {
      impacts.add(const _ImpactItem('-6', 'BP elevation risk', Color(0xFFEF4444)));
    }

    if (impacts.isEmpty) {
      impacts.add(const _ImpactItem('+2', 'General energy', Color(0xFF10B981)));
    }

    return impacts;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final impacts = _computeImpacts();
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center_rounded,
                  size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 7),
              Text('Recovery Impact',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: impacts.map((item) => _ImpactChip(item: item, isDark: isDark)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ImpactChip extends StatelessWidget {
  final _ImpactItem item;
  final bool isDark;
  const _ImpactChip({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPositive = item.score.startsWith('+');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.color.withValues(alpha: 0.22), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.score,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: item.color),
          ),
          const SizedBox(width: 5),
          Text(
            item.label,
            style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: item.color,
          ),
        ],
      ),
    );
  }
}

class _ImpactItem {
  final String score;
  final String label;
  final Color color;
  const _ImpactItem(this.score, this.label, this.color);
}
