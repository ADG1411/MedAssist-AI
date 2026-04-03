import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Sticky clinical context card — pinned below header while scrolling.
/// Displays body region, severity, duration, symptoms, risk label from
/// existing [SymptomCheckState] and [ChatState]. Pure UI — no backend edits.
class ClinicalCaseSummaryCard extends StatelessWidget {
  final String bodyRegion;
  final List<String> symptoms;
  final double severity;
  final String duration;
  final int riskScore;
  final String specialization;
  final String action;
  final List<String> chronicConditions;
  final VoidCallback? onSeverityTap;

  const ClinicalCaseSummaryCard({
    super.key,
    required this.bodyRegion,
    this.symptoms = const [],
    this.severity = 5,
    this.duration = '',
    this.riskScore = 0,
    this.specialization = 'General Physician',
    this.action = 'monitor',
    this.chronicConditions = const [],
    this.onSeverityTap,
  });

  Color _severityColor() {
    if (severity <= 3) return const Color(0xFF10B981);
    if (severity <= 6) return const Color(0xFFF59E0B);
    if (severity <= 8) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  String _severityLabel() {
    if (severity <= 3) return 'Mild';
    if (severity <= 6) return 'Moderate';
    if (severity <= 8) return 'Severe';
    return 'Critical';
  }

  Color _riskColor() {
    if (riskScore <= 25) return const Color(0xFF10B981);
    if (riskScore <= 50) return const Color(0xFFF59E0B);
    if (riskScore <= 75) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  String _riskLabel() {
    if (riskScore <= 25) return 'Low Risk';
    if (riskScore <= 50) return 'Moderate';
    if (riskScore <= 75) return 'Elevated';
    return 'High Risk';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;
    final sevColor = _severityColor();

    return GlassCard(
      radius: 18,
      blur: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: region + severity + risk ──────────────────────
          Row(
            children: [
              // Body region chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.06),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 0.7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(bodyRegion,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Severity pill
              GestureDetector(
                onTap: onSeverityTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sevColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sevColor.withValues(alpha: 0.30), width: 0.7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed_rounded, size: 12, color: sevColor),
                      const SizedBox(width: 3),
                      Text(
                        '${severity.toInt()}/10 ${_severityLabel()}',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: sevColor),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Risk badge
              if (riskScore > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _riskColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _riskColor().withValues(alpha: 0.30),
                        width: 0.7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded,
                          size: 11, color: _riskColor()),
                      const SizedBox(width: 3),
                      Text(_riskLabel(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _riskColor())),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Symptom chips ─────────────────────────────────────────
          if (symptoms.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: symptoms
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 10,
                                color: textSub,
                                fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),

          // ── Bottom row: duration + specialization + chronic ───────
          if (duration.isNotEmpty ||
              specialization != 'General Physician' ||
              chronicConditions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (duration.isNotEmpty) ...[
                  Icon(Icons.schedule_rounded, size: 11, color: textSub),
                  const SizedBox(width: 3),
                  Text(duration,
                      style: TextStyle(fontSize: 10, color: textSub)),
                  const SizedBox(width: 10),
                ],
                if (specialization != 'General Physician') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(specialization,
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 6),
                ],
                if (chronicConditions.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color:
                              const Color(0xFFF97316).withValues(alpha: 0.25),
                          width: 0.6),
                    ),
                    child: Text(
                      '${chronicConditions.length} chronic',
                      style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
