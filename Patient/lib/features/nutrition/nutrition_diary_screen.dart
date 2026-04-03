// Nutrition Diary Screen  ported from OpenNutriTracker HomePage
// Adapted for MedAssist: Riverpod, Supabase data, Date navigation, 4 Meal Lists
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class NutritionDiaryScreen extends ConsumerWidget {
  const NutritionDiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionDiaryProvider);
    final notifier = ref.read(nutritionDiaryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Food Diary', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            onPressed: () => context.push('/nutrition/history'),
          ),
        ],
      ),
      body: Column(
        children: [
          //  Date Navigator 
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => notifier.selectDate(
                      state.selectedDate.subtract(const Duration(days: 1))),
                ),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: state.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (d != null) notifier.selectDate(d);
                  },
                  child: Text(
                    _formatDate(state.selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => notifier.selectDate(
                      state.selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => notifier.refresh(),
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 40),
                      children: [
                        //  Dashboard Ring 
                        _DashboardWidget(summary: state.summary),
                        
                        //  Meal Sections 
                        _MealSection(
                          mealType: MealType.breakfast,
                          entries: state.forMeal(MealType.breakfast),
                        ),
                        _MealSection(
                          mealType: MealType.lunch,
                          entries: state.forMeal(MealType.lunch),
                        ),
                        _MealSection(
                          mealType: MealType.dinner,
                          entries: state.forMeal(MealType.dinner),
                        ),
                        _MealSection(
                          mealType: MealType.snack,
                          entries: state.forMeal(MealType.snack),
                        ),
                        
                        //  Physical Activities 
                        _ActivitySection(
                          activities: state.activities,
                          date: state.selectedDate,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/nutrition/ai'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.psychology, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
      return 'Yesterday';
    }
    return DateFormat('EEE, MMM d, yyyy').format(d);
  }
}

//  Dashboard Ported from `DashboardWidget` 
class _DashboardWidget extends StatelessWidget {
  final DailySummary summary;
  const _DashboardWidget({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Eaten', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    summary.caloriesLogged.toInt().toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              
              // Center Ring
              CircularPercentIndicator(
                radius: 65.0,
                lineWidth: 10.0,
                animation: true,
                percent: summary.calorieProgress,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: AppColors.primary,
                backgroundColor: AppColors.softBlue,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      summary.caloriesRemaining.toInt().toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text('Kcal left', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),

              // Right text
               Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Burned', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    summary.activityBurnLogged.toInt().toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Macros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroBar(
                title: 'Carbs',
                color: AppColors.warning,
                progress: summary.carbsProgress,
                text: '${summary.carbsLogged.toInt()} / ${summary.carbsGoal.toInt()}g',
              ),
              _MacroBar(
                title: 'Fat',
                color: AppColors.danger,
                progress: summary.fatProgress,
                text: '${summary.fatLogged.toInt()} / ${summary.fatGoal.toInt()}g',
              ),
              _MacroBar(
                title: 'Protein',
                color: AppColors.success,
                progress: summary.proteinProgress,
                text: '${summary.proteinLogged.toInt()} / ${summary.proteinGoal.toInt()}g',
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String title;
  final Color color;
  final double progress;
  final String text;

  const _MacroBar({
    required this.title,
    required this.color,
    required this.progress,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        LinearPercentIndicator(
          width: 80,
          lineHeight: 8,
          percent: progress,
          backgroundColor: color.withValues(alpha: 0.15),
          progressColor: color,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
      ],
    );
  }
}

//  Meal Section Ported from `IntakeVerticalList` 
class _MealSection extends ConsumerWidget {
  final MealType mealType;
  final List<IntakeEntry> entries;

  const _MealSection({required this.mealType, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalKcal = entries.fold(0.0, (sum, e) => sum + e.totalKcal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(mealType.icon, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(mealType.label,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                Text('${totalKcal.toInt()} kcal',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          
          // Items
          if (entries.isNotEmpty)
            ...entries.map((e) => Dismissible(
                  key: Key(e.id ?? e.hashCode.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.danger,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    if (e.id != null) {
                      ref.read(nutritionDiaryProvider.notifier).deleteEntry(e.id!);
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(e.meal.name ?? 'Food',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text('${e.amountG.toInt()} ${e.unit}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: Text('${e.totalKcal.toInt()} kcal',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                )),
          
          // Add Button
          InkWell(
            onTap: () => context.push('/nutrition/search', extra: mealType),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
              ),
              child: const Center(
                child: Text('+ Add Food',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//  Physical Activity Section 
class _ActivitySection extends StatelessWidget {
  final List<dynamic> activities; // Type matches ActivityEntry
  final DateTime date;

  const _ActivitySection({required this.activities, required this.date});

  @override
  Widget build(BuildContext context) {
    final totalBurn = activities.fold(0.0, (sum, e) => sum + e.caloriesBurned);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_run, size: 18, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Physical Activity',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                Text('${totalBurn.toInt()} kcal',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
              ],
            ),
          ),
          
          // Items
          if (activities.isNotEmpty)
            ...activities.map((a) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(a.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text('${a.durationMin.toInt()} minutes',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Text('${a.caloriesBurned.toInt()} kcal',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.success)),
                )),
          
          // Add Button
          InkWell(
            onTap: () => context.push('/nutrition/activity-search'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
              ),
              child: const Center(
                child: Text('+ Add Activity',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

