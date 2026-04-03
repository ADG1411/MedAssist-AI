// Food Detail Screen — AI Food Intelligence Hub
// Upgraded: SmartPortionSelector, AiFoodSafetyBanner, RecoveryImpactCard, MacroDonut
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';
import 'widgets/ai_food_safety_banner.dart';
import 'widgets/recovery_impact_card.dart';
import 'widgets/smart_portion_selector.dart';
import 'widgets/macro_donut_widget.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  final MealEntity meal;
  final MealType? initialMealType;

  const FoodDetailScreen({
    super.key,
    required this.meal,
    this.initialMealType,
  });

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen>
    with SingleTickerProviderStateMixin {
  late double _amountG;
  late MealType _selectedMealType;
  bool _isAdding = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _amountG = widget.meal.servingQuantity ?? 100.0;
    _selectedMealType = widget.initialMealType ?? MealType.lunch;
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  double get _kcal =>
      _amountG * (widget.meal.nutriments.energyPerUnit ?? 0);
  double get _carbs =>
      _amountG * (widget.meal.nutriments.carbohydratesPerUnit ?? 0);
  double get _fat =>
      _amountG * (widget.meal.nutriments.fatPerUnit ?? 0);
  double get _protein =>
      _amountG * (widget.meal.nutriments.proteinsPerUnit ?? 0);
  double get _fiber =>
      _amountG * ((widget.meal.nutriments.fiber100 ?? 0) / 100);

  Future<void> _addToDiary() async {
    HapticFeedback.lightImpact();
    setState(() => _isAdding = true);
    await ref.read(nutritionDiaryProvider.notifier).logFood(
      meal: widget.meal,
      mealType: _selectedMealType,
      amountG: _amountG,
      unit: 'g',
    );
    setState(() => _isAdding = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Added ${widget.meal.name} to ${_selectedMealType.label}'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meal = widget.meal;
    final mealColor = _selectedMealType.color;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                // ── Hero image + back ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Food image
                        if (meal.mainImageUrl != null)
                          CachedNetworkImage(
                            imageUrl: meal.mainImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                _FoodHeroPlaceholder(color: mealColor),
                            errorWidget: (_, __, ___) =>
                                _FoodHeroPlaceholder(color: mealColor),
                          )
                        else
                          _FoodHeroPlaceholder(color: mealColor),
                        // Gradient overlay
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                        // Back button
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 8,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.35),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 0.7),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 14,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        // AI badge
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 8,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6)
                              ]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    size: 10, color: Colors.white),
                                SizedBox(width: 4),
                                Text('AI Intelligence',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                        // Food name overlay
                        Positioned(
                          left: 16, right: 16, bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name ?? 'Unknown Food',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    shadows: [
                                      Shadow(blurRadius: 8,
                                          color: Colors.black54)
                                    ]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (meal.brands != null)
                                Text(meal.brands!,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Content ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source + category badges
                        Row(
                          children: [
                            _SourceBadge(meal.source),
                            if (meal.category != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.07)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(meal.category!,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: textSub,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Macro donut + kcal hero ───────────────────────
                        GlassCard(
                          radius: 22,
                          blur: 18,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              MacroDonutWidget(
                                carbs: _carbs,
                                fat: _fat,
                                protein: _protein,
                                fiber: _fiber,
                                size: 110,
                                strokeWidth: 11,
                                center: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_kcal.toInt()}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: textPrimary),
                                    ),
                                    Text('kcal',
                                        style: TextStyle(
                                            fontSize: 9, color: textSub)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _MacroRow('Carbs', _carbs,
                                        const Color(0xFFF59E0B), isDark),
                                    _MacroRow('Protein', _protein,
                                        const Color(0xFF10B981), isDark),
                                    _MacroRow('Fat', _fat,
                                        const Color(0xFFEF4444), isDark),
                                    if (_fiber > 0)
                                      _MacroRow('Fiber', _fiber,
                                          const Color(0xFF6366F1), isDark),
                                    const SizedBox(height: 4),
                                    Text(
                                      'per ${_amountG.toInt()}g',
                                      style: TextStyle(
                                          fontSize: 10, color: textSub),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Smart portion selector ────────────────────────
                        SmartPortionSelector(
                          meal: meal,
                          initialAmountG: _amountG,
                          onChanged: (v) => setState(() => _amountG = v),
                        ),
                        const SizedBox(height: 14),

                        // ── Meal type selector ────────────────────────────
                        GlassCard(
                          radius: 18,
                          blur: 14,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.restaurant_menu_rounded,
                                      size: 15,
                                      color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text('Add to Meal',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: MealType.values.map((t) {
                                  final sel = t == _selectedMealType;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedMealType = t);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 160),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: sel
                                            ? t.color
                                            : (isDark
                                                ? Colors.white.withValues(alpha: 0.06)
                                                : Colors.white.withValues(alpha: 0.70)),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: sel
                                                ? t.color
                                                : (isDark
                                                    ? Colors.white.withValues(alpha: 0.10)
                                                    : Colors.black.withValues(alpha: 0.07)),
                                            width: 0.7),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(t.emoji,
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                          const SizedBox(width: 4),
                                          Text(t.label,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: sel
                                                      ? Colors.white
                                                      : textPrimary)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── AI Safety Banner ──────────────────────────────
                        _SectionLabel('🛡️ AI Safety Check', textPrimary),
                        const SizedBox(height: 8),
                        AiFoodSafetyBanner(meal: meal, amountG: _amountG),
                        const SizedBox(height: 14),

                        // ── Recovery Impact ───────────────────────────────
                        RecoveryImpactCard(meal: meal, amountG: _amountG),
                        const SizedBox(height: 14),

                        // ── Full nutrition table ──────────────────────────
                        _SectionLabel('📊 Nutrition Facts', textPrimary),
                        const SizedBox(height: 8),
                        _NutritionTable(meal: meal, amountG: _amountG,
                            isDark: isDark),

                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky Add CTA ────────────────────────────────────────────
          Positioned(
            left: 0, right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.50)
                      : Colors.white.withValues(alpha: 0.72),
                  padding: EdgeInsets.fromLTRB(
                      16, 12, 16,
                      16 + MediaQuery.paddingOf(context).bottom),
                  child: GestureDetector(
                    onTap: _isAdding ? null : _addToDiary,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: _isAdding
                            ? null
                            : LinearGradient(colors: [
                                mealColor,
                                mealColor.withValues(alpha: 0.75),
                              ]),
                        color: _isAdding ? Colors.grey : null,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: _isAdding
                            ? null
                            : [
                                BoxShadow(
                                    color: mealColor.withValues(alpha: 0.40),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4)),
                              ],
                      ),
                      child: _isAdding
                          ? const Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_selectedMealType.emoji,
                                    style:
                                        const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'Add ${_amountG.toInt()}g · ${_kcal.toInt()} kcal → ${_selectedMealType.label}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: color));
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isDark;
  const _MacroRow(this.label, this.value, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, color: textSub)),
          const Spacer(),
          Text('${value.toStringAsFixed(1)}g',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final MealSource source;
  const _SourceBadge(this.source);

  String get label {
    switch (source) {
      case MealSource.indian: return '🇮🇳 IFCT';
      case MealSource.off:    return '🌍 OpenFoodFacts';
      case MealSource.fdc:    return '🇺🇸 USDA FDC';
      default:                return '📝 Custom';
    }
  }

  Color get color {
    switch (source) {
      case MealSource.indian: return const Color(0xFFF97316);
      case MealSource.off:    return const Color(0xFF10B981);
      case MealSource.fdc:    return AppColors.primary;
      default:                return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.7),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700)),
      );
}

class _FoodHeroPlaceholder extends StatelessWidget {
  final Color color;
  const _FoodHeroPlaceholder({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.10)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.restaurant_rounded, size: 72,
              color: color.withValues(alpha: 0.50)),
        ),
      );
}

class _NutritionTable extends StatelessWidget {
  final MealEntity meal;
  final double amountG;
  final bool isDark;

  const _NutritionTable(
      {required this.meal, required this.amountG, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final n = meal.nutriments;
    double? factor(double? per100) =>
        per100 != null ? amountG * per100 / 100 : null;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);

    return GlassCard(
      radius: 18, blur: 14, padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text('Nutrition Facts per ${amountG.toInt()}g',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: textPrimary)),
          ),
          Divider(height: 1, color: divColor),
          _Row('Calories', factor(n.energyKcal100), 'kcal',
              bold: true, color: AppColors.primary, isDark: isDark),
          Divider(height: 0.5, indent: 14, color: divColor),
          _Row('Carbohydrates', factor(n.carbohydrates100), 'g',
              color: const Color(0xFFF59E0B), isDark: isDark),
          _Row('  ↳ Sugars', factor(n.sugars100), 'g',
              indent: true, isDark: isDark),
          Divider(height: 0.5, indent: 14, color: divColor),
          _Row('Fat', factor(n.fat100), 'g',
              color: const Color(0xFFEF4444), isDark: isDark),
          _Row('  ↳ Saturated Fat', factor(n.saturatedFat100), 'g',
              indent: true, isDark: isDark),
          Divider(height: 0.5, indent: 14, color: divColor),
          _Row('Protein', factor(n.proteins100), 'g',
              color: const Color(0xFF10B981), isDark: isDark),
          _Row('Fiber', factor(n.fiber100), 'g',
              color: const Color(0xFF6366F1), isDark: isDark),
          if (n.sodium100 != null) ...[
            Divider(height: 0.5, indent: 14, color: divColor),
            _Row('Sodium', factor(n.sodium100 != null
                ? n.sodium100! * 1000 : null), 'mg',
                color: const Color(0xFF8B5CF6), isDark: isDark),
          ],
          if (n.calcium100 != null)
            _Row('Calcium', factor(n.calcium100), 'mg', isDark: isDark),
          if (n.iron100 != null)
            _Row('Iron', factor(n.iron100), 'mg', isDark: isDark),
          if (n.vitaminC100 != null)
            _Row('Vitamin C', factor(n.vitaminC100), 'mg', isDark: isDark),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final bool bold;
  final bool indent;
  final Color? color;
  final bool isDark;

  const _Row(this.label, this.value, this.unit,
      {this.bold = false, this.indent = false, this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.textSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: indent ? 22 : 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: indent ? textSub : textPrimary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(
            value != null
                ? '${value!.toStringAsFixed(1)} $unit'
                : '– $unit',
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? textPrimary),
          ),
        ],
      ),
    );
  }
}

