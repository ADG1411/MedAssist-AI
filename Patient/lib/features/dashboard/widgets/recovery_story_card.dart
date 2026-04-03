import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class RecoveryStoryCard extends StatelessWidget {
  final int recoveryScore;
  final List<dynamic> velocityData;
  final VoidCallback? onViewReport;

  const RecoveryStoryCard({
    super.key,
    required this.recoveryScore,
    this.velocityData = const [],
    this.onViewReport,
  });

  Color _recoveryColor(int score) {
    if (score >= 75) return const Color(0xFF10B981);
    if (score >= 45) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _recoveryMessage(int score) {
    if (score >= 80) return 'You\'re recovering exceptionally well 🌟';
    if (score >= 65) return 'Steady progress — keep going 💪';
    if (score >= 45) return 'Recovery is on track, stay consistent';
    return 'Focus on rest and hydration today';
  }

  String _nextMilestone(int score) {
    if (score >= 90) return 'Maintain peak performance';
    if (score >= 75) return 'Reach 90% — 2 days at this pace';
    if (score >= 55) return 'Reach 75% — improve sleep tonight';
    return 'Reach 55% — hydrate & rest well';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final color = _recoveryColor(recoveryScore);

    final List<double> chartPoints = velocityData.isNotEmpty
        ? velocityData
            .take(7)
            .map((e) => (e as num).toDouble())
            .toList()
        : [42, 48, 55, 51, 63, 70, recoveryScore.toDouble()];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.auto_graph_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recovery Progress',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '7-day trend',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$recoveryScore%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      chartPoints.length,
                      (i) => FlSpot(i.toDouble(), chartPoints[i]),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: color,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        if (index == chartPoints.length - 1) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: cardBg,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 2,
                          color: color.withValues(alpha: 0.4),
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.18),
                          color.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.1 : 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _nextMilestone(recoveryScore),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _recoveryMessage(recoveryScore),
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (onViewReport != null)
                GestureDetector(
                  onTap: onViewReport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'View Report',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
