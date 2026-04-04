import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class RecoveryMissionStory extends StatelessWidget {
  final Map<String, dynamic> data;
  const RecoveryMissionStory({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recoveryScore = (data['recovery_score'] as num?)?.toInt() ?? 70;
    final velocity = (data['recovery_velocity'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [70, 72, 71, 75, 76];
    final trending =
        velocity.length >= 2 && velocity.last > velocity[velocity.length - 2];
    final aiResult = data['latest_ai_result'] as Map<String, dynamic>?;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashSectionLabel('🌱 Recovery Mission', 'Your healing journey'),
        const SizedBox(height: 10),
        GlassCard(
          radius: 24,
          blur: 20,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score + trend chart row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recovery Score',
                            style:
                                TextStyle(fontSize: 12, color: textSub)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$recoveryScore',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                                letterSpacing: -1.5,
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
                  // Trend chart
                  SizedBox(
                    width: 100,
                    height: 52,
                    child: CustomPaint(
                        painter: _TrendPainter(
                            velocity, const Color(0xFF10B981))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // AI narrative card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.20),
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
              // Milestone chips
              Row(
                children: const [
                  _Milestone('3 Day\nStreak', Icons.local_fire_department_rounded,
                      Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  _Milestone('Good\nSleep', Icons.nightlight_round,
                      Color(0xFF8B5CF6)),
                  SizedBox(width: 8),
                  _Milestone('Low\nSeverity', Icons.shield_rounded,
                      Color(0xFF10B981)),
                  SizedBox(width: 8),
                  _Milestone('Meds\nOn Time', Icons.medication_rounded,
                      Color(0xFF06B6D4)),
                ],
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
  const _Milestone(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: 0.24), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.65)
                    : AppColors.textSecondary,
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

class _TrendPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _TrendPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min).clamp(4.0, double.infinity);

    final path = Path();
    final fill = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - min) / range) * (size.height - 6) - 3;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.0)
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => false;
}
