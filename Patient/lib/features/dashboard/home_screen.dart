import 'package:flutter/material.dart';
import '../../shared/widgets/app_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/shimmer_box.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/floating_glass_header.dart';
import 'widgets/premium_health_command_card.dart';
import 'widgets/attention_hub_rail.dart';
import 'widgets/live_vitals_glass_rail.dart';
import 'widgets/ai_insight_stream.dart';
import 'widgets/action_matrix_grid.dart';
import 'widgets/recovery_mission_story.dart';
import 'widgets/ai_daily_care_engine.dart';
import 'widgets/health_timeline_stepper.dart';

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
      duration: const Duration(milliseconds: 650),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // ── Full-screen glass background ──────────────────────────────
          AppBackground(isDark: isDark),

          // ── Scrollable content ────────────────────────────────────────
          RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            color: AppColors.primary,
            displacement: 60,
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ① Floating Glass Header
                              const FloatingGlassHeader(),
                              const SizedBox(height: 16),

                              asyncDashboard.when(
                                loading: () => _buildLoading(),
                                error: (e, _) => _buildError(),
                                data: (data) =>
                                    _buildDashboard(context, data, isDark),
                              ),

                              // Bottom spacer for glass nav bar
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
          ),

        ],
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, Map<String, dynamic> data, bool isDark) {
    final healthScore = (data['health_score'] as num?)?.toInt() ?? 78;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ② Health Command Hero
        PremiumHealthCommandCard(healthScore: healthScore, data: data),
        const SizedBox(height: 20),

        // ③ Unified Attention Hub
        AttentionHubRail(data: data),
        const SizedBox(height: 20),

        // ④ Live Vitals Rail
        const LiveVitalsGlassRail(),
        const SizedBox(height: 20),

        // ⑤ Predictive AI Insight Stream
        AiInsightStream(data: data),
        const SizedBox(height: 20),

        // ⑥ Smart Action Matrix
        const ActionMatrixGrid(),
        const SizedBox(height: 20),

        // ⑦ Recovery Mission Story
        RecoveryMissionStory(data: data),
        const SizedBox(height: 20),

        // ⑧ AI Daily Care Engine
        AiDailyCareEngine(data: data),
        const SizedBox(height: 20),

        // ⑨ Health Timeline
        HealthTimelineStepper(data: data),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        const ShimmerBox(height: 80, borderRadius: 24),
        const SizedBox(height: 16),
        const ShimmerBox(height: 220, borderRadius: 28),
        const SizedBox(height: 16),
        const ShimmerBox(height: 138, borderRadius: 20),
        const SizedBox(height: 16),
        const ShimmerBox(height: 122, borderRadius: 18),
        const SizedBox(height: 16),
        const ShimmerBox(height: 160, borderRadius: 20),
        const SizedBox(height: 16),
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
          const Text('Could not load dashboard',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
}


// ── No-scrollbar behavior ─────────────────────────────────────────────────────

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}




