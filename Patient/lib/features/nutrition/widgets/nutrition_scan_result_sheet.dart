import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/intake_entry.dart';
import '../models/meal_entity.dart';
import 'ai_food_safety_banner.dart';
import 'recovery_impact_card.dart';

/// Glass bottom sheet shown after a food scan / recognition result.
class NutritionScanResultSheet extends StatelessWidget {
  final MealEntity meal;
  final double confidence;
  final MealType initialMealType;
  final VoidCallback? onAddToMeal;

  const NutritionScanResultSheet({
    super.key,
    required this.meal,
    this.confidence = 0.90,
    this.initialMealType = MealType.lunch,
    this.onAddToMeal,
  });

  static void show(
    BuildContext context, {
    required MealEntity meal,
    double confidence = 0.90,
    MealType initialMealType = MealType.lunch,
    VoidCallback? onAddToMeal,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NutritionScanResultSheet(
        meal: meal,
        confidence: confidence,
        initialMealType: initialMealType,
        onAddToMeal: onAddToMeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final n = meal.nutriments;
    final kcal = n.energyKcal100 ?? 0;
    final carbs = n.carbohydrates100 ?? 0;
    final fat = n.fat100 ?? 0;
    final protein = n.proteins100 ?? 0;
    final sodium = (n.sodium100 ?? 0) * 1000;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;
    final pct = (confidence * 100).toInt();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.22), blurRadius: 40),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.60)
                  : Colors.white.withValues(alpha: 0.86),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38, height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.18)
                          : Colors.black.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                      children: [
                        // ── Header ───────────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text('AI Detected', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('$pct% confidence',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF10B981),
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    meal.name ?? 'Unknown Food',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                        letterSpacing: -0.4),
                                  ),
                                  if (meal.brands != null)
                                    Text(meal.brands!,
                                        style: TextStyle(fontSize: 12, color: textSub)),
                                ],
                              ),
                            ),
                            // Kcal badge
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    width: 0.8),
                              ),
                              child: Column(
                                children: [
                                  Text('${kcal.toInt()}',
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary)),
                                  Text('kcal/100g',
                                      style: TextStyle(fontSize: 9, color: textSub)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Macro row ────────────────────────────────────
                        GlassCard(
                          radius: 16, blur: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MacroCell('Carbs', '${carbs.toStringAsFixed(1)}g', const Color(0xFFF59E0B), isDark),
                              _Divider(isDark),
                              _MacroCell('Protein', '${protein.toStringAsFixed(1)}g', const Color(0xFF10B981), isDark),
                              _Divider(isDark),
                              _MacroCell('Fat', '${fat.toStringAsFixed(1)}g', const Color(0xFFEF4444), isDark),
                              _Divider(isDark),
                              _MacroCell('Sodium', '${sodium.toInt()}mg', const Color(0xFF8B5CF6), isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── AI Safety Banner ─────────────────────────────
                        AiFoodSafetyBanner(meal: meal, amountG: 100),
                        const SizedBox(height: 12),

                        // ── Recovery Impact ──────────────────────────────
                        RecoveryImpactCard(meal: meal, amountG: 100),
                        const SizedBox(height: 16),

                        // ── Add CTA ──────────────────────────────────────
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            context.push('/nutrition/detail', extra: {
                              'meal': meal,
                              'mealType': initialMealType,
                            });
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF2A7FFF), Color(0xFF6366F1)]),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_rounded,
                                    size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Add to ${initialMealType.label}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Center(
                            child: Text('Dismiss',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: textSub,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _MacroCell(this.label, this.value, this.color, this.isDark);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : AppColors.textSecondary)),
        ],
      );
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider(this.isDark);
  @override
  Widget build(BuildContext context) => Container(
        width: 0.5,
        height: 32,
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.07),
      );
}
