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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashSectionLabel('📅 Health Timeline', 'Today & upcoming'),
        const SizedBox(height: 10),
        GlassCard(
          radius: 24,
          blur: 20,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: List.generate(
              events.length,
              (i) => _TimelineRow(
                event: events[i],
                isLast: i == events.length - 1,
                isDark: isDark,
              ),
            ),
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
        done: meds.isNotEmpty && (meds.first as Map)['taken'] == true,
      ),
      _Event(
        time: '12:00 PM',
        title: 'Vitals Check',
        sub: 'Log hydration & symptoms',
        icon: Icons.monitor_heart_rounded,
        color: const Color(0xFF06B6D4),
        done: false,
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
        done: false,
      ));
    }

    if (meds.length > 1) {
      events.add(_Event(
        time: '08:00 PM',
        title: '${(meds.last as Map)['name']}',
        sub: 'Evening dose',
        icon: Icons.medication_rounded,
        color: const Color(0xFFF59E0B),
        done: (meds.last as Map)['taken'] == true,
      ));
    }

    events.add(_Event(
      time: '10:30 PM',
      title: 'Sleep Target',
      sub: 'Aim for 8 hrs of quality sleep',
      icon: Icons.nightlight_round,
      color: const Color(0xFF8B5CF6),
      done: false,
    ));

    return events;
  }
}

class _Event {
  final String time;
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final bool done;
  const _Event({
    required this.time,
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    required this.done,
  });
}

class _TimelineRow extends StatelessWidget {
  final _Event event;
  final bool isLast;
  final bool isDark;
  const _TimelineRow(
      {required this.event, required this.isLast, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.48) : AppColors.textSecondary;

    final labelColor = event.done ? textSub : textPrimary;
    final deco = event.done ? TextDecoration.lineThrough : null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Text(event.time,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textSub)),
            ),
          ),
          // Dot + vertical line
          Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: event.done
                      ? event.color.withValues(alpha: 0.14)
                      : event.color.withValues(alpha: 0.10),
                  border: Border.all(
                    color: event.done
                        ? event.color
                        : event.color.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  event.done ? Icons.check_rounded : event.icon,
                  size: 13,
                  color: event.color,
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
                  Text(event.title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                          decoration: deco,
                          decorationColor: labelColor)),
                  const SizedBox(height: 2),
                  Text(event.sub,
                      style: TextStyle(fontSize: 11, color: textSub)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
