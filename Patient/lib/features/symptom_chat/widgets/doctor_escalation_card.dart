import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Inline doctor escalation CTA card — rendered when ChatState.action == 'consult_doctor'.
/// Uses existing navigation routes. Pure UI widget.
class DoctorEscalationCard extends StatelessWidget {
  final String specialization;
  final String urgency;
  final String reason;
  final Map<String, dynamic> doctorHandoff;
  final VoidCallback? onFindDoctor;
  final VoidCallback? onBookConsult;
  final VoidCallback? onShareSummary;
  final VoidCallback? onUploadReports;

  const DoctorEscalationCard({
    super.key,
    this.specialization = 'General Physician',
    this.urgency = '',
    this.reason = '',
    this.doctorHandoff = const {},
    this.onFindDoctor,
    this.onBookConsult,
    this.onShareSummary,
    this.onUploadReports,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final handoffReason =
        reason.isNotEmpty ? reason : (doctorHandoff['reason']?.toString() ?? '');
    final handoffUrgency = urgency.isNotEmpty
        ? urgency
        : (doctorHandoff['urgency']?.toString() ?? 'Recommended');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0EA5E9).withValues(alpha: 0.12),
              const Color(0xFF6366F1).withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
              width: 0.8),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Doctor Consultation Recommended',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6)
                              ]),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(specialization,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.30),
                                  width: 0.6),
                            ),
                            child: Text(handoffUrgency,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (handoffReason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(handoffReason,
                  style: TextStyle(fontSize: 12, color: textSub, height: 1.4)),
            ],

            const SizedBox(height: 12),

            // CTA buttons
            Row(
              children: [
                Expanded(
                  child: _CTAButton(
                    icon: Icons.search_rounded,
                    label: 'Find Doctor',
                    color: const Color(0xFF0EA5E9),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onFindDoctor?.call();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CTAButton(
                    icon: Icons.calendar_month_rounded,
                    label: 'Book Consult',
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onBookConsult?.call();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _CTAButton(
                    icon: Icons.share_rounded,
                    label: 'Share Summary',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onShareSummary?.call();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CTAButton(
                    icon: Icons.upload_file_rounded,
                    label: 'Upload Reports',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onUploadReports?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _CTAButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: color.withValues(alpha: 0.25), width: 0.7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
