import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class AttentionHubRail extends StatelessWidget {
  final Map<String, dynamic> data;
  const AttentionHubRail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alerts = _buildAlerts(data);
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashSectionLabel('🔔 Attention Hub', 'AI priority alerts'),
        const SizedBox(height: 10),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (_, i) =>
                _AttentionCard(alert: alerts[i], isDark: isDark),
          ),
        ),
      ],
    );
  }

  List<_Alert> _buildAlerts(Map<String, dynamic> d) {
    final list = <_Alert>[];

    final meds = d['medication_reminders'] as List?;
    if (meds != null) {
      for (final m in meds) {
        if ((m as Map)['taken'] == false) {
          list.add(_Alert(
            emoji: '💊',
            title: 'Medication Due',
            subtitle: m['name']?.toString() ?? 'Medication',
            detail: m['time']?.toString() ?? 'Now',
            urgency: _Urgency.high,
            confidence: 98,
            action: 'Mark Taken',
          ));
        }
      }
    }

    final meal = d['unsafe_meal'] as Map<String, dynamic>?;
    if (meal != null) {
      list.add(_Alert(
        emoji: '🍽️',
        title: 'Food Risk',
        subtitle: meal['food_name']?.toString() ?? 'Recent meal',
        detail: meal['conflict']?.toString() ?? 'May affect condition',
        urgency: _Urgency.medium,
        confidence: 87,
        action: 'See Details',
      ));
    }

    if (d['profile_nudge'] == true) {
      list.add(_Alert(
        emoji: '👤',
        title: 'Profile Incomplete',
        subtitle: 'Medical history missing',
        detail: 'AI accuracy −40%',
        urgency: _Urgency.medium,
        confidence: 100,
        action: 'Complete Now',
      ));
    }

    final wearable = d['wearable_sync'] as Map<String, dynamic>?;
    if (wearable?['status'] == false) {
      list.add(_Alert(
        emoji: '⌚',
        title: 'Wearable Offline',
        subtitle: 'No vitals syncing',
        detail: 'Last: ${wearable!['last_sync']}',
        urgency: _Urgency.low,
        confidence: 100,
        action: 'Reconnect',
      ));
    }

    if (d['emergency_preparedness'] == false) {
      list.add(_Alert(
        emoji: '🆘',
        title: 'SOS Not Ready',
        subtitle: 'No emergency contacts',
        detail: 'Critical safety gap',
        urgency: _Urgency.high,
        confidence: 100,
        action: 'Setup SOS',
      ));
    }

    list.add(_Alert(
      emoji: '🤖',
      title: 'AI Reminder',
      subtitle: 'Follow-up due',
      detail: 'Schedule next check-in',
      urgency: _Urgency.low,
      confidence: 76,
      action: 'Book Now',
    ));

    return list;
  }
}

enum _Urgency { high, medium, low }

class _Alert {
  final String emoji;
  final String title;
  final String subtitle;
  final String detail;
  final _Urgency urgency;
  final int confidence;
  final String action;
  const _Alert({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.urgency,
    required this.confidence,
    required this.action,
  });
}

class _AttentionCard extends StatelessWidget {
  final _Alert alert;
  final bool isDark;
  const _AttentionCard({required this.alert, required this.isDark});

  Color get _color {
    switch (alert.urgency) {
      case _Urgency.high:   return const Color(0xFFEF4444);
      case _Urgency.medium: return const Color(0xFFF59E0B);
      case _Urgency.low:    return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      blur: 18,
      child: Container(
        width: 182,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _color.withValues(alpha: 0.14),
                  ),
                  child: Center(
                      child: Text(alert.emoji,
                          style: const TextStyle(fontSize: 14))),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${alert.confidence}%',
                      style: TextStyle(
                          fontSize: 9,
                          color: _color,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(alert.title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(alert.subtitle,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.55)
                        : AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                    color: _color.withValues(alpha: 0.28), width: 0.5),
              ),
              child: Text(alert.action,
                  style: TextStyle(
                      fontSize: 11,
                      color: _color,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
