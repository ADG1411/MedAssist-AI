import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Emergency Action Rail — bottom action bar with quick actions.
/// [isFlashlightOn] and [isAlarmOn] drive active visual states.
class EmergencyActionRail extends StatelessWidget {
  final VoidCallback? onCallFamily;
  final VoidCallback? onCallDoctor;
  final VoidCallback? onHospitalDirections;
  final VoidCallback? onShareQr;
  final VoidCallback? onFlashlight;
  final VoidCallback? onAlarm;
  final bool isFlashlightOn;
  final bool isAlarmOn;

  const EmergencyActionRail({
    super.key,
    this.onCallFamily,
    this.onCallDoctor,
    this.onHospitalDirections,
    this.onShareQr,
    this.onFlashlight,
    this.onAlarm,
    this.isFlashlightOn = false,
    this.isAlarmOn = false,
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
        icon: isFlashlightOn
            ? Icons.flashlight_on_rounded
            : Icons.flashlight_off_rounded,
        label: 'Flash',
        color: isFlashlightOn
            ? const Color(0xFFFDE047) // bright yellow when on
            : const Color(0xFFF59E0B),
        onTap: onFlashlight,
        isActive: isFlashlightOn,
      ),
      _ActionItem(
        icon: isAlarmOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        label: isAlarmOn ? 'Alarm ON' : 'Alarm',
        color: isAlarmOn
            ? const Color(0xFFFF6B6B) // bright red-orange when blaring
            : const Color(0xFFF97316),
        onTap: onAlarm,
        isActive: isAlarmOn,
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
          return _ActionButton(action: action);
        }).toList(),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final _ActionItem action;
  const _ActionButton({required this.action});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.action.isActive) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.action.isActive && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.action.isActive && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
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
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                final glow = action.isActive ? _pulse.value : 0.0;
                return Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: action.isActive
                        ? action.color.withValues(alpha: 0.25 + glow * 0.15)
                        : action.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: action.isActive
                          ? action.color.withValues(alpha: 0.70 + glow * 0.30)
                          : action.color.withValues(alpha: 0.25),
                      width: action.isActive ? 1.5 : 0.6,
                    ),
                    boxShadow: action.isActive
                        ? [
                            BoxShadow(
                              color: action.color
                                  .withValues(alpha: 0.30 + glow * 0.20),
                              blurRadius: 8 + glow * 6,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(action.icon, size: 20, color: action.color),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 8,
                  color: action.isActive
                      ? action.color
                      : Colors.white.withValues(alpha: 0.60),
                  fontWeight:
                      action.isActive ? FontWeight.w800 : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isActive = false,
  });
}
