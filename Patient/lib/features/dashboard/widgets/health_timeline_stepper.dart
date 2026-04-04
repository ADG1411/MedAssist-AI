import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class HealthTimelineStepper extends StatelessWidget {
  final Map<String, dynamic> data;
  const HealthTimelineStepper({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final events = _buildEvents(data);
    final nowHour = DateTime.now().hour;

    // Find the index where "now" marker should appear
    int nowIdx = events.length; // default: after all
    for (int i = 0; i < events.length; i++) {
      if (!events[i].done && events[i].hourApprox >= nowHour) {
        nowIdx = i;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashSectionLabel('📅 Health Timeline', 'Today & upcoming'),
        const SizedBox(height: 10),
        GlassCard(
          radius: 24,
          blur: 20,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Column(
            children: [
              for (int i = 0; i < events.length; i++) ...[
                // "Now" marker
                if (i == nowIdx)
                  _NowMarker(isDark: isDark),
                _TimelineRow(
                  event: events[i],
                  isLast: i == events.length - 1,
                  isDark: isDark,
                  isOverdue: !events[i].done && events[i].hourApprox < nowHour,
                ),
              ],
              // If nowIdx == events.length, put marker at end
              if (nowIdx == events.length)
                _NowMarker(isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }

  List<_Event> _buildEvents(Map<String, dynamic> d) {
    final meds = (d['medication_reminders'] as List?) ?? [];
    final appts = (d['upcoming_appointments'] as List?) ?? [];

    final events = <_Event>[
      _Event(
        time: '08:00 AM',
        title: meds.isNotEmpty
            ? '${(meds.first as Map)['name']}'
            : 'Morning Medication',
        sub: 'Take with a full glass of water',
        icon: Icons.medication_rounded,
        color: const Color(0xFF10B981),
        type: _EventType.medicine,
        done: meds.isNotEmpty && (meds.first as Map)['taken'] == true,
        hourApprox: 8,
      ),
      const _Event(
        time: '12:00 PM',
        title: 'Vitals Check',
        sub: 'Log hydration & symptoms',
        icon: Icons.monitor_heart_rounded,
        color: Color(0xFF06B6D4),
        type: _EventType.vitals,
        done: false,
        hourApprox: 12,
      ),
    ];

    if (appts.isNotEmpty) {
      final appt = appts.first as Map;
      events.add(_Event(
        time: appt['time']?.toString() ?? 'Tomorrow',
        title: appt['doctor']?.toString() ?? 'Doctor Appointment',
        sub: appt['type']?.toString() ?? 'Follow-up visit',
        icon: Icons.local_hospital_rounded,
        color: const Color(0xFF6366F1),
        type: _EventType.doctor,
        done: false,
        hourApprox: 15,
      ));
    }

    if (meds.length > 1) {
      events.add(_Event(
        time: '08:00 PM',
        title: '${(meds.last as Map)['name']}',
        sub: 'Evening dose',
        icon: Icons.medication_rounded,
        color: const Color(0xFFF59E0B),
        type: _EventType.medicine,
        done: (meds.last as Map)['taken'] == true,
        hourApprox: 20,
      ));
    }

    events.add(const _Event(
      time: '10:30 PM',
      title: 'Sleep Target',
      sub: 'Aim for 8 hrs of quality sleep',
      icon: Icons.nightlight_round,
      color: Color(0xFF8B5CF6),
      type: _EventType.sleep,
      done: false,
      hourApprox: 22,
    ));

    return events;
  }
}

enum _EventType { medicine, doctor, vitals, sleep }

class _Event {
  final String time;
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final _EventType type;
  final bool done;
  final int hourApprox;
  const _Event({
    required this.time,
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    required this.type,
    required this.done,
    required this.hourApprox,
  });
}

// ── Now marker line ──────────────────────────────────────────────────────────
class _NowMarker extends StatelessWidget {
  final bool isDark;
  const _NowMarker({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 66),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEF4444),
              boxShadow: [
                BoxShadow(
                  color: Color(0x55EF4444),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFFEF4444),
                  const Color(0xFFEF4444).withValues(alpha: 0.0),
                ]),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('NOW',
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEF4444),
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _Event event;
  final bool isLast;
  final bool isDark;
  final bool isOverdue;
  const _TimelineRow({
    required this.event,
    required this.isLast,
    required this.isDark,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.48) : AppColors.textSecondary;

    final labelColor = event.done
        ? textSub
        : (isOverdue ? const Color(0xFFEF4444) : textPrimary);
    final deco = event.done ? TextDecoration.lineThrough : null;
    final rowOpacity = event.done ? 0.50 : 1.0;

    return Opacity(
      opacity: rowOpacity,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time label
            SizedBox(
              width: 66,
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Text(event.time,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: isOverdue
                            ? const Color(0xFFEF4444).withValues(alpha: 0.70)
                            : textSub)),
              ),
            ),
            // Dot + vertical line
            Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.done
                        ? event.color.withValues(alpha: 0.14)
                        : (isOverdue
                            ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                            : event.color.withValues(alpha: 0.10)),
                    border: Border.all(
                      color: event.done
                          ? event.color
                          : (isOverdue
                              ? const Color(0xFFEF4444).withValues(alpha: 0.50)
                              : event.color.withValues(alpha: 0.35)),
                      width: 1.5,
                    ),
                    boxShadow: isOverdue && !event.done
                        ? [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    event.done ? Icons.check_rounded : event.icon,
                    size: 13,
                    color: event.done
                        ? event.color
                        : (isOverdue ? const Color(0xFFEF4444) : event.color),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.07),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(event.title,
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                  color: labelColor,
                                  decoration: deco,
                                  decorationColor: labelColor)),
                        ),
                        if (isOverdue && !event.done)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('OVERDUE',
                                style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFEF4444),
                                    letterSpacing: 0.4)),
                          ),
                        if (event.done)
                          const Icon(Icons.check_circle_rounded,
                              size: 14, color: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(event.sub,
                        style: TextStyle(fontSize: 11, color: textSub, letterSpacing: -0.1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
