import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Emergency Readiness Center — shows SOS setup status, emergency contacts,
/// blood group, allergies, QR card, hospital preference, insurance.
/// Visual status: READY / INCOMPLETE / HIGH RISK. Pure UI widget.
class EmergencyReadinessCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback? onOpenSos;
  final VoidCallback? onOpenHealthId;

  const EmergencyReadinessCard({
    super.key,
    required this.profile,
    this.onOpenSos,
    this.onOpenHealthId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final bloodGroup = profile['blood_group']?.toString() ??
        profile['bloodGroup']?.toString() ??
        '';
    final allergies = (profile['allergies'] as List?) ?? [];
    final emergencyContacts = (profile['emergency_contacts'] as List?) ?? [];
    final hasInsurance =
        (profile['insurance']?.toString() ?? '').isNotEmpty;

    // Calculate readiness
    final checks = <_ReadinessCheck>[
      _ReadinessCheck(
          label: 'Emergency contacts',
          ready: emergencyContacts.isNotEmpty,
          icon: Icons.phone_rounded),
      _ReadinessCheck(
          label: 'Blood group',
          ready: bloodGroup.isNotEmpty && bloodGroup != '-',
          icon: Icons.water_drop_rounded),
      _ReadinessCheck(
          label: 'Allergies recorded',
          ready: allergies.isNotEmpty,
          icon: Icons.warning_amber_rounded),
      _ReadinessCheck(
          label: 'QR emergency card',
          ready: true,
          icon: Icons.qr_code_rounded),
      _ReadinessCheck(
          label: 'Insurance linked',
          ready: hasInsurance,
          icon: Icons.shield_rounded),
    ];

    final readyCount = checks.where((c) => c.ready).length;
    final readyPercent = ((readyCount / checks.length) * 100).round();
    final status = readyPercent >= 80
        ? 'READY'
        : readyPercent >= 40
            ? 'INCOMPLETE'
            : 'HIGH RISK';
    final statusColor = readyPercent >= 80
        ? const Color(0xFF10B981)
        : readyPercent >= 40
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

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
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.22),
                      width: 0.6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emergency_rounded,
                        size: 12, color: Color(0xFFEF4444)),
                    SizedBox(width: 4),
                    Text('Emergency Readiness',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.30),
                      width: 0.6),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: readyPercent / 100,
                    minHeight: 4,
                    backgroundColor: statusColor.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$readyPercent%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor)),
            ],
          ),
          const SizedBox(height: 10),

          // Checklist
          ...checks.map((check) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      check.ready
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 14,
                      color: check.ready
                          ? const Color(0xFF10B981)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Icon(check.icon, size: 12, color: textSub),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(check.label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: check.ready
                                  ? textPrimary
                                  : textSub,
                              decoration: check.ready
                                  ? null
                                  : TextDecoration.none)),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 10),

          // Action buttons
          Row(
            children: [
              if (onOpenSos != null)
                Expanded(
                  child: GestureDetector(
                    onTap: onOpenSos,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.22),
                            width: 0.6),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sos_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          SizedBox(width: 5),
                          Text('SOS Setup',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              if (onOpenSos != null && onOpenHealthId != null)
                const SizedBox(width: 8),
              if (onOpenHealthId != null)
                Expanded(
                  child: GestureDetector(
                    onTap: onOpenHealthId,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF0EA5E9)
                                .withValues(alpha: 0.22),
                            width: 0.6),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_rounded,
                              size: 14, color: Color(0xFF0EA5E9)),
                          SizedBox(width: 5),
                          Text('Health ID',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF0EA5E9),
                                  fontWeight: FontWeight.w700)),
                        ],
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

class _ReadinessCheck {
  final String label;
  final bool ready;
  final IconData icon;

  const _ReadinessCheck({
    required this.label,
    required this.ready,
    required this.icon,
  });
}
