import 'package:flutter/material.dart';

/// Emergency Dispatch Hero — animated status header showing current
/// SOS state: Ready, Dispatching, Contacts Notified, Active, Cancelled,
/// Offline Fallback. Pulse icon + status text. Pure UI widget.
class EmergencyDispatchHero extends StatelessWidget {
  final SosState sosState;
  final int contactsNotified;
  final String? nearestHospital;
  final String? hospitalEta;

  const EmergencyDispatchHero({
    super.key,
    required this.sosState,
    this.contactsNotified = 0,
    this.nearestHospital,
    this.hospitalEta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated icon
        _StatusIcon(state: sosState),
        const SizedBox(height: 12),

        // Primary status text
        Text(
          _primaryText(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sosState == SosState.ready ? 28 : 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: sosState == SosState.ready ? 3 : 0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Secondary status
        Text(
          _secondaryText(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          ),
        ),

        // Hospital ETA
        if (sosState == SosState.active &&
            nearestHospital != null &&
            nearestHospital!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20), width: 0.6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_hospital_rounded,
                    size: 13, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  '$nearestHospital${hospitalEta != null ? " — $hospitalEta" : ""}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _primaryText() {
    switch (sosState) {
      case SosState.ready:
        return 'EMERGENCY SOS';
      case SosState.dispatching:
        return 'DISPATCHING…';
      case SosState.active:
        return 'HELP IS COMING';
      case SosState.cancelled:
        return 'FALSE ALARM';
      case SosState.offline:
        return 'OFFLINE MODE';
    }
  }

  String _secondaryText() {
    switch (sosState) {
      case SosState.ready:
        return 'Hold the button for 2 seconds to dispatch emergency';
      case SosState.dispatching:
        return 'Sending location and medical data…';
      case SosState.active:
        if (contactsNotified > 0) {
          return '$contactsNotified contact(s) notified • Location shared';
        }
        return 'Emergency responders alerted';
      case SosState.cancelled:
        return 'All contacts have been notified this was a false alarm';
      case SosState.offline:
        return 'No network — using SMS fallback for emergency contacts';
    }
  }
}

enum SosState { ready, dispatching, active, cancelled, offline }

class _StatusIcon extends StatelessWidget {
  final SosState state;

  const _StatusIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color bgColor;

    switch (state) {
      case SosState.ready:
        icon = Icons.sos_rounded;
        bgColor = Colors.white.withValues(alpha: 0.15);
      case SosState.dispatching:
        icon = Icons.sync_rounded;
        bgColor = Colors.white.withValues(alpha: 0.20);
      case SosState.active:
        icon = Icons.check_circle_rounded;
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.30);
      case SosState.cancelled:
        icon = Icons.cancel_rounded;
        bgColor = Colors.white.withValues(alpha: 0.15);
      case SosState.offline:
        icon = Icons.wifi_off_rounded;
        bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.25);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.20), width: 0.8),
      ),
      child: Icon(icon, size: 22, color: Colors.white),
    );
  }
}
