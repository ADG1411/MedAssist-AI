import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class PremiumHealthCommandCard extends StatefulWidget {
  final int healthScore;
  final Map<String, dynamic> data;

  const PremiumHealthCommandCard({
    super.key,
    required this.healthScore,
    required this.data,
  });

  @override
  State<PremiumHealthCommandCard> createState() =>
      _PremiumHealthCommandCardState();
}

class _PremiumHealthCommandCardState extends State<PremiumHealthCommandCard>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _expandCtrl;
  late Animation<double> _ringAnim;
  late Animation<double> _expandAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _ringAnim = Tween<double>(begin: 0.0, end: widget.healthScore / 100.0)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic));
    _expandAnim =
        CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _ringCtrl.forward();
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  Color _scoreColor(int s) {
    if (s >= 80) return const Color(0xFF10B981);
    if (s >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _scoreLabel(int s) {
    if (s >= 80) return 'Excellent';
    if (s >= 60) return 'Good';
    if (s >= 40) return 'Fair';
    return 'Needs Attention';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = widget.healthScore;
    final color = _scoreColor(score);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final monitoring =
        widget.data['latest_monitoring'] as Map<String, dynamic>?;
    final recoveryScore =
        (widget.data['recovery_score'] as num?)?.toInt() ?? 70;
    final sleepHours =
        (monitoring?['sleep_hours'] as num?)?.toDouble() ?? 6.5;

    final pillars = [
      _Pillar('Vitals', monitoring != null ? 80 : 60,
          Icons.favorite_rounded, const Color(0xFFEF4444)),
      _Pillar('Nutrition', monitoring != null ? 70 : 55,
          Icons.restaurant_rounded, const Color(0xFF10B981)),
      _Pillar('Sleep', (sleepHours / 9.0 * 100).clamp(0, 100),
          Icons.nightlight_round, const Color(0xFF8B5CF6)),
      _Pillar('Activity', 72,
          Icons.directions_run_rounded, const Color(0xFFF59E0B)),
      _Pillar('Recovery', recoveryScore.toDouble(),
          Icons.healing_rounded, const Color(0xFF06B6D4)),
    ];

    return GlassCard(
      radius: 28,
      blur: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row: ring + info
          Row(
            children: [
              SizedBox(
                width: 118,
                height: 118,
                child: AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (context, child) => CustomPaint(
                    painter: _ScoreRingPainter(
                      progress: _ringAnim.value,
                      color: color,
                      isDark: isDark,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(score * _ringAnim.value).round()}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: color,
                              letterSpacing: -1,
                            ),
                          ),
                          Text('/100',
                              style: TextStyle(fontSize: 11, color: textSub)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: color),
                          ),
                          const SizedBox(width: 6),
                          Text(_scoreLabel(score),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: color)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Health Command Score',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                    const SizedBox(height: 3),
                    Text(
                      'AI-computed from vitals,\nhabits & clinical history',
                      style: TextStyle(
                          fontSize: 11, color: textSub, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Badge(
                          gradient: const [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6)
                          ],
                          icon: Icons.auto_awesome,
                          label: 'AI · 94% conf',
                        ),
                        _Badge(
                          bg: const Color(0xFF10B981).withValues(alpha: 0.14),
                          fg: const Color(0xFF10B981),
                          label: '↑ $recoveryScore% recovery',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 5 pillars
          Row(
            children: pillars
                .map((p) => Expanded(
                    child: _PillarTile(pillar: p, isDark: isDark)))
                .toList(),
          ),
          const SizedBox(height: 14),
          // Expandable drawer toggle
          GestureDetector(
            onTap: () {
              setState(() => _expanded = !_expanded);
              _expanded ? _expandCtrl.forward() : _expandCtrl.reverse();
            },
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Why did my score change?',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 280),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppColors.primary),
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReasonRow('Clinical baseline & AI risk',
                      monitoring != null
                          ? 'Active monitoring logged'
                          : 'No log today — mild buffer applied',
                      const Color(0xFF6366F1)),
                  _ReasonRow('Recovery momentum',
                      'Current score: $recoveryScore / 100',
                      const Color(0xFF10B981)),
                  _ReasonRow(
                      'Vitals & monitoring',
                      monitoring != null
                          ? 'Sleep: ${sleepHours.toStringAsFixed(1)}h · Severity logged'
                          : 'No vitals logged today',
                      const Color(0xFFF59E0B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Pillar {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  const _Pillar(this.label, this.value, this.icon, this.color);
}

class _PillarTile extends StatelessWidget {
  final _Pillar pillar;
  final bool isDark;
  const _PillarTile({required this.pillar, required this.isDark});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pillar.color.withValues(alpha: 0.14),
            ),
            child: Icon(pillar.icon, size: 16, color: pillar.color),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (pillar.value / 100).clamp(0.0, 1.0),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.09)
                    : Colors.black.withValues(alpha: 0.07),
                valueColor: AlwaysStoppedAnimation(pillar.color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(pillar.label,
              style: TextStyle(
                  fontSize: 9,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppColors.textSecondary)),
        ],
      );
}

class _Badge extends StatelessWidget {
  final List<Color>? gradient;
  final Color? bg;
  final Color? fg;
  final IconData? icon;
  final String label;

  const _Badge({this.gradient, this.bg, this.fg, this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(colors: gradient!)
            : null,
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 10, color: fg ?? Colors.white),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: fg ?? Colors.white,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  const _ReasonRow(this.title, this.subtitle, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.50)
                          : AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Score Ring Painter ────────────────────────────────────────────────────────

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;
  const _ScoreRingPainter(
      {required this.progress, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = (isDark ? Colors.white : Colors.black)
              .withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: startAngle,
            endAngle: startAngle + sweepAngle,
            colors: [color.withValues(alpha: 0.55), color],
          ).createShader(
              Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.progress != progress;
}
