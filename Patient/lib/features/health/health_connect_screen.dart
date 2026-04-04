import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/services/health_sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_card.dart';
import 'providers/health_data_provider.dart';
import 'providers/health_history_provider.dart';
import 'widgets/health_activity_card.dart';
import 'widgets/neumorphic_health_score.dart';
import 'widgets/weekly_chart_card.dart';
import 'widgets/workout_log_card.dart';
import 'widgets/water_intake_logger.dart';
import 'widgets/ai_health_insight_card.dart';

class HealthConnectScreen extends ConsumerStatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  ConsumerState<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends ConsumerState<HealthConnectScreen> {
  bool _isSyncing = false;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _aiResult;

  @override
  void initState() {
    super.initState();
    _loadLatestInsight();
  }

  Future<void> _loadLatestInsight() async {
    final insight = await HealthSyncService.getLatestInsight();
    if (mounted && insight != null) {
      setState(() {
        _aiResult = {
          'overall_assessment': insight['ai_insight'],
          'risk_flags': (insight['ai_risk_flags'] as List?)?.cast<String>() ?? [],
        };
      });
    }
  }

  Future<void> _syncAndAnalyze() async {
    final metrics = ref.read(healthDataProvider).whenOrNull(data: (m) => m);
    if (metrics == null || !metrics.permissionGranted) return;

    setState(() => _isSyncing = true);
    await HealthSyncService.syncToCloud(metrics);
    setState(() {
      _isSyncing = false;
      _isAnalyzing = true;
    });

    final result = await HealthSyncService.analyzeHealthTrends();
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        if (result != null) _aiResult = result;
      });
    }
  }

  String _fmtNum(num n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncMetrics = ref.watch(healthDataProvider);
    final asyncHistory = ref.watch(healthHistoryProvider);

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
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: isDark ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health Connect',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Real-time body metrics & AI insights',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _isSyncing ? null : _syncAndAnalyze,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _isSyncing
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  )
                                : const Icon(Icons.sync_rounded,
                                    size: 18, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: asyncMetrics.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => _buildError(context, isDark),
                      data: (metrics) => _buildContent(context, metrics, asyncHistory, isDark),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, bool isDark) {
    return GlassCard(
      radius: 20,
      blur: 14,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.health_and_safety_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Connect Health Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Grant access to Health Connect to see your vitals, activity, and AI insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.read(healthDataProvider.notifier).refresh(),
            child: const Text('Connect Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    HealthMetrics m,
    AsyncValue<HealthHistory> asyncHistory,
    bool isDark,
  ) {
    if (!m.permissionGranted) return _buildError(context, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Health Intelligence
        AiHealthInsightCard(
          overallAssessment: _aiResult?['overall_assessment'] as String?,
          riskFlags: (_aiResult?['risk_flags'] as List?)?.cast<String>() ?? [],
          recommendations: (_aiResult?['recommendations'] as List?)?.cast<String>() ?? [],
          trendDirection: _aiResult?['trend_direction'] as String? ?? 'stable',
          priorityMetric: _aiResult?['priority_metric'] as String?,
          isLoading: _isAnalyzing,
          onAnalyze: _syncAndAnalyze,
        ),
        const SizedBox(height: 20),

        // Section: Today's Vitals
        _sectionLabel('Today\'s Vitals', Icons.monitor_heart_rounded, isDark),
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            HealthActivityCard(
              label: 'Steps', value: _fmtNum(m.steps), unit: 'steps',
              icon: Icons.directions_walk_rounded, color: const Color(0xFF6366F1),
              hasData: m.steps > 0,
            ),
            HealthActivityCard(
              label: 'Heart Rate', value: m.heartRate > 0 ? '${m.heartRate.toInt()}' : '--', unit: 'bpm',
              icon: Icons.favorite_rounded, color: const Color(0xFFEF4444),
              hasData: m.heartRate > 0,
            ),
            HealthActivityCard(
              label: 'Sleep', value: m.sleepHours > 0 ? m.sleepHours.toStringAsFixed(1) : '--', unit: 'hrs',
              icon: Icons.nightlight_round, color: const Color(0xFF8B5CF6),
              hasData: m.sleepHours > 0,
            ),
            HealthActivityCard(
              label: 'Calories', value: '${m.caloriesBurned.toInt()}', unit: 'kcal',
              icon: Icons.local_fire_department_rounded, color: const Color(0xFFF59E0B),
              hasData: m.caloriesBurned > 0,
            ),
            HealthActivityCard(
              label: 'SpO₂', value: m.bloodOxygen > 0 ? '${m.bloodOxygen.toInt()}' : '--', unit: '%',
              icon: Icons.air_rounded, color: const Color(0xFF06B6D4),
              hasData: m.bloodOxygen > 0,
            ),
            HealthActivityCard(
              label: 'Distance', value: m.distanceKm > 0 ? m.distanceKm.toStringAsFixed(1) : '--', unit: 'km',
              icon: Icons.place_rounded, color: const Color(0xFF10B981),
              hasData: m.distanceMeters > 0,
            ),
            HealthActivityCard(
              label: 'BP',
              value: m.bpSystolic > 0 ? '${m.bpSystolic.toInt()}/${m.bpDiastolic.toInt()}' : '--',
              unit: 'mmHg',
              icon: Icons.speed_rounded, color: const Color(0xFFEC4899),
              hasData: m.bpSystolic > 0,
            ),
            HealthActivityCard(
              label: 'Glucose', value: m.bloodGlucose > 0 ? '${m.bloodGlucose.toInt()}' : '--', unit: 'mg/dL',
              icon: Icons.bloodtype_rounded, color: const Color(0xFFD946EF),
              hasData: m.bloodGlucose > 0,
            ),
            HealthActivityCard(
              label: 'Weight', value: m.weight > 0 ? m.weight.toStringAsFixed(1) : '--', unit: 'kg',
              icon: Icons.monitor_weight_rounded, color: const Color(0xFF14B8A6),
              hasData: m.weight > 0,
            ),
            HealthActivityCard(
              label: 'Temp', value: m.bodyTemperature > 0 ? m.bodyTemperature.toStringAsFixed(1) : '--', unit: '°C',
              icon: Icons.thermostat_rounded, color: const Color(0xFFFF6B6B),
              hasData: m.bodyTemperature > 0,
            ),
            HealthActivityCard(
              label: 'Resp Rate', value: m.respiratoryRate > 0 ? '${m.respiratoryRate.toInt()}' : '--', unit: 'bpm',
              icon: Icons.waves_rounded, color: const Color(0xFF0EA5E9),
              hasData: m.respiratoryRate > 0,
            ),
            HealthActivityCard(
              label: 'Body Fat', value: m.bodyFatPct > 0 ? m.bodyFatPct.toStringAsFixed(1) : '--', unit: '%',
              icon: Icons.pie_chart_rounded, color: const Color(0xFFA855F7),
              hasData: m.bodyFatPct > 0,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Section: Hydration
        WaterIntakeLogger(currentCups: m.waterCups),
        const SizedBox(height: 20),

        // Section: Workouts
        _sectionLabel('Activity', Icons.fitness_center_rounded, isDark),
        const SizedBox(height: 10),
        WorkoutLogCard(workouts: m.workouts),
        const SizedBox(height: 20),

        // Section: Weekly Trends (Charts)
        _sectionLabel('Weekly Trends', Icons.bar_chart_rounded, isDark),
        const SizedBox(height: 10),
        asyncHistory.when(
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(strokeWidth: 2),
          )),
          error: (_, __) => const SizedBox.shrink(),
          data: (history) {
            if (history.dailyData.isEmpty) {
              return GlassCard(
                radius: 18,
                blur: 14,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No historical data yet. Keep tracking!',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                  ),
                ),
              );
            }

            final dayLabels = history.dailyData.map((d) => DateFormat('E').format(d.date).substring(0, 2)).toList();

            return Column(
              children: [
                WeeklyChartCard(
                  title: 'Steps',
                  data: history.dailyData.map((d) => d.steps.toDouble()).toList(),
                  dayLabels: dayLabels,
                  color: const Color(0xFF6366F1),
                  unit: 'steps',
                  icon: Icons.directions_walk_rounded,
                ),
                const SizedBox(height: 12),
                WeeklyChartCard(
                  title: 'Sleep',
                  data: history.dailyData.map((d) => d.sleepHours).toList(),
                  dayLabels: dayLabels,
                  color: const Color(0xFF8B5CF6),
                  unit: 'hrs',
                  icon: Icons.nightlight_round,
                ),
                const SizedBox(height: 12),
                WeeklyChartCard(
                  title: 'Heart Rate',
                  data: history.dailyData.map((d) => d.heartRate).toList(),
                  dayLabels: dayLabels,
                  color: const Color(0xFFEF4444),
                  unit: 'bpm',
                  icon: Icons.favorite_rounded,
                ),
                const SizedBox(height: 12),
                WeeklyChartCard(
                  title: 'Calories',
                  data: history.dailyData.map((d) => d.calories).toList(),
                  dayLabels: dayLabels,
                  color: const Color(0xFFF59E0B),
                  unit: 'kcal',
                  icon: Icons.local_fire_department_rounded,
                ),
              ],
            );
          },
        ),

        // Health Score — Premium Neumorphic Card
        const SizedBox(height: 20),
        NeumorphicHealthScoreCard(
          score: m.computedScore,
          label: 'Health Score',
          subtitle: 'Computed from your real Health Connect data',
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: AppColors.primary, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Score colors are now handled internally by NeumorphicHealthScoreCard
}
