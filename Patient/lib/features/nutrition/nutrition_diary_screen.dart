// Nutrition Diary Screen — Clean Blue Theme
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';
import 'widgets/premium_calorie_hero.dart';
import 'widgets/meal_timeline_card.dart';
import 'widgets/ai_next_meal_suggestions.dart';

class NutritionDiaryScreen extends ConsumerWidget {
  const NutritionDiaryScreen({super.key});

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
    final y = now.subtract(const Duration(days: 1));
    if (d.year == y.year && d.month == y.month && d.day == y.day) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(d);
  }

  int _computeAiScore(NutritionDiaryState state) {
    final s = state.summary;
    if (s.caloriesLogged == 0) return 0;
    double score = 60;
    final pR = s.proteinGoal > 0 ? s.proteinLogged / s.proteinGoal : 0;
    final cR = s.carbsGoal > 0 ? s.carbsLogged / s.carbsGoal : 0;
    final kR = s.calorieGoal > 0 ? s.caloriesLogged / s.calorieGoal : 0;
    if (pR >= 0.7 && pR <= 1.1) score += 15;
    if (cR >= 0.5 && cR <= 1.1) score += 10;
    if (kR >= 0.8 && kR <= 1.05) score += 15;
    return score.toInt().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(nutritionDiaryProvider);
    final notifier = ref.read(nutritionDiaryProvider.notifier);
    final tp = isDark ? Colors.white : AppColors.textPrimary;
    final ts = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, const Color(0xFF2563EB)]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.restaurant_rounded, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nutrition Diary', style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: tp, letterSpacing: -0.5)),
                              Text('AI-powered food intelligence',
                                style: TextStyle(fontSize: 11, color: ts)),
                            ],
                          ),
                        ),
                        // History button
                        GestureDetector(
                          onTap: () => context.push('/nutrition/history'),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.72),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06),
                                width: 0.6),
                            ),
                            child: Icon(Icons.table_chart_outlined, size: 16, color: tp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Date navigator ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NavButton(
                          icon: Icons.chevron_left,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.selectDate(state.selectedDate.subtract(const Duration(days: 1)));
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: state.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                                child: child!,
                              ),
                            );
                            if (d != null) notifier.selectDate(d);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06),
                                width: 0.6),
                            ),
                            child: Text(_formatDate(state.selectedDate),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tp)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _NavButton(
                          icon: Icons.chevron_right,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.selectDate(state.selectedDate.add(const Duration(days: 1)));
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Body ────────────────────────────────────────────
                if (state.isLoading)
                  SliverToBoxAdapter(child: _buildLoading(isDark))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Calorie hero
                        PremiumCalorieHero(
                          summary: state.summary,
                          aiMealScore: _computeAiScore(state),
                        ),
                        const SizedBox(height: 10),

                        // Meal timeline cards
                        ...MealType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MealTimelineCard(
                            mealType: type,
                            entries: state.forMeal(type),
                            onAddFood: () => context.push('/nutrition/search', extra: type),
                          ),
                        )),

                        // Activity section
                        if (state.activities.isNotEmpty)
                          _ActivityCard(
                            activities: state.activities,
                            isDark: isDark,
                            onAdd: () => context.push('/nutrition/activity-search')),
                        if (state.activities.isEmpty)
                          _AddActivityButton(
                            isDark: isDark,
                            onTap: () => context.push('/nutrition/activity-search')),

                        const SizedBox(height: 10),

                        // AI suggestions
                        AiNextMealSuggestions(
                          summary: state.summary,
                          currentMealType: MealType.dinner,
                        ),

                        const SizedBox(height: 90),
                      ]),
                    ),
                  ),
              ],
            ),
          ),

          // ── AI FAB ────────────────────────────────────────────
          Positioned(
            right: 18,
            bottom: (MediaQuery.paddingOf(context).bottom == 0 ? 14.0 : MediaQuery.paddingOf(context).bottom) + 74,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/nutrition/ai');
              },
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, const Color(0xFF2563EB)]),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(4, (i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 110,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(18),
          ),
        )),
      ),
    );
  }
}

// ── Nav arrow button ──────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _NavButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.72),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.07),
                width: 0.7),
          ),
          child: Icon(icon,
              size: 18,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
      );
}

// ── Activity card ─────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final List<dynamic> activities;
  final bool isDark;
  final VoidCallback onAdd;
  const _ActivityCard({
    required this.activities,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final totalBurn =
        activities.fold<double>(0, (sum, e) => sum + (e.caloriesBurned as num).toDouble());
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.18),
            width: 0.7),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(Icons.directions_run_rounded,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Physical Activity',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary)),
                ),
                Text('${totalBurn.toInt()} kcal burned',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          ),
          ...activities.map((a) => Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(a.name.toString(),
                          style: TextStyle(fontSize: 12, color: textPrimary)),
                    ),
                    Text('${(a.durationMin as num).toInt()} min',
                        style: TextStyle(fontSize: 11, color: textSub)),
                    const SizedBox(width: 8),
                    Text('${(a.caloriesBurned as num).toInt()} kcal',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
              )),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text('Add Activity',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddActivityButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _AddActivityButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 0.7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_run_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('+ Log Physical Activity',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

