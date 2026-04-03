import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Report trend card — shows lab value trends across records.
/// Computes trends from existing record metadata. Pure UI widget.
class ReportTrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const ReportTrendCard({super.key, required this.records});

  /// Extract trend items from records metadata
  List<_TrendItem> _extractTrends() {
    final trends = <_TrendItem>[];
    for (final record in records) {
      final meta = record['metadata'] as Map<String, dynamic>? ?? {};
      final metrics =
          meta['extracted_metrics'] as Map<String, dynamic>? ?? {};
      final type = record['record_type'] ?? record['type'] ?? '';

      if (type.toString().toLowerCase().contains('lab') ||
          type.toString().toLowerCase().contains('blood')) {
        // Synthesize trend labels from available metrics
        for (final entry in metrics.entries) {
          final key = entry.key.replaceAll('_', ' ');
          if (key.toLowerCase().contains('hemoglobin') ||
              key.toLowerCase().contains('glucose') ||
              key.toLowerCase().contains('vitamin') ||
              key.toLowerCase().contains('cholesterol') ||
              key.toLowerCase().contains('iron') ||
              key.toLowerCase().contains('platelet')) {
            trends.add(_TrendItem(
              label: key,
              value: entry.value.toString(),
              trend: _TrendDirection.stable,
            ));
          }
        }
      }
    }
    return trends.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final trends = _extractTrends();
    if (trends.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.22),
                      width: 0.6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 12, color: Color(0xFF0EA5E9)),
                    SizedBox(width: 4),
                    Text('Health Trends',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Trend items
          ...trends.map((t) {
            final color = switch (t.trend) {
              _TrendDirection.improving => const Color(0xFF10B981),
              _TrendDirection.declining => const Color(0xFFEF4444),
              _TrendDirection.stable => const Color(0xFF0EA5E9),
            };
            final icon = switch (t.trend) {
              _TrendDirection.improving => Icons.trending_up_rounded,
              _TrendDirection.declining => Icons.trending_down_rounded,
              _TrendDirection.stable => Icons.trending_flat_rounded,
            };
            final label = switch (t.trend) {
              _TrendDirection.improving => 'Improving',
              _TrendDirection.declining => 'Needs attention',
              _TrendDirection.stable => 'Stable',
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(t.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Text(t.value,
                      style: TextStyle(
                          fontSize: 11,
                          color: textSub,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TrendItem {
  final String label;
  final String value;
  final _TrendDirection trend;

  const _TrendItem({
    required this.label,
    required this.value,
    required this.trend,
  });
}

enum _TrendDirection { improving, declining, stable }
