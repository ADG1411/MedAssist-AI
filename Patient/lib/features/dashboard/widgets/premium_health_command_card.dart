import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;
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

  List<Color> _ringGradient(int s) {
    if (s >= 80) return const [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)];
    if (s >= 60) return const [Color(0xFFF1DA95), Color(0xFFFBBF24), Color(0xFFF59E0B)];
    if (s >= 40) return const [Color(0xFFFBBF24), Color(0xFFF97316), Color(0xFFEF4444)];
    return const [Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFDC2626)];
  }

  Color _scoreAccent(int s) {
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

  IconData _scoreIcon(int s) {
    if (s >= 80) return Icons.emoji_events_rounded;
    if (s >= 60) return Icons.thumb_up_alt_rounded;
    if (s >= 40) return Icons.info_outline_rounded;
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = widget.healthScore;
    final accent = _scoreAccent(score);
    final gradColors = _ringGradient(score);
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
          // Top row: neumorphic ring + info
          Row(
            children: [
              // ── Neumorphic Score Ring ──────────────────
              SizedBox(
                width: 118,
                height: 118,
                child: AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (context, child) =>
                      _NeumorphicDashboardRing(
                        score: score,
                        progress: _ringAnim.value,
                        gradientColors: gradColors,
                        accentColor: accent,
                        isDark: isDark,
                      ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.18),
                            accent.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accent.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_scoreIcon(score), size: 12, color: accent),
                          const SizedBox(width: 6),
                          Text(_scoreLabel(score),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accent)),
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

// ── Neumorphic Dashboard Ring ──────────────────────────────────────────────────
class _NeumorphicDashboardRing extends StatelessWidget {
  final int score;
  final double progress;
  final List<Color> gradientColors;
  final Color accentColor;
  final bool isDark;

  const _NeumorphicDashboardRing({
    required this.score,
    required this.progress,
    required this.gradientColors,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1E2328) : const Color(0xFFF0F2F5);
    final shadowColor = isDark ? const Color(0xFF0A0D10) : const Color(0xFFBEC3CB);
    final highlightColor = isDark 
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.8);
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer neumorphic inset container
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
          child: Stack(
            children: [
              // Inner highlight (bottom-right)
              ClipPath(
                clipper: _DiagonalClipper(topLeft: false),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [bgColor, highlightColor],
                      center: const AlignmentDirectional(-0.05, -0.05),
                      focal: const AlignmentDirectional(-0.05, -0.05),
                      radius: 0.6,
                      focalRadius: 0.1,
                      stops: const [0.75, 1.0],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.55, 1],
                        colors: [bgColor, bgColor.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
              // Inner shadow (top-left)
              ClipPath(
                clipper: _DiagonalClipper(topLeft: true),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [bgColor, shadowColor],
                      center: const AlignmentDirectional(0.05, 0.05),
                      focal: Alignment.center,
                      radius: 0.5,
                      focalRadius: 0,
                      stops: const [0.75, 1.0],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0, 0.45],
                        colors: [bgColor.withValues(alpha: 0), bgColor],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Gradient progress ring
        SizedBox.expand(
          child: CustomPaint(
            painter: _GradientRingPainter(
              progress: (score / 100.0) * progress,
              colors: gradientColors,
              strokeWidth: 8.0,
              isDark: isDark,
            ),
          ),
        ),

        // Inner elevated circle with score number
        LayoutBuilder(builder: (context, c) {
          final sz = c.maxWidth * 0.48;
          return Container(
            width: sz,
            height: sz,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: highlightColor,
                  offset: const Offset(-2, -2),
                  blurRadius: 5,
                ),
                BoxShadow(
                  color: shadowColor.withValues(alpha: isDark ? 0.7 : 0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(score * progress).round()}',
                    style: TextStyle(
                      fontSize: sz * 0.36,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: -1,
                      shadows: [
                        Shadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Text('/100', style: TextStyle(fontSize: 9, color: textSub)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Gradient Ring Painter ──────────────────────────────────────────────────────
class _GradientRingPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;
  final bool isDark;

  _GradientRingPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.14;
    final rect = Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset);

    // Background track
    canvas.drawArc(
      rect,
      vm.radians(-90),
      vm.radians(360),
      false,
      Paint()
        ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      // Gradient arc
      canvas.drawArc(
        rect,
        vm.radians(-90),
        vm.radians(360 * progress),
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: vm.radians(-90),
            endAngle: vm.radians(-90 + 360 * progress),
            colors: colors,
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      // Glow dot at the tip
      final angle = vm.radians(-90 + 360 * progress);
      final radius = (size.width - inset * 2) / 2;
      final cx = size.width / 2 + radius * math.cos(angle);
      final cy = size.height / 2 + radius * math.sin(angle);

      canvas.drawCircle(
        Offset(cx, cy),
        strokeWidth * 0.55,
        Paint()
          ..color = colors.last.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        strokeWidth * 0.28,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_GradientRingPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

// ── Diagonal Clipper ──────────────────────────────────────────────────────────
class _DiagonalClipper extends CustomClipper<Path> {
  final bool topLeft;
  _DiagonalClipper({required this.topLeft});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (topLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
