import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Inline card rendering likely conditions from existing parsed response.
/// Reads `conditions` list from ChatState.lastResult. Pure UI widget.
class ConditionConfidenceCard extends StatelessWidget {
  /// Each condition map expected to have: name, confidence, severity, reason
  final List<dynamic> conditions;

  const ConditionConfidenceCard({super.key, required this.conditions});

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassCard(
        radius: 16,
        blur: 12,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                        width: 0.6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.biotech_rounded,
                          size: 11, color: Color(0xFFF59E0B)),
                      SizedBox(width: 3),
                      Text('Likely Conditions',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                Text('${conditions.length} identified',
                    style: TextStyle(fontSize: 10, color: textSub)),
              ],
            ),
            const SizedBox(height: 10),

            // Condition cards
            ...conditions.take(5).map((c) {
              final map = c is Map<String, dynamic> ? c : <String, dynamic>{};
              final name = map['name']?.toString() ?? map['condition']?.toString() ?? 'Unknown';
              final confidence = (map['confidence'] ?? map['probability'] ?? 0);
              final confValue = confidence is num
                  ? confidence.toDouble()
                  : double.tryParse(confidence.toString()) ?? 0;
              final severity = map['severity']?.toString() ?? '';
              final reason = map['reason']?.toString() ?? map['explanation']?.toString() ?? '';

              final confPct = confValue > 1 ? confValue : confValue * 100;
              final confColor = confPct >= 70
                  ? const Color(0xFFEF4444)
                  : confPct >= 40
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary)),
                        ),
                        // Confidence badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: confColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: confColor.withValues(alpha: 0.30),
                                width: 0.6),
                          ),
                          child: Text(
                            '${confPct.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: confColor),
                          ),
                        ),
                      ],
                    ),
                    if (severity.isNotEmpty || reason.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (severity.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(severity,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: textSub,
                                      fontWeight: FontWeight.w600)),
                            ),
                          if (reason.isNotEmpty)
                            Expanded(
                              child: Text(reason,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 10, color: textSub)),
                            ),
                        ],
                      ),
                    ],
                    // Confidence bar
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (confPct / 100).clamp(0.0, 1.0),
                        minHeight: 3,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation(confColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
