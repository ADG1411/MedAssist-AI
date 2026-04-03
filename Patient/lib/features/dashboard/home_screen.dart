import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/premium_health_score_hero.dart';
import 'widgets/alert_strip_card.dart';
import 'widgets/quick_action_pod.dart';
import 'widgets/ai_insight_card.dart';
import 'widgets/vitals_stat_pill.dart';
import 'widgets/recovery_story_card.dart';
import 'widgets/care_plan_checklist.dart';
import 'widgets/real_health_metrics_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncDashboard = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider) ?? {};
    final userName = user['name']?.toString().split(' ').first ?? 'Guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _DashboardBackground(isDark: isDark),
          RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        color: AppColors.primary,
        child: ScrollConfiguration(
          behavior: const _NoScrollbarBehavior(),
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, userName, isDark),
                        const SizedBox(height: 24),
                        asyncDashboard.when(
                          loading: () => _buildLoading(),
                          error: (e, _) => _buildError(),
                          data: (data) => _buildDashboard(context, data, isDark),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, bool isDark) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_getGreeting()}, $userName 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formatDate(),
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your recovery trend improved by 12% since yesterday',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            _notificationBell(isDark),
            const SizedBox(width: 10),
            _premiumAvatar(userName, isDark),
          ],
        ),
      ],
    );
  }

  Widget _notificationBell(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.notifications_outlined,
              size: 20,
              color: isDark ? Colors.white70 : AppColors.textPrimary),
          Positioned(
            top: 9,
            right: 9,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumAvatar(String userName, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7FFF), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, Map<String, dynamic> data, bool isDark) {
    final healthScore = data['health_score'] as int? ?? 78;
    final latestMonitoring = data['latest_monitoring'] as Map<String, dynamic>?;
    final unsafeMeal = data['unsafe_meal'] as Map<String, dynamic>?;
    final recoveryScore = data['recovery_score'] as int? ?? 72;
    final profileNudge = data['profile_nudge'] == true;
    final emergencyActive = data['emergency_preparedness'] == true;
    final recoveryVelocity = data['recovery_velocity'] as List<dynamic>? ?? [];
    final medicationReminders =
        data['medication_reminders'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION 2 — Health Score Hero
        PremiumHealthScoreHero(
          score: healthScore,
          insightText: healthScore >= 70
              ? 'Hydration and nutrition compliance improved your score'
              : 'Focus on sleep and medication adherence to boost your score',
        ),
        const SizedBox(height: 20),

        // SECTION — Live Health Data
        const RealHealthMetricsCard(),
        const SizedBox(height: 20),

        // SECTION 3 — Alert Strips
        _buildAlertStrips(
          context,
          profileNudge: profileNudge,
          emergencyActive: emergencyActive,
          unsafeMeal: unsafeMeal,
          hasMedication: medicationReminders.isNotEmpty,
        ),

        // SECTION 6 — Vitals Strip
        if (latestMonitoring != null) ...[
          _sectionLabel('Today\'s Vitals', isDark),
          SizedBox(
            height: 132,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                VitalsStatPill(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Pain Level',
                  value: '${latestMonitoring['symptom_severity'] ?? '-'}',
                  unit: '/10',
                  color: AppColors.danger,
                ),
                const SizedBox(width: 10),
                VitalsStatPill(
                  icon: Icons.water_drop_outlined,
                  label: 'Hydration',
                  value: '${latestMonitoring['hydration_cups'] ?? '-'}',
                  unit: '/8',
                  color: const Color(0xFF0EA5E9),
                  trending: true,
                ),
                const SizedBox(width: 10),
                VitalsStatPill(
                  icon: Icons.bedtime_outlined,
                  label: 'Sleep',
                  value: '${latestMonitoring['sleep_hours'] ?? '-'}',
                  unit: 'hrs',
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 10),
                VitalsStatPill(
                  icon: Icons.mood_outlined,
                  label: 'Mood',
                  value: (latestMonitoring['mood']?.toString() ?? '').isNotEmpty
                      ? latestMonitoring['mood'].toString()[0].toUpperCase()
                      : '-',
                  color: AppColors.success,
                  trending: true,
                ),
                const SizedBox(width: 10),
                VitalsStatPill(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Calories',
                  value: '1840',
                  unit: 'kcal',
                  color: const Color(0xFFF97316),
                ),
                const SizedBox(width: 10),
                VitalsStatPill(
                  icon: Icons.air_outlined,
                  label: 'SpO2',
                  value: '98',
                  unit: '%',
                  color: const Color(0xFF10B981),
                  trending: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // SECTION 5 — AI Insights Feed
        _sectionLabel('AI Insights', isDark),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: const [
              AiInsightCard(
                insight: 'High sodium meal yesterday may affect blood pressure today.',
                category: InsightCategory.nutrition,
                timeAgo: '2 hours ago',
              ),
              SizedBox(width: 12),
              AiInsightCard(
                insight: 'Sleep dropped below 6h for 2 consecutive days.',
                category: InsightCategory.sleep,
                timeAgo: 'Last night',
              ),
              SizedBox(width: 12),
              AiInsightCard(
                insight: 'Your gastritis trigger pattern is improving this week.',
                category: InsightCategory.recovery,
                timeAgo: 'Today',
              ),
              SizedBox(width: 12),
              AiInsightCard(
                insight: 'Doctor follow-up recommended based on last AI analysis.',
                category: InsightCategory.warning,
                timeAgo: '1 day ago',
              ),
              SizedBox(width: 12),
              AiInsightCard(
                insight: 'Resting heart rate stable at 72 bpm for 3 days.',
                category: InsightCategory.vitals,
                timeAgo: '3 hours ago',
              ),
              SizedBox(width: 12),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // SECTION 4 — Quick Action Grid
        _sectionLabel('Quick Actions', isDark),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            QuickActionPod(
              icon: Icons.psychology_outlined,
              title: 'Symptom AI',
              description: 'Analyse symptoms with AI',
              color: AppColors.primary,
              showAiBadge: true,
              badgeLabel: 'Recommended',
              onTap: () => context.push('/symptom-check'),
            ),
            QuickActionPod(
              icon: Icons.qr_code_scanner_outlined,
              title: 'Nutrition Scan',
              description: 'Scan food for safety check',
              color: const Color(0xFF10B981),
              showAiBadge: true,
              badgeLabel: 'AI',
              onTap: () => context.push('/nutrition'),
            ),
            QuickActionPod(
              icon: Icons.medical_services_outlined,
              title: 'Doctors',
              description: 'Find & consult specialists',
              color: const Color(0xFFF59E0B),
              onTap: () => context.push('/doctors'),
            ),
            QuickActionPod(
              icon: Icons.folder_special_outlined,
              title: 'Records Vault',
              description: 'Medical history & labs',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.push('/records'),
            ),
            QuickActionPod(
              icon: Icons.show_chart_rounded,
              title: 'Daily Vitals',
              description: 'Log today\'s health data',
              color: const Color(0xFF06B6D4),
              onTap: () => context.push('/monitoring'),
            ),
            QuickActionPod(
              icon: Icons.emergency_share_outlined,
              title: 'Emergency SOS',
              description: 'Alert emergency contacts',
              color: AppColors.danger,
              onTap: () => context.push('/sos'),
            ),
            QuickActionPod(
              icon: Icons.insights_outlined,
              title: 'Recovery Report',
              description: 'Deep dive into progress',
              color: const Color(0xFF0EA5E9),
              showAiBadge: true,
              badgeLabel: 'AI',
              onTap: () => context.push('/monitoring'),
            ),
            QuickActionPod(
              icon: Icons.qr_code_2_outlined,
              title: 'Health ID QR',
              description: 'Share your health card',
              color: const Color(0xFF64748B),
              onTap: () => context.push('/profile'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // SECTION 7 — Recovery Story Card
        _sectionLabel('Recovery Story', isDark),
        RecoveryStoryCard(
          recoveryScore: recoveryScore,
          velocityData: recoveryVelocity,
          onViewReport: () => context.push('/monitoring'),
        ),
        const SizedBox(height: 20),

        // SECTION 8 — Today's Care Plan
        _sectionLabel('Today\'s Care Plan', isDark),
        const CarePlanChecklist(),
      ],
    );
  }

  Widget _buildAlertStrips(
    BuildContext context, {
    required bool profileNudge,
    required bool emergencyActive,
    Map<String, dynamic>? unsafeMeal,
    bool hasMedication = false,
  }) {
    final alerts = <Widget>[];

    if (profileNudge) {
      alerts.add(AlertStripCard(
        icon: Icons.person_add_alt_1_outlined,
        title: 'Complete Medical Profile',
        subtitle: 'Missing core data affects AI accuracy',
        severity: AlertSeverity.warning,
        onTap: () => context.push('/onboarding-wizard'),
      ));
    }
    if (!emergencyActive) {
      alerts.add(AlertStripCard(
        icon: Icons.warning_amber_rounded,
        title: 'SOS Setup Incomplete',
        subtitle: 'No emergency contact configured yet',
        severity: AlertSeverity.danger,
        onTap: () => context.push('/onboarding-wizard'),
      ));
    }
    if (hasMedication) {
      alerts.add(AlertStripCard(
        icon: Icons.medication_outlined,
        title: 'Medication Reminder Due',
        subtitle: 'Evening dose not marked as taken',
        severity: AlertSeverity.info,
        onTap: () {},
      ));
    }
    if (unsafeMeal != null) {
      alerts.add(AlertStripCard(
        icon: Icons.restaurant_outlined,
        title: 'Unsafe Food Detected',
        subtitle:
            '${unsafeMeal['food_name'] ?? 'Item'} flagged for your condition',
        severity: AlertSeverity.danger,
        onTap: () {},
      ));
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < alerts.length; i++) ...[
          alerts[i],
          if (i < alerts.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        const ShimmerBox(height: 360, borderRadius: 24),
        const SizedBox(height: 20),
        const ShimmerBox(height: 72, borderRadius: 16),
        const SizedBox(height: 10),
        const ShimmerBox(height: 72, borderRadius: 16),
        const SizedBox(height: 20),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 120, borderRadius: 20)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 120, borderRadius: 20)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 120, borderRadius: 20)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 120, borderRadius: 20)),
          ],
        ),
        const SizedBox(height: 20),
        const ShimmerBox(height: 200, borderRadius: 24),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.cloud_off_outlined,
                size: 32, color: AppColors.danger),
          ),
          const SizedBox(height: 16),
          const Text(
            'Could not load dashboard',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _formatDate() {
    final now = DateTime.now();
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class _DashboardBackground extends StatelessWidget {
  final bool isDark;
  const _DashboardBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // DNA background image via DecorationImage — safe on web Skia,
        // onError silently falls back to the solid color below.
        DecoratedBox(
          decoration: BoxDecoration(
            // Solid fallback shown when the asset hasn't been bundled yet
            color: isDark
                ? const Color(0xFF050E1A)
                : const Color(0xFFDCEEFB),
            image: DecorationImage(
              image: const AssetImage('assets/images/dashboard_bg.png'),
              fit: BoxFit.cover,
              // Slight desaturation + lightening for a softer look
              colorFilter: isDark
                  ? ColorFilter.mode(
                      const Color(0xFF050E1A).withValues(alpha: 0.55),
                      BlendMode.darken,
                    )
                  : ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.12),
                      BlendMode.lighten,
                    ),
              onError: (_, __) {},
            ),
          ),
        ),
        // Gradient fade for readability
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: isDark
                  ? [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF050E1A).withValues(alpha: 0.3),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.60),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}



