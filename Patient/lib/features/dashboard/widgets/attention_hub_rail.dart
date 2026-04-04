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

    // Sort: critical first, then medium, then low
    alerts.sort((a, b) => a.urgency.index.compareTo(b.urgency.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: DashSectionLabel('🔔 Attention Hub', 'AI priority alerts'),
            ),
            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${alerts.where((a) => a.urgency == _Urgency.high).length} critical',
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 158,
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

class _AttentionCard extends StatefulWidget {
  final _Alert alert;
  final bool isDark;
  const _AttentionCard({required this.alert, required this.isDark});

  @override
  State<_AttentionCard> createState() => _AttentionCardState();
}

class _AttentionCardState extends State<_AttentionCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseCtrl;
  Animation<double>? _pulseAnim;

  @override
  void initState() {
    super.initState();
    if (widget.alert.urgency == _Urgency.high) {
      _pulseCtrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat(reverse: true);
      _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
          CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.alert.urgency) {
      case _Urgency.high:   return const Color(0xFFEF4444);
      case _Urgency.medium: return const Color(0xFFF59E0B);
      case _Urgency.low:    return const Color(0xFF6366F1);
    }
  }

  String get _urgencyLabel {
    switch (widget.alert.urgency) {
      case _Urgency.high:   return 'CRITICAL';
      case _Urgency.medium: return 'WARNING';
      case _Urgency.low:    return 'INFO';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHigh = widget.alert.urgency == _Urgency.high;
    final isDark = widget.isDark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppColors.textSecondary;

    Widget card = Container(
      width: 182,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Severity-specific border
        border: Border.all(
          color: isHigh
              ? _color.withValues(alpha: 0.50)
              : _color.withValues(alpha: 0.20),
          width: isHigh ? 1.2 : 0.6,
        ),
        // Soft glow for critical
        boxShadow: isHigh
            ? [
                BoxShadow(
                  color: _color.withValues(alpha: 0.18),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Emoji + pulse dot for critical
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _color.withValues(alpha: 0.14),
                    ),
                    child: Center(
                        child: Text(widget.alert.emoji,
                            style: const TextStyle(fontSize: 14))),
                  ),
                  if (isHigh && _pulseAnim != null)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: AnimatedBuilder(
                        animation: _pulseAnim!,
                        builder: (context, _) => Opacity(
                          opacity: _pulseAnim!.value,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _color,
                              boxShadow: [
                                BoxShadow(
                                  color: _color.withValues(alpha: 0.60),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              // Urgency chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_urgencyLabel,
                    style: TextStyle(
                        fontSize: 8.5,
                        color: _color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.alert.title,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.2)),
          const SizedBox(height: 3),
          Text(widget.alert.subtitle,
              style: TextStyle(fontSize: 11, color: textSub),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(widget.alert.detail,
              style: TextStyle(
                  fontSize: 10.5,
                  color: _color.withValues(alpha: 0.80),
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                      color: _color.withValues(alpha: 0.22), width: 0.5),
                ),
                child: Text(widget.alert.action,
                    style: TextStyle(
                        fontSize: 11,
                        color: _color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1)),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 9, color: textSub),
                  const SizedBox(width: 3),
                  Text('${widget.alert.confidence}%',
                      style: TextStyle(
                          fontSize: 9.5,
                          color: textSub,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return GlassCard(
      radius: 20,
      blur: 18,
      child: card,
    );
  }
}
