import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Emergency Action Rail — bottom action bar with quick actions:
/// call family, call doctor, hospital directions, share QR ID,
/// flashlight, loud alarm. Large touch targets. Pure UI widget.
class EmergencyActionRail extends StatelessWidget {
  final VoidCallback? onCallFamily;
  final VoidCallback? onCallDoctor;
  final VoidCallback? onHospitalDirections;
  final VoidCallback? onShareQr;
  final VoidCallback? onFlashlight;
  final VoidCallback? onAlarm;

  const EmergencyActionRail({
    super.key,
    this.onCallFamily,
    this.onCallDoctor,
    this.onHospitalDirections,
    this.onShareQr,
    this.onFlashlight,
    this.onAlarm,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionItem>[
      _ActionItem(
        icon: Icons.family_restroom_rounded,
        label: 'Family',
        color: const Color(0xFFEF4444),
        onTap: onCallFamily,
      ),
      _ActionItem(
        icon: Icons.medical_services_rounded,
        label: 'Doctor',
        color: const Color(0xFF3B82F6),
        onTap: onCallDoctor,
      ),
      _ActionItem(
        icon: Icons.local_hospital_rounded,
        label: 'Hospital',
        color: const Color(0xFF10B981),
        onTap: onHospitalDirections,
      ),
      _ActionItem(
        icon: Icons.qr_code_rounded,
        label: 'QR ID',
        color: const Color(0xFF8B5CF6),
        onTap: onShareQr,
      ),
      _ActionItem(
        icon: Icons.flashlight_on_rounded,
        label: 'Flash',
        color: const Color(0xFFF59E0B),
        onTap: onFlashlight,
      ),
      _ActionItem(
        icon: Icons.volume_up_rounded,
        label: 'Alarm',
        color: const Color(0xFFF97316),
        onTap: onAlarm,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.10), width: 0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              action.onTap?.call();
            },
            child: SizedBox(
              width: 52,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: action.color.withValues(alpha: 0.25),
                          width: 0.6),
                    ),
                    child: Icon(action.icon,
                        size: 20, color: action.color),
                  ),
                  const SizedBox(height: 4),
                  Text(action.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.60),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}
