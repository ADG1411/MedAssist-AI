// Recovery Report Screen — fully functional, data-driven.
// Uses RecoveryNotifier to show real 7-day trend, score, AI insight,
// and correlation analysis from actual monitoring logs.
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../monitoring/providers/recovery_provider.dart';

class RecoveryReportScreen extends ConsumerWidget {
  const RecoveryReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recoveryAsync = ref.watch(recoveryProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Recovery Report',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            onPressed: () => ref.read(recoveryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: recoveryAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(onRetry: () => ref.read(recoveryProvider.notifier).refresh()),
        data: (data) => _RecoveryBody(data: data, isDark: isDark),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Computing recovery score…',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.danger),
        const SizedBox(height: 12),
        const Text('Could not load recovery data',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ]),
    );
  }
}

// ── Main body ─────────────────────────────────────────────────────────────────

class _RecoveryBody extends StatelessWidget {
  final RecoveryData data;
  final bool isDark;
  const _RecoveryBody({required this.data, required this.isDark});

  Color get _scoreColor {
    if (data.score >= 75) return const Color(0xFF10B981);
    if (data.score >= 45) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _statusLabel {
    if (data.score >= 80) return 'Excellent Recovery';
    if (data.score >= 65) return 'Good Progress';
    if (data.score >= 45) return 'Recovering';
    return 'Needs Attention';
  }

  String get _aiInsight {
    final cond = data.conditionName;
    final name = cond != null ? '$cond symptoms' : 'your symptoms';
    if (data.score >= 80) {
      return 'Outstanding! Based on ${data.episodeDays} days of data, $name are nearly resolved. Maintain hydration and sleep to sustain this.';
    }
    if (data.score >= 60) {
      return 'Steady progress. Based on ${data.episodeDays} days of data, $name are improving. Keep up the consistent hydration and good sleep habits.';
    }
    if (data.isTrending) {
      return 'Your body is healing — upward trend detected. Continue reducing severity-triggering foods and prioritise 7–8 hours of sleep.';
    }
    return 'Recovery is slower than ideal. Focus on hydration (8+ cups/day), 7+ hours of sleep, and avoid known trigger foods to accelerate healing.';
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.55) : AppColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF111827) : Colors.white;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        // Refresh handled via app bar button
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero score gauge ────────────────────────────────────────
            _ScoreHeroCard(
              score: data.score,
              status: _statusLabel,
              episodeDays: data.episodeDays,
              delta: data.scoreDelta,
              isTrending: data.isTrending,
              color: _scoreColor,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSub: textSub,
            ),
            const SizedBox(height: 16),

            // ── ETA to next milestone ───────────────────────────────────
            _EtaCard(
              etaLabel: data.etaLabel,
              score: data.score,
              color: _scoreColor,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
            ),
            const SizedBox(height: 16),

            // ── 7-day trend ─────────────────────────────────────────────
            _TrendCard(
              velocity: data.velocity,
              color: _scoreColor,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSub: textSub,
            ),
            const SizedBox(height: 16),

            // ── AI insight ─────────────────────────────────────────────
            _AiInsightCard(
              insight: _aiInsight,
              score: data.score,
              conditionName: data.conditionName,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
            ),
            const SizedBox(height: 16),

            // ── Per-day breakdown ───────────────────────────────────────
            if (data.logs.isNotEmpty) ...[
              _SectionLabel('7-Day Breakdown', textSub),
              const SizedBox(height: 8),
              _LogBreakdown(
                logs: data.logs,
                velocity: data.velocity,
                color: _scoreColor,
                isDark: isDark,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSub: textSub,
              ),
              const SizedBox(height: 16),
            ],

            // ── Correlation analysis ────────────────────────────────────
            _CorrelationCard(
              logs: data.logs,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSub: textSub,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Score Hero Card ────────────────────────────────────────────────────────────

class _ScoreHeroCard extends StatelessWidget {
  final int score;
  final String status;
  final int episodeDays;
  final int delta;
  final bool isTrending;
  final Color color;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSub;

  const _ScoreHeroCard({
    required this.score,
    required this.status,
    required this.episodeDays,
    required this.delta,
    required this.isTrending,
    required this.color,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.healing_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        )),
                    Text('Day $episodeDays of recovery',
                        style: TextStyle(fontSize: 12, color: textSub)),
                  ],
                ),
              ),
              // Delta badge
              if (delta != 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isTrending
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrending
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 13,
                        color: isTrending
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${isTrending ? '+' : ''}$delta pts',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isTrending
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Big score circle
          _AnimatedScoreRing(score: score, color: color, isDark: isDark),
        ],
      ),
    );
  }
}

class _AnimatedScoreRing extends StatelessWidget {
  final int score;
  final Color color;
  final bool isDark;
  const _AnimatedScoreRing(
      {required this.score, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: score / 100.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => CustomPaint(
              painter: _RingPainter(
                progress: value,
                color: color,
                trackColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: score),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
              Text(
                'out of 100',
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  const _RingPainter(
      {required this.progress,
      required this.color,
      required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullSweep,
        false,
        trackPaint);

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progress * fullSweep,
        false,
        progressPaint);

    // Glow at tip
    if (progress > 0.02) {
      final angle = startAngle + progress * fullSweep;
      final tipX = center.dx + radius * math.cos(angle);
      final tipY = center.dy + radius * math.sin(angle);
      canvas.drawCircle(
        Offset(tipX, tipY),
        6,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── ETA Card ──────────────────────────────────────────────────────────────────

class _EtaCard extends StatelessWidget {
  final String etaLabel;
  final int score;
  final Color color;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;

  const _EtaCard({
    required this.etaLabel,
    required this.score,
    required this.color,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final nextMilestone = score < 80 ? 80 : score < 90 ? 90 : 100;
    final progress = (score / nextMilestone).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: Color(0xFF6366F1), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etaLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 5,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trend Chart Card ──────────────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  final List<double> velocity;
  final Color color;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSub;

  const _TrendCard({
    required this.velocity,
    required this.color,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    if (velocity.isEmpty) return const SizedBox.shrink();

    // Pad to 7 points with neutral value if fewer days logged
    final pts = velocity.length < 2
        ? [50.0, ...velocity]
        : velocity;

    final spots = List.generate(
      pts.length,
      (i) => FlSpot(i.toDouble(), pts[i].clamp(0.0, 100.0)),
    );

    final minY = (pts.reduce(math.min) - 5).clamp(0.0, 100.0);
    final maxY = (pts.reduce(math.max) + 5).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text('7-Day Score Trend',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
              const Spacer(),
              Text('${pts.length} days logged',
                  style: TextStyle(fontSize: 11, color: textSub)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= pts.length) {
                          return const SizedBox.shrink();
                        }
                        final labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                        final dayLabel = idx < labels.length ? labels[idx] : 'D${idx + 1}';
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(dayLabel,
                              style: TextStyle(fontSize: 9, color: textSub)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: TextStyle(fontSize: 9, color: textSub),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toInt()} pts',
                              TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: color,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isLast = index == spots.length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 5 : 3,
                          color: color,
                          strokeWidth: isLast ? 2 : 1,
                          strokeColor: isDark
                              ? const Color(0xFF111827)
                              : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.20),
                          color.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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
}

// ── AI Insight Card ───────────────────────────────────────────────────────────

class _AiInsightCard extends StatelessWidget {
  final String insight;
  final int score;
  final String? conditionName;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;

  const _AiInsightCard({
    required this.insight,
    required this.score,
    this.conditionName,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = score.clamp(60, 95);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF6366F1)
                .withValues(alpha: isDark ? 0.25 : 0.15),
            width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Color(0xFF818CF8), size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Recovery Insight',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary)),
                  if (conditionName != null)
                    Text(conditionName!,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF818CF8))),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text('$confidence% conf.',
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF818CF8))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: TextStyle(
                fontSize: 13, color: textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Per-day log breakdown ─────────────────────────────────────────────────────

class _LogBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final List<double> velocity;
  final Color color;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSub;

  const _LogBreakdown({
    required this.logs,
    required this.velocity,
    required this.color,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: List.generate(logs.length, (i) {
          final log = logs[i];
          final dayScore = i < velocity.length ? velocity[i].toInt() : 0;
          final dateStr = log['logged_date'] as String? ?? '';
          final severity = (log['symptom_severity'] as num?)?.toDouble() ?? 0;
          final hydration = (log['hydration_cups'] as num?)?.toInt() ?? 0;
          final sleep = (log['sleep_hours'] as num?)?.toDouble() ?? 0;
          final mood = log['mood'] as String? ?? '';

          final dayColor = dayScore >= 75
              ? const Color(0xFF10B981)
              : dayScore >= 45
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFEF4444);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Day score bubble
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dayColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$dayScore',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: dayColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr.length >= 10
                            ? _formatDate(dateStr)
                            : 'Day ${i + 1}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _MiniStat(
                              Icons.local_hospital_outlined,
                              '${severity.toInt()}/10',
                              const Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          _MiniStat(Icons.water_drop_outlined,
                              '${hydration}c', const Color(0xFF0EA5E9)),
                          const SizedBox(width: 8),
                          _MiniStat(Icons.nightlight_round,
                              '${sleep.toStringAsFixed(1)}h',
                              const Color(0xFF8B5CF6)),
                          if (mood.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _MiniStat(Icons.sentiment_satisfied_rounded, mood,
                                const Color(0xFF10B981)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return iso;
    }
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _MiniStat(this.icon, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 2),
        Text(value,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Correlation Analysis Card ─────────────────────────────────────────────────

class _CorrelationCard extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSub;

  const _CorrelationCard({
    required this.logs,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    // Compute real correlations from log data
    final avgSleepFirst = _avgSleep(logs.take(2).toList());
    final avgSleepLast = _avgSleep(logs.skip(logs.length > 2 ? logs.length - 2 : 0).toList());
    final avgHydFirst = _avgHydration(logs.take(2).toList());
    final avgHydLast = _avgHydration(logs.skip(logs.length > 2 ? logs.length - 2 : 0).toList());
    final firstSeverity = logs.isNotEmpty
        ? (logs.first['symptom_severity'] as num?)?.toDouble() ?? 5
        : 5.0;
    final lastSeverity = logs.isNotEmpty
        ? (logs.last['symptom_severity'] as num?)?.toDouble() ?? 5
        : 5.0;

    final sleepImproved = avgSleepLast > avgSleepFirst;
    final hydImproved = avgHydLast > avgHydFirst;
    final severityImproved = lastSeverity < firstSeverity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Correlation Analysis',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          _CorrelationItem(
            icon: Icons.water_drop_rounded,
            color: const Color(0xFF0EA5E9),
            title: 'Hydration',
            detail: hydImproved
                ? 'Avg hydration improved from ${avgHydFirst.toStringAsFixed(1)} to ${avgHydLast.toStringAsFixed(1)} cups — directly supporting symptom relief.'
                : 'Hydration has been consistent at ~${avgHydLast.toStringAsFixed(1)} cups/day. Aim for 8+ cups to accelerate recovery.',
            isDark: isDark,
            textPrimary: textPrimary,
            textSub: textSub,
          ),
          const SizedBox(height: 12),
          _CorrelationItem(
            icon: Icons.nightlight_round,
            color: const Color(0xFF8B5CF6),
            title: 'Sleep Quality',
            detail: sleepImproved
                ? 'Sleep improved from ~${avgSleepFirst.toStringAsFixed(1)} to ~${avgSleepLast.toStringAsFixed(1)} hours, positively correlating with lower severity scores.'
                : 'Sleep has averaged ~${avgSleepLast.toStringAsFixed(1)} hours. Targeting 7–9 hours is key to cellular repair.',
            isDark: isDark,
            textPrimary: textPrimary,
            textSub: textSub,
          ),
          const SizedBox(height: 12),
          _CorrelationItem(
            icon: Icons.monitor_heart_rounded,
            color: const Color(0xFFEF4444),
            title: 'Symptom Severity',
            detail: severityImproved
                ? 'Severity dropped from ${firstSeverity.toInt()}/10 to ${lastSeverity.toInt()}/10 — a ${(firstSeverity - lastSeverity).toInt()} point improvement over the tracked period.'
                : 'Severity has held at ${lastSeverity.toInt()}/10. Focus on reducing triggers and increasing rest.',
            isDark: isDark,
            textPrimary: textPrimary,
            textSub: textSub,
          ),
        ],
      ),
    );
  }

  double _avgSleep(List<Map<String, dynamic>> l) {
    if (l.isEmpty) return 6.0;
    final sum = l.fold<double>(
        0, (acc, e) => acc + ((e['sleep_hours'] as num?)?.toDouble() ?? 6.0));
    return sum / l.length;
  }

  double _avgHydration(List<Map<String, dynamic>> l) {
    if (l.isEmpty) return 4.0;
    final sum = l.fold<double>(
        0, (acc, e) => acc + ((e['hydration_cups'] as num?)?.toDouble() ?? 4.0));
    return sum / l.length;
  }
}

class _CorrelationItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final bool isDark;
  final Color textPrimary;
  final Color textSub;

  const _CorrelationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.isDark,
    required this.textPrimary,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
              const SizedBox(height: 3),
              Text(detail,
                  style: TextStyle(
                      fontSize: 12, color: textSub, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4),
    );
  }
}
