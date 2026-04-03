import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Donut chart showing macro distribution (carbs / fat / protein / fiber).
class MacroDonutWidget extends StatelessWidget {
  final double carbs;
  final double fat;
  final double protein;
  final double fiber;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const MacroDonutWidget({
    super.key,
    required this.carbs,
    required this.fat,
    required this.protein,
    this.fiber = 0,
    this.size = 110,
    this.strokeWidth = 11,
    this.center,
  });

  static const _carbColor    = Color(0xFFF59E0B);
  static const _fatColor     = Color(0xFFEF4444);
  static const _proteinColor = Color(0xFF10B981);
  static const _fiberColor   = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = carbs + fat + protein + fiber;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(
              values: total > 0
                  ? [carbs / total, fat / total, protein / total, fiber / total]
                  : [0.25, 0.25, 0.25, 0.25],
              colors: const [_carbColor, _fatColor, _proteinColor, _fiberColor],
              strokeWidth: strokeWidth,
              trackColor: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: center != null
                ? Center(child: center!)
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(carbs + fat + protein + fiber).toInt()}',
                          style: TextStyle(
                            fontSize: size * 0.16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: size * 0.10,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.50)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _Legend('Carbs', '${carbs.toInt()}g', _carbColor),
            _Legend('Fat', '${fat.toInt()}g', _fatColor),
            _Legend('Protein', '${protein.toInt()}g', _proteinColor),
            if (fiber > 0) _Legend('Fiber', '${fiber.toInt()}g', _fiberColor),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Legend(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $value',
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? Colors.white.withValues(alpha: 0.60)
                : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final Color trackColor;

  const _DonutPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    const startAngle = -pi / 2;
    const gap = 0.04;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    double current = startAngle;
    final totalGap = gap * values.length;
    final availableSweep = 2 * pi - totalGap;

    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] * availableSweep;
      if (sweep <= 0) {
        current += gap;
        continue;
      }
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        current,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      current += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}
