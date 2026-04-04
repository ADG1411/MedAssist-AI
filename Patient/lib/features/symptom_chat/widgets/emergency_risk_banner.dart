import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Inline SOS emergency risk banner — rendered when ChatState.isEmergency == true.
/// Uses existing SOS navigation logic. Pure UI widget.
class EmergencyRiskBanner extends StatefulWidget {
  final String likelyCause;
  final VoidCallback? onTriggerSOS;
  final VoidCallback? onNearestHospital;
  final VoidCallback? onCallEmergencyContact;

  const EmergencyRiskBanner({
    super.key,
    this.likelyCause = '',
    this.onTriggerSOS,
    this.onNearestHospital,
    this.onCallEmergencyContact,
  });

  @override
  State<EmergencyRiskBanner> createState() => _EmergencyRiskBannerState();
}

class _EmergencyRiskBannerState extends State<EmergencyRiskBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, _) {
        final pulseAlpha = 0.10 + 0.08 * _pulseCtrl.value;
        final borderAlpha = 0.40 + 0.20 * _pulseCtrl.value;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFFEF4444).withValues(alpha: pulseAlpha),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: borderAlpha),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFEF4444,
                ).withValues(alpha: 0.15 * _pulseCtrl.value),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Risk Detected',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        if (widget.likelyCause.isNotEmpty)
                          Text(
                            widget.likelyCause,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : const Color(
                                      0xFFEF4444,
                                    ).withValues(alpha: 0.70),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                'Please seek immediate medical attention. Use the options below for quick action.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // CTA buttons
              Row(
                children: [
                  Expanded(
                    child: _SOSButton(
                      icon: Icons.sos_rounded,
                      label: 'Trigger SOS',
                      isPrimary: true,
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        widget.onTriggerSOS?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SOSButton(
                      icon: Icons.local_hospital_rounded,
                      label: 'Nearest Hospital',
                      isPrimary: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onNearestHospital?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SOSButton(
                      icon: Icons.phone_rounded,
                      label: 'Emergency Call',
                      isPrimary: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onCallEmergencyContact?.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SOSButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _SOSButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFFEF4444)
              : const Color(0xFFEF4444).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: isPrimary
              ? null
              : Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.30),
                  width: 0.7,
                ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : const Color(0xFFEF4444),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: isPrimary ? Colors.white : const Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
