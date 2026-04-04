import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// A premium neumorphic health score card with animated gradient progress ring.
/// Customized from a neumorphic circle component for the MedAssist Health Dashboard.
class NeumorphicHealthScoreCard extends StatefulWidget {
  final int score; // 0–100
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const NeumorphicHealthScoreCard({
    super.key,
    required this.score,
    this.label = 'Health Score',
    this.subtitle = 'Computed from Health Connect data',
    this.onTap,
  });

  @override
  State<NeumorphicHealthScoreCard> createState() =>
      _NeumorphicHealthScoreCardState();
}

class _NeumorphicHealthScoreCardState extends State<NeumorphicHealthScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(NeumorphicHealthScoreCard old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Score → label
  String get _scoreLabel {
    if (widget.score >= 80) return 'Excellent';
    if (widget.score >= 60) return 'Good';
    if (widget.score >= 40) return 'Fair';
    return 'Needs Attention';
  }

  // Score → icon
  IconData get _scoreIcon {
    if (widget.score >= 80) return Icons.emoji_events_rounded;
    if (widget.score >= 60) return Icons.thumb_up_alt_rounded;
    if (widget.score >= 40) return Icons.info_outline_rounded;
    return Icons.warning_amber_rounded;
  }

  // Score → gradient colors
  List<Color> get _ringColors {
    if (widget.score >= 80)
      return const [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)];
    if (widget.score >= 60)
      return const [Color(0xFFF1DA95), Color(0xFFFBBF24), Color(0xFFF59E0B)];
    if (widget.score >= 40)
      return const [Color(0xFFFBBF24), Color(0xFFF97316), Color(0xFFEF4444)];
    return const [Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFDC2626)];
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF1E2328);
    const shadowColor = Color(0xFF0A0D10);
    final highlightColor = Colors.white.withValues(alpha: 0.04);

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor.withValues(alpha: 0.92),
                  const Color(0xFF262B30).withValues(alpha: 0.88),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.5),
                  offset: const Offset(6, 6),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: highlightColor,
                  offset: const Offset(-4, -4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Neumorphic Score Ring ─────────────────────────
                SizedBox(
                  width: 120,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, _) {
                      return _NeumorphicScoreRing(
                        score: widget.score,
                        progress: _progressAnim.value,
                        bgColor: bgColor,
                        shadowColor: shadowColor,
                        highlightColor: highlightColor,
                        ringColors: _ringColors,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),

                // ── Score Info ────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _ringColors.take(2).toList(),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _scoreIcon,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _scoreLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _ringColors[1],
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.45),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Mini breakdown bar
                      _MiniBreakdownBar(
                        score: widget.score,
                        colors: _ringColors,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Neumorphic Score Ring ─────────────────────────────────────────────────────
class _NeumorphicScoreRing extends StatelessWidget {
  final int score;
  final double progress;
  final Color bgColor;
  final Color shadowColor;
  final Color highlightColor;
  final List<Color> ringColors;

  const _NeumorphicScoreRing({
    required this.score,
    required this.progress,
    required this.bgColor,
    required this.shadowColor,
    required this.highlightColor,
    required this.ringColors,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer neumorphic inset circle
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            gradient: RadialGradient(
              colors: [bgColor, bgColor.withValues(alpha: 0.9)],
              center: const AlignmentDirectional(-0.2, -0.2),
              radius: 0.7,
            ),
          ),
          child: Stack(
            children: [
              // Inner shadow (top-left highlight)
              ClipPath(
                clipper: _DiagonalClipper(topLeftToBottomRight: false),
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
              // Inner shadow (bottom-right shadow)
              ClipPath(
                clipper: _DiagonalClipper(topLeftToBottomRight: true),
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

        // ── Gradient Progress Ring ──
        SizedBox.expand(
          child: CustomPaint(
            painter: _HealthRingPainter(
              progress: (score / 100.0) * progress,
              colors: ringColors,
              strokeWidthFactor: 0.12,
            ),
          ),
        ),

        // ── Inner elevated circle with score ──
        LayoutBuilder(
          builder: (context, c) {
            final size = c.maxWidth * 0.48;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                boxShadow: [
                  BoxShadow(
                    color: highlightColor,
                    offset: const Offset(-3, -3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.7),
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${(score * progress).toInt()}',
                    key: ValueKey(score),
                    style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.w900,
                      color: ringColors[1],
                      letterSpacing: -1,
                      shadows: [
                        Shadow(
                          color: ringColors[1].withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Progress Ring Painter ────────────────────────────────────────────────────
class _HealthRingPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidthFactor;

  _HealthRingPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidthFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * strokeWidthFactor;
    final inset = size.width * 0.16;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );

    // Background track
    canvas.drawArc(
      rect,
      vm.radians(-90),
      vm.radians(360),
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Gradient progress arc
    if (progress > 0) {
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
      final cx = size.width / 2 + radius * cos(angle);
      final cy = size.height / 2 + radius * sin(angle);

      canvas.drawCircle(
        Offset(cx, cy),
        strokeWidth * 0.6,
        Paint()
          ..color = colors.last.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        strokeWidth * 0.3,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_HealthRingPainter old) =>
      old.progress != progress || old.strokeWidthFactor != strokeWidthFactor;
}

// ── Diagonal Clipper for neumorphic inner shadows ────────────────────────────
class _DiagonalClipper extends CustomClipper<Path> {
  final bool topLeftToBottomRight;
  _DiagonalClipper({required this.topLeftToBottomRight});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (topLeftToBottomRight) {
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

// ── Mini Breakdown Bar ──────────────────────────────────────────────────────
class _MiniBreakdownBar extends StatelessWidget {
  final int score;
  final List<Color> colors;

  const _MiniBreakdownBar({required this.score, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$score/100',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors[1],
              ),
            ),
            const Spacer(),
            Text(
              'Overall',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 100.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(colors: colors),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
