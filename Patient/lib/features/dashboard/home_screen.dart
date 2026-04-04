import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int i, int total, Widget child) {
    final begin = (i / total).clamp(0.0, 1.0);
    final end = ((i + 2) / total).clamp(0.0, 1.0);
    final curve = Interval(begin, end, curve: Curves.easeOutCubic);
    final opacity = _staggerCtrl.drive(
        Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)));
    final slide = _staggerCtrl.drive(
        Tween(begin: 20.0, end: 0.0).chain(CurveTween(curve: curve)));
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (_, __) => Opacity(
        opacity: opacity.value,
        child: Transform.translate(offset: Offset(0, slide.value), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dash = ref.watch(dashboardProvider);
    final authData = ref.watch(authProvider);
    final userName = (authData?['full_name'] as String?) ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            color: AppColors.primary,
            displacement: 60,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(userName: userName, isDark: isDark),
                          const SizedBox(height: 24),
                          dash.when(
                            loading: () => _buildLoading(),
                            error: (e, _) => _buildError(),
                            data: (data) => _buildDashboard(data, isDark),
                          ),
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── SOS FAB (dashboard only) ──────────────────────────
          Positioned(
            right: 18,
            bottom: (MediaQuery.paddingOf(context).bottom == 0 ? 14.0 : MediaQuery.paddingOf(context).bottom) + 74,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push('/sos');
              },
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.45),
                      blurRadius: 14, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text('SOS', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900,
                    fontSize: 14, letterSpacing: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(Map<String, dynamic> data, bool isDark) {
    final score = (data['health_score'] as num?)?.toInt() ?? 78;
    final monitoring = data['latest_monitoring'] as Map<String, dynamic>?;
    final wearable = data['wearable_sync'] as Map<String, dynamic>?;
    final meds = data['medication_reminders'] as List? ?? [];
    final appointments = data['upcoming_appointments'] as List? ?? [];
    final recoveryScore = (data['recovery_score'] as num?)?.toInt() ?? 70;

    if (!_staggerCtrl.isAnimating && _staggerCtrl.value == 0) {
      Future.microtask(() => _staggerCtrl.forward());
    }

    const t = 7;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ① Health Score Card
        _stagger(0, t, _HealthScoreCard(
          score: score,
          isDark: isDark,
          onTap: () => context.push('/health-connect'),
        )),
        const SizedBox(height: 16),

        // ② Health Metrics
        _stagger(1, t, DashSectionLabel(
          'Health Metrics', 'Real-time body data',
          onSeeAll: () => context.push('/health-connect'),
        )),
        const SizedBox(height: 8),
        _stagger(1, t, _HealthMetricsRail(
          monitoring: monitoring,
          wearable: wearable,
          isDark: isDark,
        )),
        const SizedBox(height: 16),

        // ③ Activity
        _stagger(2, t, DashSectionLabel(
          'Activity', 'Your daily movement',
          onSeeAll: () => context.push('/health-connect'),
        )),
        const SizedBox(height: 8),
        _stagger(2, t, _ActivityCard(
          steps: (wearable?['steps'] as num?)?.toInt() ?? 0,
          sleepHours: (monitoring?['sleep_hours'] as num?)?.toDouble() ?? 0,
          hydration: (monitoring?['hydration_cups'] as num?)?.toInt() ?? 0,
          isDark: isDark,
        )),
        const SizedBox(height: 16),

        // ④ Upcoming
        if (meds.isNotEmpty || appointments.isNotEmpty) ...[
          _stagger(3, t, DashSectionLabel(
            'Upcoming', 'Meds & appointments',
          )),
          const SizedBox(height: 8),
          _stagger(3, t, _UpcomingSection(
            meds: meds,
            appointments: appointments,
            isDark: isDark,
          )),
          const SizedBox(height: 16),
        ],

        // ⑤ Recovery
        _stagger(4, t, _RecoveryCard(
          score: recoveryScore,
          isDark: isDark,
          onTap: () => context.push('/monitoring'),
        )),
        const SizedBox(height: 16),

        // ⑥ Quick Actions
        _stagger(5, t, DashSectionLabel(
          'Quick Actions', 'Health tools at a tap',
        )),
        const SizedBox(height: 8),
        _stagger(5, t, _QuickActionsGrid(isDark: isDark)),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(children: const [
      ShimmerBox(height: 100, borderRadius: 20),
      SizedBox(height: 20),
      ShimmerBox(height: 130, borderRadius: 20),
      SizedBox(height: 20),
      ShimmerBox(height: 160, borderRadius: 20),
      SizedBox(height: 20),
      ShimmerBox(height: 100, borderRadius: 20),
    ]);
  }

  Widget _buildError() {
    return Center(
      child: Column(children: [
        const SizedBox(height: 80),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.cloud_off_outlined, size: 32, color: AppColors.danger),
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
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final String userName;
  final bool isDark;
  const _Header({required this.userName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    final hour = now.hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr,
                  style: TextStyle(fontSize: 13, color: textSub, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                'Hello, $userName!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(greeting,
                  style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        // Search
        _HeaderIconBtn(
          icon: Icons.search_rounded,
          isDark: isDark,
          onTap: () {},
        ),
        const SizedBox(width: 10),
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.80),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.border,
            width: 0.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(icon, size: 20,
            color: isDark ? Colors.white.withValues(alpha: 0.70) : AppColors.textSecondary),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEALTH SCORE CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _HealthScoreCard extends StatelessWidget {
  final int score;
  final bool isDark;
  final VoidCallback onTap;
  const _HealthScoreCard({required this.score, required this.isDark, required this.onTap});

  String get _label =>
      score >= 80 ? 'Excellent Health' :
      score >= 60 ? 'Good Health' :
      score >= 40 ? 'Fair Health' : 'Needs Attention';

  Color get _statusColor =>
      score >= 80 ? AppColors.success :
      score >= 60 ? AppColors.primary :
      score >= 40 ? AppColors.warning : AppColors.danger;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      )),
                  const SizedBox(height: 8),
                  Row(children: [
                    _TagChip(
                      label: 'Healthy',
                      icon: Icons.favorite_rounded,
                      color: _statusColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _TagChip(
                      label: 'MedAssist+',
                      icon: Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ]),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 24,
                color: isDark ? Colors.white.withValues(alpha: 0.35) : AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _TagChip({required this.label, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEALTH METRICS RAIL
// ═══════════════════════════════════════════════════════════════════════════════

class _HealthMetricsRail extends StatefulWidget {
  final Map<String, dynamic>? monitoring;
  final Map<String, dynamic>? wearable;
  final bool isDark;
  const _HealthMetricsRail({this.monitoring, this.wearable, required this.isDark});

  @override
  State<_HealthMetricsRail> createState() => _HealthMetricsRailState();
}

class _HealthMetricsRailState extends State<_HealthMetricsRail> {
  late final PageController _pageCtrl;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  static String _fmtNum(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final steps = (widget.wearable?['steps'] as num?)?.toInt() ?? 0;
    final sleep = (widget.monitoring?['sleep_hours'] as num?)?.toDouble() ?? 0;
    final hydration = (widget.monitoring?['hydration_cups'] as num?)?.toInt() ?? 0;
    final isDark = widget.isDark;

    final metrics = [
      _MetricData('Heart Rate', '72', 'bpm', Icons.favorite_rounded, const Color(0xFFEF4444)),
      _MetricData('Blood Pressure', '120/80', 'mmHg', Icons.monitor_heart_rounded, AppColors.primary),
      _MetricData('SpO₂', '98', '%', Icons.air_rounded, const Color(0xFF06B6D4)),
      _MetricData('Steps', steps > 0 ? _fmtNum(steps) : '--', 'steps', Icons.directions_walk_rounded, const Color(0xFF8B5CF6)),
      _MetricData('Sleep', sleep > 0 ? sleep.toStringAsFixed(1) : '--', 'hrs', Icons.nightlight_round, const Color(0xFF6366F1)),
      _MetricData('Water', hydration > 0 ? '$hydration' : '--', 'cups', Icons.water_drop_rounded, const Color(0xFF0EA5E9)),
    ];

    // Group into pairs of 2
    final pageCount = (metrics.length / 2).ceil();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: pageCount,
            onPageChanged: (i) => setState(() => _currentPage = i),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, pageIndex) {
              final startIdx = pageIndex * 2;
              return AnimatedBuilder(
                animation: _pageCtrl,
                builder: (context, child) {
                  double page = _pageCtrl.hasClients && _pageCtrl.position.haveDimensions
                      ? _pageCtrl.page ?? _currentPage.toDouble()
                      : _currentPage.toDouble();
                  double delta = (page - pageIndex).abs().clamp(0.0, 1.0);
                  double scale = 1.0 - (delta * 0.05);
                  double opacity = 1.0 - (delta * 0.3);

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: [
                      for (int j = 0; j < 2; j++)
                        if (startIdx + j < metrics.length)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: j == 0 ? 0 : 6, right: j == 0 ? 6 : 0),
                              child: _MetricCard(data: metrics[startIdx + j], isDark: isDark),
                            ),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pageCount, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive
                    ? AppColors.primary
                    : (isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15)),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MetricData {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _MetricData(this.label, this.value, this.unit, this.icon, this.color);
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  final bool isDark;
  const _MetricCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      blur: 14,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(data.icon, size: 18, color: data.color),
            ),
            const Spacer(),
            RichText(text: TextSpan(children: [
              TextSpan(
                text: data.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: ' ${data.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white.withValues(alpha: 0.40) : AppColors.textSecondary,
                ),
              ),
            ])),
            const SizedBox(height: 4),
            Text(data.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTIVITY CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _ActivityCard extends StatelessWidget {
  final int steps;
  final double sleepHours;
  final int hydration;
  final bool isDark;
  const _ActivityCard({required this.steps, required this.sleepHours,
      required this.hydration, required this.isDark});

  String get _level {
    if (steps >= 10000) return 'Very Active';
    if (steps >= 5000) return 'Active';
    if (steps >= 2000) return 'Light';
    return 'Sedentary';
  }

  double get _progress => (steps / 10000).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Summary row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_level,
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: textPrimary, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text(
                      steps > 0
                          ? 'You walked ${steps.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} steps today'
                          : 'Start tracking your steps',
                      style: TextStyle(fontSize: 13, color: textSub),
                    ),
                  ],
                ),
              ),
              // Progress ring
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52, height: 52,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.paleBlue,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stat chips
          Row(
            children: [
              _StatChip(Icons.directions_walk_rounded, '${steps > 0 ? steps : "--"} steps', AppColors.primary, isDark),
              const SizedBox(width: 10),
              _StatChip(Icons.nightlight_round, '${sleepHours > 0 ? sleepHours.toStringAsFixed(1) : "--"} hrs', const Color(0xFF6366F1), isDark),
              const SizedBox(width: 10),
              _StatChip(Icons.water_drop_rounded, '${hydration > 0 ? hydration : "--"} cups', const Color(0xFF0EA5E9), isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  const _StatChip(this.icon, this.label, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.10 : 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// UPCOMING SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _UpcomingSection extends StatelessWidget {
  final List meds;
  final List appointments;
  final bool isDark;
  const _UpcomingSection({required this.meds, required this.appointments, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...meds.map((m) {
            final taken = m['taken'] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (taken ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      taken ? Icons.check_circle_rounded : Icons.medication_rounded,
                      size: 18,
                      color: taken ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['name'] ?? '', style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                        Text(m['time'] ?? '', style: TextStyle(fontSize: 12, color: textSub)),
                      ],
                    ),
                  ),
                  if (taken)
                    const Icon(Icons.check_rounded, size: 18, color: AppColors.success),
                ],
              ),
            );
          }),
          ...appointments.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['doctor'] ?? '', style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                      Text(a['time'] ?? '', style: TextStyle(fontSize: 12, color: textSub)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20,
                    color: isDark ? Colors.white.withValues(alpha: 0.30) : AppColors.textHint),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RECOVERY CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _RecoveryCard extends StatelessWidget {
  final int score;
  final bool isDark;
  final VoidCallback onTap;
  const _RecoveryCard({required this.score, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Recovery ring
            SizedBox(
              width: 56, height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56, height: 56,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.paleBlue,
                      valueColor: const AlwaysStoppedAnimation(AppColors.success),
                    ),
                  ),
                  Text('$score',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recovery Score',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: textPrimary, letterSpacing: -0.2)),
                  const SizedBox(height: 4),
                  Text(
                    score >= 80
                        ? 'Great progress! Keep it up'
                        : 'Steady improvement — stay consistent',
                    style: TextStyle(fontSize: 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 24,
                color: isDark ? Colors.white.withValues(alpha: 0.35) : AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// QUICK ACTIONS GRID
// ═══════════════════════════════════════════════════════════════════════════════

class _QuickActionsGrid extends StatelessWidget {
  final bool isDark;
  const _QuickActionsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA('AI Check', Icons.psychology_rounded, AppColors.primary, '/symptom-check'),
      _QA('Doctors', Icons.medical_services_rounded, const Color(0xFF8B5CF6), '/doctors'),
      _QA('Pharmacy', Icons.local_pharmacy_rounded, const Color(0xFF10B981), '/pharmacy'),
      _QA('Hospitals', Icons.local_hospital_rounded, const Color(0xFFEF4444), '/hospitals'),
      _QA('Records', Icons.folder_rounded, const Color(0xFFF59E0B), '/records'),
      _QA('Monitoring', Icons.monitor_heart_rounded, const Color(0xFF06B6D4), '/monitoring'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: actions.map((a) => _QuickActionTile(action: a, isDark: isDark)).toList(),
    );
  }
}

class _QA {
  final String label, route;
  final IconData icon;
  final Color color;
  const _QA(this.label, this.icon, this.color, this.route);
}

class _QuickActionTile extends StatelessWidget {
  final _QA action;
  final bool isDark;
  const _QuickActionTile({required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(action.route);
      },
      child: GlassCard(
        radius: 16,
        blur: 12,
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, size: 22, color: action.color),
            ),
            const SizedBox(height: 10),
            Text(action.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
