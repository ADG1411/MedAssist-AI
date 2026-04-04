import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Post-analysis summary card — rendered after final diagnosis response.
/// Displays likely causes, risk, recommended doctor, care steps, recovery ETA,
/// medication hints, food/movement precautions from existing ChatState.lastResult.
/// Pure UI widget.
class DiagnosisOutcomeCard extends StatelessWidget {
  final Map<String, dynamic>? lastResult;
  final List<dynamic> conditions;
  final int riskScore;
  final String specialization;
  final List<dynamic> prescriptionHints;
  final Map<String, dynamic> monitoringPlan;
  final VoidCallback? onViewFullResults;

  const DiagnosisOutcomeCard({
    super.key,
    this.lastResult,
    this.conditions = const [],
    this.riskScore = 0,
    this.specialization = 'General Physician',
    this.prescriptionHints = const [],
    this.monitoringPlan = const {},
    this.onViewFullResults,
  });

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty && prescriptionHints.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final careSteps =
        lastResult?['care_steps'] as List<dynamic>? ?? [];
    final recoveryEta =
        lastResult?['recovery_eta']?.toString() ?? '';
    final foodPrecautions =
        lastResult?['food_precautions'] as List<dynamic>? ?? [];
    final movementPrecautions =
        lastResult?['movement_precautions'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.10),
              const Color(0xFF0EA5E9).withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.22),
              width: 0.8),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF0EA5E9)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Analysis Summary',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary)),
                      Text('Based on symptom conversation',
                          style: TextStyle(fontSize: 10, color: textSub)),
                    ],
                  ),
                ),
                if (riskScore > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _riskColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _riskColor().withValues(alpha: 0.30),
                          width: 0.6),
                    ),
                    child: Text('Risk $riskScore%',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _riskColor())),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Likely causes ───────────────────────────────────────
            if (conditions.isNotEmpty) ...[
              _SectionHeader('Likely Causes', Icons.biotech_rounded,
                  const Color(0xFFF59E0B)),
              const SizedBox(height: 6),
              ...conditions.take(3).map((c) {
                final name = c is Map
                    ? (c['name']?.toString() ?? c['condition']?.toString() ?? 'Unknown')
                    : c.toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(name,
                            style: TextStyle(
                                fontSize: 12,
                                color: textPrimary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],

            // ── Recommended Doctor ──────────────────────────────────
            if (specialization != 'General Physician') ...[
              _SectionHeader('Recommended Doctor',
                  Icons.medical_services_rounded, const Color(0xFF6366F1)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(specialization,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
            ],

            // ── Care Steps ──────────────────────────────────────────
            if (careSteps.isNotEmpty) ...[
              _SectionHeader('Care Steps', Icons.healing_rounded,
                  const Color(0xFF10B981)),
              const SizedBox(height: 4),
              ...careSteps.take(4).map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                                color: Color(0xFF10B981), fontSize: 12)),
                        Expanded(
                          child: Text(step.toString(),
                              style: TextStyle(
                                  fontSize: 11, color: textSub, height: 1.3)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
            ],

            // ── Medication hints ────────────────────────────────────
            if (prescriptionHints.isNotEmpty) ...[
              _SectionHeader('OTC Guidance', Icons.medication_rounded,
                  const Color(0xFF0EA5E9)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: prescriptionHints.take(4).map((h) {
                  final text = h is Map
                      ? (h['name']?.toString() ?? h.toString())
                      : h.toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF0EA5E9).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: const Color(0xFF0EA5E9)
                              .withValues(alpha: 0.22),
                          width: 0.6),
                    ),
                    child: Text(text,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w600)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // ── Recovery ETA ────────────────────────────────────────
            if (recoveryEta.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 13, color: Color(0xFF10B981)),
                  const SizedBox(width: 5),
                  Text('Recovery: $recoveryEta',
                      style: TextStyle(
                          fontSize: 11,
                          color: textSub,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // ── Food precautions ────────────────────────────────────
            if (foodPrecautions.isNotEmpty) ...[
              _SectionHeader('Food Precautions',
                  Icons.restaurant_rounded, const Color(0xFFF97316)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: foodPrecautions.take(4).map((f) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(f.toString(),
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFF97316),
                              fontWeight: FontWeight.w600)),
                    )).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // ── Movement precautions ────────────────────────────────
            if (movementPrecautions.isNotEmpty) ...[
              _SectionHeader('Movement Precautions',
                  Icons.directions_run_rounded, const Color(0xFF8B5CF6)),
              const SizedBox(height: 4),
              ...movementPrecautions.take(3).map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠ ',
                            style: TextStyle(fontSize: 10)),
                        Expanded(
                          child: Text(m.toString(),
                              style: TextStyle(
                                  fontSize: 11, color: textSub, height: 1.3)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
            ],

            // ── View full results CTA ───────────────────────────────
            if (onViewFullResults != null)
              GestureDetector(
                onTap: onViewFullResults,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF0EA5E9)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_rounded,
                          size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text('View Full Analysis',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _riskColor() {
    if (riskScore <= 25) return const Color(0xFF10B981);
    if (riskScore <= 50) return const Color(0xFFF59E0B);
    if (riskScore <= 75) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(title,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }
}
