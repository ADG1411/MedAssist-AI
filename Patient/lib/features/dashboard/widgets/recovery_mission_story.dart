import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class RecoveryMissionStory extends StatefulWidget {
  final Map<String, dynamic> data;
  const RecoveryMissionStory({super.key, required this.data});

  @override
  State<RecoveryMissionStory> createState() => _RecoveryMissionStoryState();
}

class _RecoveryMissionStoryState extends State<RecoveryMissionStory>
    with TickerProviderStateMixin {
  late AnimationController _fireCtrl;
  late AnimationController _confettiCtrl;
  late Animation<double> _fireAnim;

  @override
  void initState() {
    super.initState();
    _fireCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _fireAnim = Tween<double>(begin: 0.85, end: 1.15)
        .animate(CurvedAnimation(parent: _fireCtrl, curve: Curves.easeInOut));

    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    // Fire confetti if recovery is trending up
    final velocity = (widget.data['recovery_velocity'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];
    if (velocity.length >= 2 && velocity.last > velocity[velocity.length - 2]) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _confettiCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _fireCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recoveryScore = (widget.data['recovery_score'] as num?)?.toInt() ?? 70;
    final velocity = (widget.data['recovery_velocity'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [70, 72, 71, 75, 76];
    final trending =
        velocity.length >= 2 && velocity.last > velocity[velocity.length - 2];
    final aiResult = widget.data['latest_ai_result'] as Map<String, dynamic>?;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    // Next milestone
    final nextMilestone = recoveryScore < 80 ? 80 : 90;
    final etaDays = ((nextMilestone - recoveryScore) / 3).ceil().clamp(1, 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashSectionLabel('🌱 Recovery Mission', 'Your healing journey'),
        const SizedBox(height: 10),
        GlassCard(
          radius: 24,
          blur: 20,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score + trend chart row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Recovery Score',
                                    style:
                                        TextStyle(fontSize: 12, color: textSub, letterSpacing: -0.1)),
                                const SizedBox(width: 8),
                                // Animated streak fire badge
                                ScaleTransition(
                                  scale: _fireAnim,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFFF59E0B),
                                        Color(0xFFEF4444),
                                      ]),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B)
                                              .withValues(alpha: 0.35),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('🔥', style: TextStyle(fontSize: 10)),
                                        SizedBox(width: 3),
                                        Text('3 Day Streak',
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$recoveryScore',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                    letterSpacing: -2,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 6, left: 3),
                                  child: Text('/100',
                                      style: TextStyle(
                                          fontSize: 13, color: textSub)),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (trending
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B))
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        trending
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_flat_rounded,
                                        size: 12,
                                        color: trending
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        trending ? '+3 pts' : 'Stable',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: trending
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Smoothed trend chart
                      SizedBox(
                        width: 100,
                        height: 52,
                        child: CustomPaint(
                            painter: _SmoothTrendPainter(
                                velocity, const Color(0xFF10B981))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recovery ETA confidence bar
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                          width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded,
                            size: 14, color: Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next milestone: $nextMilestone pts  ·  ETA ~$etaDays days',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary),
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (recoveryScore / nextMilestone)
                                      .clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.06),
                                  valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF6366F1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('🏆 Reward',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // AI narrative card
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF10B981).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.18),
                          width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Text('🤖',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            aiResult != null
                                ? '2 more days of good hydration may fully stabilize ${aiResult['condition']} symptoms.'
                                : '2 more days of consistent hydration may fully stabilize your symptoms.',
                            style: TextStyle(
                                fontSize: 12,
                                color: textPrimary,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Milestone chips with unlock glow
                  Row(
                    children: [
                      _Milestone('3 Day\nStreak', Icons.local_fire_department_rounded,
                          const Color(0xFFF59E0B), true),
                      const SizedBox(width: 7),
                      _Milestone('Good\nSleep', Icons.nightlight_round,
                          const Color(0xFF8B5CF6), false),
                      const SizedBox(width: 7),
                      _Milestone('Low\nSeverity', Icons.shield_rounded,
                          const Color(0xFF10B981), true),
                      const SizedBox(width: 7),
                      _Milestone('Meds\nOn Time', Icons.medication_rounded,
                          const Color(0xFF06B6D4), false),
                    ],
                  ),
                ],
              ),
              // Confetti overlay
              if (trending)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _confettiCtrl,
                      builder: (context, _) => CustomPaint(
                        painter: _ConfettiPainter(_confettiCtrl.value),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Milestone extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool unlocked;
  const _Milestone(this.label, this.icon, this.color, this.unlocked);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: unlocked ? 0.14 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: unlocked ? 0.35 : 0.15),
              width: unlocked ? 1.0 : 0.5),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                if (unlocked)
                  Positioned(
                    right: 0,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981),
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E2328)
                                : Colors.white,
                            width: 1.5),
                      ),
                      child: const Icon(Icons.check,
                          size: 6, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: unlocked
                    ? (isDark ? Colors.white.withValues(alpha: 0.80) : color)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.40)
                        : AppColors.textSecondary),
                fontWeight: unlocked ? FontWeight.w600 : FontWeight.w400,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Smoothed bezier trend painter
class _SmoothTrendPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _SmoothTrendPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min).clamp(4.0, double.infinity);

    List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - min) / range) * (size.height - 6) - 3;
      pts.add(Offset(x, y));
    }

    // Build smooth bezier path
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    final fill = Path()
      ..moveTo(pts.first.dx, size.height)
      ..lineTo(pts.first.dx, pts.first.dy);

    for (int i = 0; i < pts.length - 1; i++) {
      final cx = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(cx, pts[i].dy, cx, pts[i + 1].dy, pts[i + 1].dx, pts[i + 1].dy);
      fill.cubicTo(cx, pts[i].dy, cx, pts[i + 1].dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    fill.lineTo(pts.last.dx, size.height);
    fill.close();

    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.0)
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Glow dot at last point
    canvas.drawCircle(
      pts.last,
      4,
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(pts.last, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SmoothTrendPainter old) => false;
}

// Mini confetti painter
class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final rng = math.Random(42);
    const count = 18;
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final startY = -10.0 + rng.nextDouble() * size.height * 0.3;
      final endY = size.height * 0.4 + rng.nextDouble() * size.height * 0.6;
      final y = startY + (endY - startY) * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final colors = [
        const Color(0xFF10B981),
        const Color(0xFF6366F1),
        const Color(0xFFF59E0B),
        const Color(0xFFEF4444),
        const Color(0xFF06B6D4),
      ];
      canvas.drawCircle(
        Offset(x, y),
        2 + rng.nextDouble() * 2,
        Paint()..color = colors[i % colors.length].withValues(alpha: opacity * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}
