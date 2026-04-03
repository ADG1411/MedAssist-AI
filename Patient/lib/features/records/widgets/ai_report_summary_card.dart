import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// AI Report Summary Card — shows AI-generated summary, extracted metrics,
/// confidence badge, and abnormal value highlights for a single record.
class AiReportSummaryCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const AiReportSummaryCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final metadata = record['metadata'] as Map<String, dynamic>? ?? {};
    final aiSummary = metadata['ai_summary']?.toString() ?? '';
    final metrics =
        metadata['extracted_metrics'] as Map<String, dynamic>? ?? {};
    final confidence = (metadata['confidence'] ?? 0).toDouble();
    final processedBy = metadata['processed_by']?.toString() ?? '';

    if (aiSummary.isEmpty && metrics.isEmpty) return const SizedBox.shrink();

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
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('AI Analysis',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              if (confidence > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: 0.25),
                        width: 0.6),
                  ),
                  child: Text(
                    '${(confidence * 100).toStringAsFixed(0)}% confidence',
                    style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // AI Summary text
          if (aiSummary.isNotEmpty)
            Text(aiSummary,
                style: TextStyle(
                    fontSize: 13, color: textPrimary, height: 1.45)),

          // Extracted metrics
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 0.6),
              ),
              child: Column(
                children: metrics.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              color: textSub,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3),
                        ),
                        Text(
                          e.value.toString(),
                          style: TextStyle(
                              fontSize: 11,
                              color: textPrimary,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // Processed by
          if (processedBy.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.memory_rounded, size: 11, color: textSub),
                const SizedBox(width: 4),
                Text('Processed by $processedBy',
                    style: TextStyle(fontSize: 9, color: textSub)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
