import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../core/theme/app_colors.dart';
import '../../health/providers/health_data_provider.dart';

class RealHealthMetricsCard extends ConsumerStatefulWidget {
  const RealHealthMetricsCard({super.key});

  @override
  ConsumerState<RealHealthMetricsCard> createState() =>
      _RealHealthMetricsCardState();
}

class _RealHealthMetricsCardState extends ConsumerState<RealHealthMetricsCard>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _entryAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _entryAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncHealth = ref.watch(healthDataProvider);

    return FadeTransition(
      opacity: _entryAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_entryAnim),
        child: asyncHealth.when(
          loading: () => _buildLoadingSkeleton(isDark),
          error: (e, _) => _buildError(isDark, e.toString()),
          data: (metrics) => metrics.permissionGranted
              ? _buildMetricsGrid(context, metrics, isDark)
              : _buildPermissionPrompt(isDark, metrics.error),
        ),
      ),
    );
  }

  // ── Loading skeleton ──────────────────────────────────────────────────────
  Widget _buildLoadingSkeleton(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(isDark),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.92,
          children: List.generate(
            4,
            (_) => Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Permission prompt ─────────────────────────────────────────────────────
  Widget _buildPermissionPrompt(bool isDark, String? msg) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cs.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.health_and_safety_rounded,
                  color: cs.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect Health Data',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg ?? 'Grant access to steps, heart rate, sleep & more.',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(healthDataProvider.notifier).refresh(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Connect',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildError(bool isDark, String msg) {
    return _buildPermissionPrompt(isDark, msg);
  }

  // ── Main metrics grid ─────────────────────────────────────────────────────
  Widget _buildMetricsGrid(
      BuildContext context, HealthMetrics m, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(isDark, onRefresh: () {
          ref.read(healthDataProvider.notifier).refresh();
        }),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.92,
          children: [
            _StepsCard(
              steps: m.steps,
              goal: m.stepGoal,
              progress: m.stepProgress,
              isDark: isDark,
            ),
            _HeartRateCard(
              bpm: m.heartRate,
              pulseAnim: _pulseAnim,
              isDark: isDark,
            ),
            _SleepCard(
              hours: m.sleepHours,
              goal: m.sleepGoal,
              progress: m.sleepProgress,
              isDark: isDark,
            ),
            _CaloriesCard(
              burned: m.caloriesBurned,
              goal: m.calorieGoal,
              progress: m.calorieProgress,
              isDark: isDark,
            ),
          ],
        ),
        if (m.bloodOxygen > 0) ...[
          const SizedBox(height: 12),
          _BloodOxygenBanner(spO2: m.bloodOxygen, isDark: isDark),
        ],
      ],
    );
  }

  Widget _sectionHeader(bool isDark, {VoidCallback? onRefresh}) {
    return Row(
      children: [
        LiquidGlass.withOwnLayer(
          fake: true,
          settings: const LiquidGlassSettings(
            blur: 5,
            thickness: 14,
            lightIntensity: 0.4,
            glassColor: Color.fromARGB(18, 99, 102, 241),
          ),
          shape: const LiquidRoundedSuperellipse(borderRadius: 8),
          glassContainsChild: true,
          child: Container(
            padding: const EdgeInsets.all(6),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.monitor_heart_rounded,
                color: AppColors.primary, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Live Health Data',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        if (onRefresh != null)
          IconButton.filledTonal(
            onPressed: onRefresh,
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
      ],
    );
  }
}

// ── Steps Card ────────────────────────────────────────────────────────────────
class _StepsCard extends StatefulWidget {
  final int steps;
  final int goal;
  final double progress;
  final bool isDark;

  const _StepsCard({
    required this.steps,
    required this.goal,
    required this.progress,
    required this.isDark,
  });

  @override
  State<_StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<_StepsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF6366F1);
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: color.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.directions_walk_rounded,
                        color: color, size: 15),
                  ),
                  const Spacer(),
                  Text(
                    '${(_anim.value * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _formatNumber(widget.steps),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text('steps today',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              _ArcProgress(
                  progress: _anim.value,
                  color: color,
                  isDark: widget.isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Heart Rate Card ────────────────────────────────────────────────────────────
class _HeartRateCard extends StatelessWidget {
  final double bpm;
  final Animation<double> pulseAnim;
  final bool isDark;

  const _HeartRateCard({
    required this.bpm,
    required this.pulseAnim,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFEF4444);
    final cs = Theme.of(context).colorScheme;
    final statusOk = bpm > 0 && bpm <= 100;

    String status = 'No data today';
    if (bpm > 0) {
      if (bpm < 60) {
        status = 'Below normal';
      } else if (bpm <= 100) {
        status = 'Normal range';
      } else {
        status = 'Above normal';
      }
    }

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      surfaceTintColor: color.withValues(alpha: 0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: pulseAnim,
                  builder: (context, child) => Transform.scale(
                    scale: bpm > 0 ? pulseAnim.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: color, size: 15),
                    ),
                  ),
                ),
                const Spacer(),
                RawChip(
                  label: Text(statusOk ? '♥ OK' : '—'),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusOk ? color : cs.onSurfaceVariant,
                  ),
                  backgroundColor: statusOk
                      ? color.withValues(alpha: 0.1)
                      : cs.surfaceContainerHighest,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              bpm > 0 ? '${bpm.toInt()}' : '--',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: bpm > 0 ? color : cs.onSurfaceVariant,
                letterSpacing: -0.5,
              ),
            ),
            Text('bpm • $status',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            const SizedBox(height: 6),
            _HeartbeatLine(color: color, isDark: isDark, hasData: bpm > 0),
          ],
        ),
      ),
    );
  }
}

// ── Sleep Card ────────────────────────────────────────────────────────────────
class _SleepCard extends StatefulWidget {
  final double hours;
  final double goal;
  final double progress;
  final bool isDark;

  const _SleepCard({
    required this.hours,
    required this.goal,
    required this.progress,
    required this.isDark,
  });

  @override
  State<_SleepCard> createState() => _SleepCardState();
}

class _SleepCardState extends State<_SleepCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF8B5CF6);
    final cs = Theme.of(context).colorScheme;

    final h = widget.hours.floor();
    final m = ((widget.hours - h) * 60).toInt();
    final label = widget.hours > 0 ? '${h}h ${m}m' : 'No data';

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: color.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bedtime_rounded,
                        color: color, size: 15),
                  ),
                  const Spacer(),
                  Text(
                    'Goal ${widget.goal.toInt()}h',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: widget.hours > 0 ? cs.onSurface : cs.onSurfaceVariant,
                  letterSpacing: -0.5,
                ),
              ),
              Text('last night',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _anim.value,
                  minHeight: 7,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Calories Card ─────────────────────────────────────────────────────────────
class _CaloriesCard extends StatefulWidget {
  final double burned;
  final double goal;
  final double progress;
  final bool isDark;

  const _CaloriesCard({
    required this.burned,
    required this.goal,
    required this.progress,
    required this.isDark,
  });

  @override
  State<_CaloriesCard> createState() => _CaloriesCardState();
}

class _CaloriesCardState extends State<_CaloriesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFF59E0B);
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: color.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_fire_department_rounded,
                        color: color, size: 15),
                  ),
                  const Spacer(),
                  _ArcProgress(
                      progress: _anim.value,
                      color: color,
                      isDark: widget.isDark,
                      size: 30),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.burned > 0
                    ? '${widget.burned.toInt()} kcal'
                    : '-- kcal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: widget.burned > 0 ? cs.onSurface : cs.onSurfaceVariant,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'of ${widget.goal.toInt()} kcal goal',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Blood Oxygen Banner ───────────────────────────────────────────────────────
class _BloodOxygenBanner extends StatelessWidget {
  final double spO2;
  final bool isDark;

  const _BloodOxygenBanner({required this.spO2, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF0EA5E9);
    final cs = Theme.of(context).colorScheme;
    final isNormal = spO2 >= 95;
    final statusColor = isNormal ? color : AppColors.danger;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      surfaceTintColor: statusColor.withValues(alpha: 0.15),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.air_rounded, color: color, size: 20),
        ),
        title: Text(
          'Blood Oxygen (SpO₂)',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface),
        ),
        subtitle: Text(
          isNormal ? 'Normal levels' : 'Below normal — consult a doctor',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${spO2.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 2),
            RawChip(
              label: Text(isNormal ? 'Normal' : 'Low'),
              labelStyle: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
              backgroundColor: statusColor.withValues(alpha: 0.1),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Arc Progress ───────────────────────────────────────────────────────
class _ArcProgress extends StatelessWidget {
  final double progress;
  final Color color;
  final bool isDark;
  final double size;

  const _ArcProgress({
    required this.progress,
    required this.color,
    required this.isDark,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcPainter(
          progress: progress,
          color: color,
          bgColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE8EDFF),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    const strokeWidth = 5.0;
    const startAngle = -math.pi * 0.8;
    const sweepFull = math.pi * 1.6;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      bgPaint,
    );

    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepFull * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Heartbeat line ────────────────────────────────────────────────────────────
class _HeartbeatLine extends StatelessWidget {
  final Color color;
  final bool isDark;
  final bool hasData;

  const _HeartbeatLine(
      {required this.color, required this.isDark, required this.hasData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: CustomPaint(
        painter: _HeartbeatPainter(
          color: hasData ? color : Colors.grey.withValues(alpha: 0.3),
          bgColor: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFFFEDED),
        ),
        size: const Size(double.infinity, 28),
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  final Color color;
  final Color bgColor;

  const _HeartbeatPainter({required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final mid = h / 2;

    path.moveTo(0, mid);
    path.lineTo(w * 0.15, mid);
    path.lineTo(w * 0.25, mid - h * 0.35);
    path.lineTo(w * 0.30, mid + h * 0.4);
    path.lineTo(w * 0.35, mid - h * 0.5);
    path.lineTo(w * 0.40, mid);
    path.lineTo(w * 0.55, mid);
    path.lineTo(w * 0.65, mid - h * 0.35);
    path.lineTo(w * 0.70, mid + h * 0.4);
    path.lineTo(w * 0.75, mid - h * 0.5);
    path.lineTo(w * 0.80, mid);
    path.lineTo(w, mid);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter old) => false;
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _formatNumber(int n) {
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  }
  return '$n';
}
