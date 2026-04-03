import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_history_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class NutritionHistoryScreen extends ConsumerStatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  ConsumerState<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends ConsumerState<NutritionHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History & Trends'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (s, f) {
                    setState(() {
                      _selectedDay = s;
                      _focusedDay = f;
                    });
                  },
                  onPageChanged: (f) {
                    _focusedDay = f;
                    ref.read(nutritionHistoryProvider.notifier).changeMonth(f);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, state),
                    selectedBuilder: (context, day, focusedDay) => Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildDayCell(day, state),
                    ),
                    todayBuilder: (context, day, focusedDay) => Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildDayCell(day, state),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          if (_selectedDay != null) ...[
            SliverToBoxAdapter(
              child: _buildDayDetails(
                _selectedDay!, 
                state.summaries[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)],
              ),
            ),
          ],
          
          SliverToBoxAdapter(
            child: _buildWeeklyChart(state),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, NutritionHistoryState state) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final summary = state.summaries[normalizedDay];
    
    Color boxColor = Colors.transparent;
    if (summary != null && summary.caloriesLogged > 0) {
      final progress = summary.calorieProgress;
      if (progress < 0.6) {
        boxColor = AppColors.warning.withValues(alpha: 0.3);
      } else if (progress <= 1.05) {
        boxColor = AppColors.success.withValues(alpha: 0.5);
      } else {
        boxColor = AppColors.danger.withValues(alpha: 0.5);
      }
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: summary != null && summary.caloriesLogged > 0 ? Colors.black87 : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDayDetails(DateTime date, dynamic summary) {
    if (summary == null || summary.caloriesLogged == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text('No food logged on ${DateFormat('MMM d, yyyy').format(date)}',
            style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, MMMM d').format(date), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(label: 'Calories', value: '${summary.caloriesLogged.toInt()} kcal', color: AppColors.primary),
              _Stat(label: 'Carbs', value: '${summary.carbsLogged.toInt()}g', color: AppColors.warning),
              _Stat(label: 'Fat', value: '${summary.fatLogged.toInt()}g', color: AppColors.danger),
              _Stat(label: 'Protein', value: '${summary.proteinLogged.toInt()}g', color: AppColors.success),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(NutritionHistoryState state) {
    if (state.summaries.isEmpty) return const SizedBox();

    // Get last 7 days of data
    final now = DateTime.now();
    final spots = <BarChartGroupData>[];
    double maxVal = 2500;

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final norm = DateTime(d.year, d.month, d.day);
      final kcal = state.summaries[norm]?.caloriesLogged ?? 0.0;
      if (kcal > maxVal) maxVal = kcal + 500;

      spots.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: kcal,
              color: AppColors.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ]
        )
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last 7 Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        final d = now.subtract(Duration(days: 6 - v.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(DateFormat('E').format(d).substring(0, 1), 
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, meta) => Text(v.toInt().toString(), 
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    )
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 500),
                barGroups: spots,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

