import 'package:flutter/material.dart';

/// Live Dispatch Timeline — vertical timeline showing SOS dispatch
/// events revealed step-by-step as [dispatchStep] increments (0–6).
/// Step 0 = nothing done, 6 = all steps complete.
class DispatchTimelineWidget extends StatelessWidget {
  final bool isActive;
  final int contactCount;

  /// Drives which events are "completed". Each event completes when
  /// its 1-based index ≤ dispatchStep.
  final int dispatchStep;

  /// Real emergency contacts — used to show masked phone numbers.
  final List<Map<String, dynamic>> emergencyContacts;

  const DispatchTimelineWidget({
    super.key,
    required this.isActive,
    this.contactCount = 0,
    this.dispatchStep = 0,
    this.emergencyContacts = const [],
  });

  String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 4) return phone;
    return '${phone.substring(0, phone.length - 4)}••••';
  }

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    // Build masked contact string for SMS step
    final contactSmsLabel = contactCount > 0
        ? 'SMS sent to ${contactCount} contact${contactCount > 1 ? 's' : ''}'
            '${emergencyContacts.isNotEmpty ? ' (${_maskPhone(emergencyContacts.first['phone'] as String? ?? '')})' : ''}'
        : 'No contacts configured';

    final events = <_TimelineEvent>[
      const _TimelineEvent(
        icon: Icons.sos_rounded,
        label: 'Emergency triggered',
        time: 'Now',
        color: Color(0xFFEF4444),
        stepIndex: 1,
      ),
      const _TimelineEvent(
        icon: Icons.location_on_rounded,
        label: 'Live location shared',
        time: 'Now',
        color: Color(0xFF0EA5E9),
        stepIndex: 2,
      ),
      _TimelineEvent(
        icon: Icons.people_rounded,
        label: '$contactCount contact(s) alerted',
        time: 'Sending…',
        color: const Color(0xFF8B5CF6),
        stepIndex: 3,
      ),
      _TimelineEvent(
        icon: Icons.sms_rounded,
        label: contactSmsLabel,
        time: dispatchStep >= 4 ? 'Done' : 'Queued',
        color: const Color(0xFFF59E0B),
        stepIndex: 4,
      ),
      const _TimelineEvent(
        icon: Icons.phone_rounded,
        label: 'Call attempt started',
        time: 'Queued',
        color: Color(0xFF10B981),
        stepIndex: 5,
      ),
      const _TimelineEvent(
        icon: Icons.local_hospital_rounded,
        label: 'Hospital alert created',
        time: 'Queued',
        color: Color(0xFF60A5FA),
        stepIndex: 6,
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
              // Animated live dot
              _LiveDot(dispatchStep: dispatchStep, totalSteps: events.length),
            ],
          ),
          const SizedBox(height: 10),

          // Timeline rows
          ...List.generate(events.length, (i) {
            final event = events[i];
            final isLast = i == events.length - 1;
            final completed = dispatchStep >= event.stepIndex;
            final isCurrentStep = dispatchStep == event.stepIndex - 1;

            return _TimelineRow(
              event: event,
              completed: completed,
              isLast: isLast,
              isPending: isCurrentStep,
            );
          }),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  final int dispatchStep;
  final int totalSteps;
  const _LiveDot({required this.dispatchStep, required this.totalSteps});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allDone = widget.dispatchStep >= widget.totalSteps;
    if (allDone) {
      return const Text('Complete',
          style: TextStyle(
              fontSize: 9,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w700));
    }
    return FadeTransition(
      opacity: _fade,
      child: const Text('Live',
          style: TextStyle(
              fontSize: 9,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w700)),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _TimelineEvent event;
  final bool completed;
  final bool isLast;
  final bool isPending;

  const _TimelineRow({
    required this.event,
    required this.completed,
    required this.isLast,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot + line
        SizedBox(
          width: 24,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? event.color.withValues(alpha: 0.30)
                      : isPending
                          ? event.color.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: completed
                        ? event.color
                        : isPending
                            ? event.color.withValues(alpha: 0.50)
                            : Colors.white.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                ),
                child: completed
                    ? Icon(Icons.check, size: 6, color: event.color)
                    : null,
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 1.2,
                  height: 24,
                  color: completed
                      ? event.color.withValues(alpha: 0.30)
                      : Colors.white.withValues(alpha: 0.10),
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
                    color: completed
                        ? event.color
                        : isPending
                            ? event.color.withValues(alpha: 0.50)
                            : Colors.white.withValues(alpha: 0.20)),
                const SizedBox(width: 6),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: completed
                            ? Colors.white
                            : isPending
                                ? Colors.white.withValues(alpha: 0.60)
                                : Colors.white.withValues(alpha: 0.25)),
                    child: Text(event.label),
                  ),
                ),
                Text(
                  completed ? event.time : (isPending ? 'In progress…' : 'Queued'),
                  style: TextStyle(
                      fontSize: 9,
                      color: completed
                          ? Colors.white.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.20),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineEvent {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  /// 1-indexed step that must be reached for this event to be "completed".
  final int stepIndex;

  const _TimelineEvent({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
    required this.stepIndex,
  });
}
