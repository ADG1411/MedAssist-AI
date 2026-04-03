import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../health/providers/health_data_provider.dart';

class LiveVitalsGlassRail extends ConsumerWidget {
  const LiveVitalsGlassRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMetrics = ref.watch(healthDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return asyncMetrics.when(
      loading: () => _buildShimmer(isDark),
      error: (e, st) => const SizedBox.shrink(),
      data: (m) {
        final vitals = [
          _VitalTile(
            label: 'Heart',
            value: m.heartRate > 0 ? '${m.heartRate.toInt()}' : '--',
            unit: 'bpm',
            icon: Icons.favorite_rounded,
            color: const Color(0xFFEF4444),
            riskColor: _risk(m.heartRate, 60, 100),
            spark: [68, 72, 75, 70, m.heartRate],
          ),
          _VitalTile(
            label: 'Steps',
            value: _fmt(m.steps),
            unit: 'today',
            icon: Icons.directions_walk_rounded,
            color: const Color(0xFF6366F1),
            riskColor: _risk(m.steps.toDouble(), 5000, 10000),
            spark: [4000, 5200, 6000, 5800, m.steps.toDouble()],
          ),
          _VitalTile(
            label: 'Sleep',
            value: m.sleepHours > 0 ? m.sleepHours.toStringAsFixed(1) : '--',
            unit: 'hrs',
            icon: Icons.nightlight_round,
            color: const Color(0xFF8B5CF6),
            riskColor: _risk(m.sleepHours, 6, 9),
            spark: [6.5, 7.0, 6.2, 7.5, m.sleepHours],
          ),
          _VitalTile(
            label: 'SpO₂',
            value: m.bloodOxygen > 0 ? '${m.bloodOxygen.toInt()}' : '--',
            unit: '%',
            icon: Icons.air_rounded,
            color: const Color(0xFF06B6D4),
            riskColor: _risk(m.bloodOxygen, 95, 100),
            spark: [97, 98, 97.5, 96, m.bloodOxygen],
          ),
          _VitalTile(
            label: 'Calories',
            value: '${m.caloriesBurned.toInt()}',
            unit: 'kcal',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFF59E0B),
            riskColor: _risk(m.caloriesBurned, 200, 600),
            spark: [180, 250, 320, 280, m.caloriesBurned],
          ),
          const _VitalTile(
            label: 'Hydration',
            value: '6',
            unit: 'cups',
            icon: Icons.water_drop_rounded,
            color: Color(0xFF3B82F6),
            riskColor: Color(0xFF3B82F6),
            spark: [4, 5, 6, 5.5, 6.0],
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashSectionLabel('📊 Live Vitals', 'Real-time body metrics'),
            const SizedBox(height: 10),
            SizedBox(
              height: 122,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemCount: vitals.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) =>
                    _VitalCard(tile: vitals[index], isDark: isDark),
              ),
            ),
          ],
        );
      },
    );
  }

  static Color _risk(double val, double lo, double hi) {
    if (val <= 0) return const Color(0xFF94A3B8);
    return (val >= lo && val <= hi)
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
  }

  static String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  Widget _buildShimmer(bool isDark) => SizedBox(
        height: 122,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) => Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.50),
            ),
          ),
        ),
      );
}

class _VitalTile {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final Color riskColor;
  final List<double> spark;
  const _VitalTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.riskColor,
    required this.spark,
  });
}

class _VitalCard extends StatelessWidget {
  final _VitalTile tile;
  final bool isDark;
  const _VitalCard({required this.tile, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      blur: 16,
      child: SizedBox(
        width: 100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(tile.icon, size: 13, color: tile.color),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tile.riskColor,
                      boxShadow: [
                        BoxShadow(
                            color: tile.riskColor.withValues(alpha: 0.55),
                            blurRadius: 5)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: tile.value,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: ' ${tile.unit}',
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(tile.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.50)
                        : AppColors.textSecondary,
                  )),
              const Spacer(),
              SizedBox(
                height: 20,
                child: CustomPaint(
                    painter: _SparklinePainter(tile.spark, tile.riskColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min).clamp(1.0, double.infinity);
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - min) / range) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => false;
}
