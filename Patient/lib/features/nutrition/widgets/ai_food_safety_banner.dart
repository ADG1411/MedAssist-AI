import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/meal_entity.dart';
import '../models/meal_nutriments.dart';

/// Disease-aware AI safety banner shown on food detail / scan result.
class AiFoodSafetyBanner extends StatelessWidget {
  final MealEntity meal;
  final double amountG;

  const AiFoodSafetyBanner({
    super.key,
    required this.meal,
    this.amountG = 100,
  });

  List<_SafetyWarning> _computeWarnings(MealNutriments n, double amount) {
    final warnings = <_SafetyWarning>[];
    final factor = amount / 100;

    final sodiumMg = (n.sodium100 ?? 0) * factor * 1000;
    final sugarG   = (n.sugars100 ?? 0) * factor;
    final satFatG  = (n.saturatedFat100 ?? 0) * factor;
    final carbsG   = (n.carbohydrates100 ?? 0) * factor;
    final name     = meal.name?.toLowerCase() ?? '';

    // Sodium
    if (sodiumMg > 600) {
      warnings.add(_SafetyWarning(
        icon: Icons.warning_rounded,
        color: const Color(0xFFEF4444),
        condition: 'Hypertension Risk',
        message: 'High sodium (${sodiumMg.toInt()}mg) may elevate blood pressure.',
      ));
    }

    // Sugar
    if (sugarG > 20) {
      warnings.add(_SafetyWarning(
        icon: Icons.bloodtype_rounded,
        color: const Color(0xFFF59E0B),
        condition: 'Diabetes Risk',
        message: 'High sugar (${sugarG.toInt()}g) may spike blood glucose.',
      ));
    }

    // Spicy / irritant foods
    final spicyKeywords = ['spicy', 'chilli', 'chili', 'masala', 'maggi',
        'noodle', 'peri peri', 'schezwan', 'pickle'];
    if (spicyKeywords.any((k) => name.contains(k))) {
      warnings.add(const _SafetyWarning(
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFEF4444),
        condition: 'Gastritis Risk',
        message: 'Spicy/processed food may worsen gastritis and acid reflux.',
      ));
    }

    // Saturated fat
    if (satFatG > 8) {
      warnings.add(_SafetyWarning(
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFFEF4444),
        condition: 'Heart Risk',
        message: 'High saturated fat (${satFatG.toStringAsFixed(1)}g) may affect cholesterol.',
      ));
    }

    // High carbs for diabetics
    if (carbsG > 60) {
      warnings.add(_SafetyWarning(
        icon: Icons.show_chart_rounded,
        color: const Color(0xFFF59E0B),
        condition: 'Glycemic Load',
        message: 'High carbs (${carbsG.toInt()}g) — monitor glucose if diabetic.',
      ));
    }

    // Kidney-related (high protein + sodium)
    final proteinG = (n.proteins100 ?? 0) * factor;
    if (proteinG > 30 && sodiumMg > 400) {
      warnings.add(const _SafetyWarning(
        icon: Icons.science_rounded,
        color: Color(0xFF8B5CF6),
        condition: 'Kidney Load',
        message: 'High protein + sodium may increase kidney filtration demand.',
      ));
    }

    return warnings;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warnings = _computeWarnings(meal.nutriments, amountG);

    if (warnings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.25),
              width: 0.7),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 16, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'AI Safety Check: No major dietary concerns detected for this food.',
                style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark ? Colors.white : AppColors.textPrimary,
                    height: 1.3),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: warnings
          .map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _WarningTile(warning: w, isDark: isDark),
              ))
          .toList(),
    );
  }
}

class _WarningTile extends StatelessWidget {
  final _SafetyWarning warning;
  final bool isDark;
  const _WarningTile({required this.warning, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: warning.color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: warning.color.withValues(alpha: 0.25), width: 0.7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(warning.icon, size: 16, color: warning.color),
            const SizedBox(width: 9),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(warning.condition,
                      style: TextStyle(
                          fontSize: 11,
                          color: warning.color,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(warning.message,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white : AppColors.textPrimary,
                          height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SafetyWarning {
  final IconData icon;
  final Color color;
  final String condition;
  final String message;
  const _SafetyWarning({
    required this.icon,
    required this.color,
    required this.condition,
    required this.message,
  });
}
