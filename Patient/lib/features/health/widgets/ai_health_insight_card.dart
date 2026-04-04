import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class AiHealthInsightCard extends StatelessWidget {
  final String? overallAssessment;
  final List<String> riskFlags;
  final List<String> recommendations;
  final String trendDirection;
  final String? priorityMetric;
  final bool isLoading;
  final VoidCallback? onAnalyze;

  const AiHealthInsightCard({
    super.key,
    this.overallAssessment,
    this.riskFlags = const [],
    this.recommendations = const [],
    this.trendDirection = 'stable',
    this.priorityMetric,
    this.isLoading = false,
    this.onAnalyze,
  });

  IconData get _trendIcon {
    switch (trendDirection) {
      case 'improving':
        return Icons.trending_up_rounded;
      case 'declining':
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }

  Color get _trendColor {
    switch (trendDirection) {
      case 'improving':
        return const Color(0xFF10B981);
      case 'declining':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return GlassCard(
        radius: 20,
        blur: 14,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
            ),
            const SizedBox(width: 12),
            Text(
              'AI is analyzing your health data...',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (overallAssessment == null || overallAssessment!.isEmpty) {
      return GlassCard(
        radius: 20,
        blur: 14,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFF6366F1), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Health Intelligence',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sync your health data to get AI-powered insights',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onAnalyze != null)
              FilledButton.tonal(
                onPressed: onAnalyze,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(60, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Analyze', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      );
    }

    return GlassCard(
      radius: 20,
      blur: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.2),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF6366F1), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Health Intelligence',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _trendColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_trendIcon, color: _trendColor, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      trendDirection.substring(0, 1).toUpperCase() + trendDirection.substring(1),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _trendColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Assessment
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              overallAssessment!,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.textPrimary,
              ),
            ),
          ),

          // Risk flags
          if (riskFlags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: riskFlags.map((flag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      flag.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.lightbulb_outline_rounded,
                        color: Color(0xFFF59E0B), size: 14),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          // Priority metric
          if (priorityMetric != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.priority_high_rounded, color: Color(0xFF6366F1), size: 14),
                const SizedBox(width: 4),
                Text(
                  'Focus on: ',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                  ),
                ),
                Text(
                  priorityMetric!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ],

          // Re-analyze button
          if (onAnalyze != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAnalyze,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Re-analyze', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
