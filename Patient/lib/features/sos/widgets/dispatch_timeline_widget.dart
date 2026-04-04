import 'package:flutter/material.dart';

/// Live Dispatch Timeline — vertical timeline showing SOS dispatch
/// events: contacts notified, SMS delivered, location shared, call
/// attempts, hospital alert. Pure UI widget.
class DispatchTimelineWidget extends StatelessWidget {
  final bool isActive;
  final int contactCount;

  const DispatchTimelineWidget({
    super.key,
    required this.isActive,
    this.contactCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    final events = <_TimelineEvent>[
      const _TimelineEvent(
        icon: Icons.sos_rounded,
        label: 'Emergency triggered',
        time: 'Just now',
        color: Color(0xFFEF4444),
        completed: true,
      ),
      const _TimelineEvent(
        icon: Icons.location_on_rounded,
        label: 'Live location shared',
        time: 'Just now',
        color: Color(0xFF0EA5E9),
        completed: true,
      ),
      _TimelineEvent(
        icon: Icons.people_rounded,
        label: '$contactCount contact(s) notified',
        time: 'Just now',
        color: const Color(0xFF8B5CF6),
        completed: contactCount > 0,
      ),
      const _TimelineEvent(
        icon: Icons.sms_rounded,
        label: 'Emergency SMS delivered',
        time: 'Sending…',
        color: Color(0xFFF59E0B),
        completed: false,
      ),
      const _TimelineEvent(
        icon: Icons.phone_rounded,
        label: 'Call attempt started',
        time: 'Queued',
        color: Color(0xFF10B981),
        completed: false,
      ),
      const _TimelineEvent(
        icon: Icons.local_hospital_rounded,
        label: 'Hospital alert created',
        time: 'Queued',
        color: Color(0xFF60A5FA),
        completed: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.12), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timeline_rounded,
                        size: 11, color: Color(0xFFFBBF24)),
                    SizedBox(width: 3),
                    Text('Dispatch Timeline',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFFBBF24),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Text('Live',
                  style: TextStyle(
                      fontSize: 9,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),

          // Timeline
          ...List.generate(events.length, (i) {
            final event = events[i];
            final isLast = i == events.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot + line
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event.completed
                              ? event.color.withValues(alpha: 0.30)
                              : Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: event.completed
                                ? event.color
                                : Colors.white.withValues(alpha: 0.20),
                            width: 1.5,
                          ),
                        ),
                        child: event.completed
                            ? Icon(Icons.check,
                                size: 6, color: event.color)
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 1.2,
                          height: 24,
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(event.icon,
                            size: 13,
                            color: event.completed
                                ? event.color
                                : Colors.white.withValues(alpha: 0.30)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(event.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: event.completed
                                      ? Colors.white
                                      : Colors.white
                                          .withValues(alpha: 0.35))),
                        ),
                        Text(event.time,
                            style: TextStyle(
                                fontSize: 9,
                                color: event.completed
                                    ? Colors.white.withValues(alpha: 0.50)
                                    : Colors.white.withValues(alpha: 0.20),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  final IconData icon;
  final String label;
  final String time;
  final Color color;
  final bool completed;

  const _TimelineEvent({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
    required this.completed,
  });
}
