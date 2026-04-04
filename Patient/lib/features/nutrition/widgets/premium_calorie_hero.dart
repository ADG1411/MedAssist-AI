import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/intake_entry.dart';

/// Premium daily calorie ring hero card for the nutrition diary.
class PremiumCalorieHero extends StatefulWidget {
  final DailySummary summary;
  final int aiMealScore;

  const PremiumCalorieHero({
    super.key,
    required this.summary,
    this.aiMealScore = 0,
  });

  @override
  State<PremiumCalorieHero> createState() => _PremiumCalorieHeroState();
}

class _PremiumCalorieHeroState extends State<PremiumCalorieHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(PremiumCalorieHero old) {
    super.didUpdateWidget(old);
    if (old.summary != widget.summary) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.summary;
    final remaining = s.caloriesRemaining.clamp(0, s.calorieGoal);
    final progress = s.calorieProgress.clamp(0.0, 1.0);
    final overGoal = s.caloriesLogged > s.calorieGoal;

    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return GlassCard(
      radius: 24,
      blur: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Ring row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Eaten
              _StatColumn(
                label: 'Eaten',
                value: s.caloriesLogged.toInt().toString(),
                unit: 'kcal',
                color: AppColors.primary,
                isDark: isDark,
              ),

              // Center ring
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (_, __) => _CalorieRing(
                  progress: progress * _ringAnim.value,
                  remaining: remaining.toInt(),
                  overGoal: overGoal,
                  isDark: isDark,
                ),
              ),

              // Burned
              _StatColumn(
                label: 'Burned',
                value: s.activityBurnLogged.toInt().toString(),
                unit: 'kcal',
                color: const Color(0xFF10B981),
                isDark: isDark,
                alignEnd: true,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Macro progress bars ───────────────────────────────────────
          Row(
            children: [
              _MacroProgress(
                label: 'Protein',
                logged: s.proteinLogged,
                goal: s.proteinGoal,
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _MacroProgress(
                label: 'Carbs',
                logged: s.carbsLogged,
                goal: s.carbsGoal,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _MacroProgress(
                label: 'Fat',
                logged: s.fatLogged,
                goal: s.fatGoal,
                color: const Color(0xFFEF4444),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── AI Score + goal row ───────────────────────────────────────
          Row(
            children: [
              // AI Meal Score
              if (widget.aiMealScore > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 11, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('AI Score ${widget.aiMealScore}/100',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Sodium warning
              if (_hasSodiumWarning(s)) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                        width: 0.6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_rounded,
                          size: 10, color: Color(0xFFEF4444)),
                      SizedBox(width: 4),
                      Text('High Sodium',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Text(
                'Goal: ${s.calorieGoal.toInt()} kcal',
                style: TextStyle(fontSize: 11, color: textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasSodiumWarning(DailySummary s) => false; // placeholder
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _CalorieRing extends StatelessWidget {
  final double progress;
  final int remaining;
  final bool overGoal;
  final bool isDark;

  const _CalorieRing({
    required this.progress,
    required this.remaining,
    required this.overGoal,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = overGoal ? const Color(0xFFEF4444) : AppColors.primary;
    return SizedBox(
      width: 126,
      height: 126,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          color: ringColor,
          trackColor: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          strokeWidth: 11,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remaining.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: overGoal
                      ? const Color(0xFFEF4444)
                      : AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              Text(
                overGoal ? 'over' : 'kcal left',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.50)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;
  final bool alignEnd;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: textSub)),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(unit, style: TextStyle(fontSize: 10, color: textSub)),
      ],
    );
  }
}

class _MacroProgress extends StatelessWidget {
  final String label;
  final double logged;
  final double goal;
  final Color color;
  final bool isDark;

  const _MacroProgress({
    required this.label,
    required this.logged,
    required this.goal,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (logged / goal).clamp(0.0, 1.0) : 0.0;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 10, color: textSub)),
              Text('${logged.toInt()}/${goal.toInt()}g',
                  style: TextStyle(
                      fontSize: 9,
                      color: textPrimary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
