// Nutrition Diary Screen — AI Nutrition Timeline Dashboard
// Upgraded: PremiumCalorieHero, MealTimelineCards, AiNextMealSuggestions
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

class NutritionDiaryScreen extends ConsumerStatefulWidget {
  const NutritionDiaryScreen({super.key});

  @override
  ConsumerState<NutritionDiaryScreen> createState() =>
      _NutritionDiaryScreenState();
}

class _NutritionDiaryScreenState extends ConsumerState<NutritionDiaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('EEE, MMM d').format(d);
  }

  int _computeAiScore(NutritionDiaryState state) {
    final s = state.summary;
    if (s.caloriesLogged == 0) return 0;
    double score = 60;
    final proteinRatio = s.proteinGoal > 0 ? s.proteinLogged / s.proteinGoal : 0;
    final carbRatio = s.carbsGoal > 0 ? s.carbsLogged / s.carbsGoal : 0;
    final calRatio = s.calorieGoal > 0 ? s.caloriesLogged / s.calorieGoal : 0;
    if (proteinRatio >= 0.7 && proteinRatio <= 1.1) score += 15;
    if (carbRatio >= 0.5 && carbRatio <= 1.1) score += 10;
    if (calRatio >= 0.8 && calRatio <= 1.05) score += 15;
    return score.toInt().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(nutritionDiaryProvider);
    final notifier = ref.read(nutritionDiaryProvider.notifier);
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
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Glass header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.28)
                            : Colors.white.withValues(alpha: 0.55),
                        padding: EdgeInsets.fromLTRB(
                            16,
                            MediaQuery.paddingOf(context).top + 12,
                            16,
                            10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nutrition Diary',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                          letterSpacing: -0.4)),
                                  Text('AI-powered food intelligence',
                                      style: TextStyle(
                                          fontSize: 11, color: textSub)),
                                ],
                              ),
                            ),
                            // History
                            GestureDetector(
                              onTap: () =>
                                  context.push('/nutrition/history'),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.09)
                                      : Colors.white.withValues(alpha: 0.72),
                                  border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : Colors.white,
                                      width: 0.8),
                                ),
                                child: Icon(Icons.table_chart_outlined,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Date navigator ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NavButton(
                          icon: Icons.chevron_left,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.selectDate(state.selectedDate
                                .subtract(const Duration(days: 1)));
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
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 1)),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: AppColors.primary),
                                ),
                                child: child!,
                              ),
                            );
                            if (d != null) notifier.selectDate(d);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.07),
                                  width: 0.7),
                            ),
                            child: Text(
                              _formatDate(state.selectedDate),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _NavButton(
                          icon: Icons.chevron_right,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.selectDate(state.selectedDate
                                .add(const Duration(days: 1)));
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Body ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: state.isLoading
                      ? _buildLoading(isDark)
                      : RefreshIndicator(
                          onRefresh: () async => notifier.refresh(),
                          color: AppColors.primary,
                          displacement: 20,
                          child: SingleChildScrollView(
                            physics:
                                const NeverScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 14, 16, 0),
                              child: Column(
                                children: [
                                  // Calorie hero
                                  PremiumCalorieHero(
                                    summary: state.summary,
                                    aiMealScore:
                                        _computeAiScore(state),
                                  ),
                                  const SizedBox(height: 14),

                                  // Meal timeline cards
                                  ...MealType.values.map((type) =>
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        child: MealTimelineCard(
                                          mealType: type,
                                          entries: state.forMeal(type),
                                          onAddFood: () => context.push(
                                              '/nutrition/search',
                                              extra: type),
                                        ),
                                      )),

                                  // Activity section
                                  if (state.activities.isNotEmpty)
                                    _ActivityCard(
                                        activities: state.activities,
                                        isDark: isDark,
                                        onAdd: () => context.push(
                                            '/nutrition/activity-search')),
                                  if (state.activities.isEmpty)
                                    _AddActivityButton(
                                        isDark: isDark,
                                        onTap: () => context.push(
                                            '/nutrition/activity-search')),

                                  const SizedBox(height: 14),

                                  // AI suggestions
                                  AiNextMealSuggestions(
                                    summary: state.summary,
                                    currentMealType: MealType.dinner,
                                  ),

                                  const SizedBox(height: 110),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ── AI FAB ────────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 100 + MediaQuery.paddingOf(context).bottom,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/nutrition/ai');
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.white, size: 24),
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
        children: List.generate(
          4,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
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
            color: const Color(0xFF10B981).withValues(alpha: 0.22),
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
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.directions_run_rounded,
                      size: 18, color: Color(0xFF10B981)),
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
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981))),
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
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981))),
                  ],
                ),
              )),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 5),
                  Text('Add Activity',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
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
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.22),
                width: 0.7),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_run_rounded,
                  size: 16, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('+ Log Physical Activity',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

