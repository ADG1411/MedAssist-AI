import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class PremiumHealthScoreHero extends StatefulWidget {
  final int score;
  final String insightText;

  const PremiumHealthScoreHero({
    super.key,
    required this.score,
    this.insightText = 'Hydration and nutrition compliance improved your score',
  });

  @override
  State<PremiumHealthScoreHero> createState() => _PremiumHealthScoreHeroState();
}

class _PremiumHealthScoreHeroState extends State<PremiumHealthScoreHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _expanded = false;

  final List<_BreakdownItem> _breakdown = [
    _BreakdownItem('Symptoms Impact', 0.72, Icons.monitor_heart_outlined),
    _BreakdownItem('Sleep Score', 0.58, Icons.bedtime_outlined),
    _BreakdownItem('Hydration', 0.85, Icons.water_drop_outlined),
    _BreakdownItem('Nutrition Safety', 0.66, Icons.eco_outlined),
    _BreakdownItem('Medication Adherence', 0.90, Icons.medication_outlined),
    _BreakdownItem('Recovery Trend', 0.75, Icons.trending_up_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PremiumHealthScoreHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score / 100.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _scoreColor(int s) {
    if (s >= 71) return const Color(0xFF10B981);
    if (s >= 41) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _scoreColorDim(int s) {
    if (s >= 71) return const Color(0xFF064E3B);
    if (s >= 41) return const Color(0xFF78350F);
    return const Color(0xFF7F1D1D);
  }

  String _scoreLabel(int s) {
    if (s >= 85) return 'Excellent';
    if (s >= 71) return 'Good';
    if (s >= 41) return 'Watch';
    return 'Critical';
  }

  String _scoreSublabel(int s) {
    if (s >= 85) return 'Keep it up!';
    if (s >= 71) return 'On track';
    if (s >= 41) return 'Needs attention';
    return 'Take action now';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme tokens
    final cardBg = isDark
        ? const Color(0xFF0D1B2A)
        : Colors.white.withValues(alpha: 0.78);
    final cardBg2 = isDark
        ? const Color(0xFF1A2744)
        : const Color(0xFFE8F4FF).withValues(alpha: 0.82);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B);
    final insightBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFE2E8F0);
    final logoTint = isDark ? Colors.white : const Color(0xFF0F172A);
    final progressBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final current = (_animation.value * 100).toInt();
        final color = _scoreColor(current);
        final colorDim = _scoreColorDim(current);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardBg, cardBg2, cardBg],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            border: isDark
                ? null
                : Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                blurRadius: isDark ? 32 : 20,
                spreadRadius: isDark ? 2 : 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isDark ? 0 : 18,
                sigmaY: isDark ? 0 : 18,
              ),
              child: Stack(
              children: [
                // Faded logo watermark — top right
                Positioned(
                  top: -10,
                  right: -10,
                  child: Opacity(
                    opacity: isDark ? 0.055 : 0.04,
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 180,
                      colorFilter: ColorFilter.mode(
                        logoTint,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                // Score color ambient glow behind arc
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withValues(alpha: isDark ? 0.18 : 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // ── Top header bar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Row(
                        children: [
                          LiquidGlass.withOwnLayer(
                            fake: true,
                            settings: LiquidGlassSettings(
                              blur: 6,
                              thickness: 16,
                              lightIntensity: 0.5,
                              glassColor:
                                  Color.fromARGB(20, 255, 255, 255),
                            ),
                            shape: LiquidRoundedSuperellipse(
                                borderRadius: 10),
                            glassContainsChild: true,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              color: color.withValues(alpha: 0.15),
                              child: Icon(Icons.favorite_rounded,
                                  color: color, size: 16),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MedAssist Score',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'AI Health Intelligence',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          RawChip(
                            avatar: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            label: Text(
                              _scoreLabel(current),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 0.3,
                              ),
                            ),
                            backgroundColor: isDark
                                ? colorDim.withValues(alpha: 0.6)
                                : color.withValues(alpha: 0.1),
                            side: BorderSide(
                                color: color.withValues(alpha: 0.3), width: 1),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                          ),
                        ],
                      ),
                    ),

                    // ── Arc + Score ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                      child: SizedBox(
                        width: 210,
                        height: 210,
                        child: CustomPaint(
                          painter: _SegmentedArcPainter(
                            progress: _animation.value,
                            isDark: isDark,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.75)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(bounds),
                                  child: Text(
                                    '$current',
                                    style: const TextStyle(
                                      fontSize: 58,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.0,
                                      letterSpacing: -3,
                                    ),
                                  ),
                                ),
                                Text(
                                  'out of 100',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _scoreSublabel(current),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: color.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── AI Insight chip ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                      child: LiquidGlass.withOwnLayer(
                        fake: true,
                        settings: LiquidGlassSettings(
                          blur: 10,
                          thickness: 20,
                          lightIntensity: 0.4,
                          refractiveIndex: 1.1,
                          glassColor:
                              Color.fromARGB(15, 255, 255, 255),
                        ),
                        shape: LiquidRoundedRectangle(borderRadius: 14),
                        glassContainsChild: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          color: insightBg,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF6366F1),
                                    size: 13),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.insightText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Color zone pills ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _zoneChip('0–40', const Color(0xFFEF4444),
                              isDark
                                  ? const Color(0xFF7F1D1D)
                                  : const Color(0xFFFFEDED)),
                          const SizedBox(width: 8),
                          _zoneChip('41–70', const Color(0xFFF59E0B),
                              isDark
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFFFFF8E7)),
                          const SizedBox(width: 8),
                          _zoneChip('71–100', const Color(0xFF10B981),
                              isDark
                                  ? const Color(0xFF064E3B)
                                  : const Color(0xFFE8FBF5)),
                        ],
                      ),
                    ),

                    // ── Divider ──
                    Container(height: 1, color: dividerColor),

                    // ── Breakdown toggle ──
                    InkWell(
                      onTap: () => setState(() => _expanded = !_expanded),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(_expanded ? 0 : 24),
                        bottomRight: Radius.circular(_expanded ? 0 : 24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.bar_chart_rounded,
                                color: Color(0xFF6366F1), size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Health Breakdown',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const Spacer(),
                            AnimatedRotation(
                              turns: _expanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 250),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _expanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild:
                          _buildBreakdown(textPrimary, progressBg),
                      secondChild: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _zoneChip(String label, Color color, Color bg) {
    return RawChip(
      avatar: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      label: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
      backgroundColor: bg,
      side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _buildBreakdown(Color textPrimary, Color progressBg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        children: _breakdown.map((item) {
          final color = item.value >= 0.71
              ? const Color(0xFF10B981)
              : item.value >= 0.41
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFEF4444);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: color.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Icon(item.icon, size: 16, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textPrimary)),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.value,
                          minHeight: 5,
                          backgroundColor: progressBg,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(item.value * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BreakdownItem {
  final String label;
  final double value;
  final IconData icon;
  const _BreakdownItem(this.label, this.value, this.icon);
}

class _SegmentedArcPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SegmentedArcPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 10;
    const strokeWidth = 14.0;
    const gapDegrees = 3.5;
    const totalSegments = 24;
    const totalAngle = 270.0;
    const startAngle = 135.0;

    final segmentAngle =
        (totalAngle - gapDegrees * totalSegments) / totalSegments;
    final bgColor =
        isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDDE6F0);

    for (int i = 0; i < totalSegments; i++) {
      final segStart = startAngle + i * (segmentAngle + gapDegrees);
      final segProgress = (i + 1) / totalSegments;

      Color segColor;
      if (segProgress <= 0.4) {
        segColor = const Color(0xFFEF4444);
      } else if (segProgress <= 0.70) {
        segColor = const Color(0xFFF59E0B);
      } else {
        segColor = const Color(0xFF10B981);
      }

      final isFilled = progress >= (i / totalSegments);

      final paint = Paint()
        ..color = isFilled ? segColor : bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isFilled ? strokeWidth : strokeWidth - 2
        ..strokeCap = StrokeCap.round;

      if (isFilled) {
        final glowPaint = Paint()
          ..color = segColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerRadius),
          _toRad(segStart),
          _toRad(segmentAngle),
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        _toRad(segStart),
        _toRad(segmentAngle),
        false,
        paint,
      );
    }
  }

  double _toRad(double deg) => deg * pi / 180;

  @override
  bool shouldRepaint(covariant _SegmentedArcPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
