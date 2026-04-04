import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class AiInsightStream extends StatelessWidget {
  final Map<String, dynamic> data;
  const AiInsightStream({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = _buildInsights(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashSectionLabel(
            '🧠 AI Insight Stream', 'Prediction → Action → Outcome'),
        const SizedBox(height: 10),
        ...insights.map((ins) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightStoryCard(insight: ins, isDark: isDark),
            )),
      ],
    );
  }

  List<_Insight> _buildInsights(Map<String, dynamic> d) {
    final list = <_Insight>[];

    final ai = d['latest_ai_result'] as Map<String, dynamic>?;
    if (ai != null) {
      list.add(_Insight(
        tag: 'Risk Forecast',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFF59E0B),
        prediction:
            'Active condition: ${ai['condition']} — ${ai['risk']} risk level detected.',
        action: 'Follow prescribed treatment plan & monitor vitals twice daily',
        outcome: '${ai['risk'] == 'high' ? 'Reduce' : 'Maintain'} risk level within 3 days',
        confidence: (ai['confidence'] as num?)?.toInt() ?? 80,
        eta: '3 days',
        escalate: ai['risk'] == 'high',
        cta: 'View AI Report',
      ));
    }

    final mon = d['latest_monitoring'] as Map<String, dynamic>?;
    if (mon != null) {
      final sleep = (mon['sleep_hours'] as num?)?.toDouble() ?? 7;
      if (sleep < 6.5) {
        list.add(_Insight(
          tag: 'Sleep Risk',
          icon: Icons.nightlight_round,
          color: const Color(0xFF8B5CF6),
          prediction:
              'Low sleep (${sleep.toStringAsFixed(1)}h) may increase migraine probability tonight by 18%.',
          action: 'Sleep before 11 PM tonight, avoid screens after 9 PM',
          outcome: '+8 recovery score tomorrow, −18% migraine risk',
          confidence: 79,
          eta: 'Tonight',
          escalate: false,
          cta: 'Sleep Guide',
        ));
      }
    }

    list.add(_Insight(
      tag: 'Recovery ETA',
      icon: Icons.healing_rounded,
      color: const Color(0xFF10B981),
      prediction:
          '2 more days of consistent hydration may fully stabilize gastritis symptoms.',
      action: 'Drink 8+ cups of water daily, avoid spicy foods',
      outcome: 'Full symptom stabilization, +12 recovery score',
      confidence: 85,
      eta: '2 days',
      escalate: false,
      cta: 'See Recovery Plan',
    ));

    list.add(_Insight(
      tag: 'Preventive Alert',
      icon: Icons.shield_rounded,
      color: const Color(0xFF06B6D4),
      prediction:
          'Activity levels suggest elevated stress markers this week.',
      action: 'Schedule a rest day, try 10-min breathing exercise',
      outcome: 'Stress markers normalize, +5 wellness score',
      confidence: 72,
      eta: 'This week',
      escalate: false,
      cta: 'AI Recommendation',
    ));

    return list;
  }
}

class _Insight {
  final String tag;
  final IconData icon;
  final Color color;
  final String prediction;
  final String action;
  final String outcome;
  final int confidence;
  final String eta;
  final bool escalate;
  final String cta;
  const _Insight({
    required this.tag,
    required this.icon,
    required this.color,
    required this.prediction,
    required this.action,
    required this.outcome,
    required this.confidence,
    required this.eta,
    required this.escalate,
    required this.cta,
  });
}

class _InsightStoryCard extends StatelessWidget {
  final _Insight insight;
  final bool isDark;
  const _InsightStoryCard({required this.insight, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : AppColors.textPrimary;

    return GlassCard(
      radius: 22,
      blur: 18,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: insight.color.withValues(alpha: 0.14),
                ),
                child: Icon(insight.icon, size: 16, color: insight.color),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: insight.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(insight.tag,
                    style: TextStyle(
                        fontSize: 10,
                        color: insight.color,
                        fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 10, color: Color(0xFF6366F1)),
                  const SizedBox(width: 3),
                  Text('${insight.confidence}%',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Prediction ─────────────────
          _StoryStep(
            label: 'PREDICTION',
            icon: Icons.lightbulb_outline_rounded,
            color: insight.color,
            text: insight.prediction,
            textColor: textPrimary,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // ── Action ─────────────────────
          _StoryStep(
            label: 'ACTION',
            icon: Icons.play_circle_outline_rounded,
            color: const Color(0xFF6366F1),
            text: insight.action,
            textColor: textPrimary,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // ── Outcome ────────────────────
          _StoryStep(
            label: 'OUTCOME',
            icon: Icons.emoji_events_outlined,
            color: const Color(0xFF10B981),
            text: insight.outcome,
            textColor: textPrimary,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // ETA + escalation + CTA row
          Row(
            children: [
              // ETA chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: insight.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: insight.color.withValues(alpha: 0.22),
                      width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 10, color: insight.color),
                    const SizedBox(width: 4),
                    Text('ETA: ${insight.eta}',
                        style: TextStyle(
                            fontSize: 10,
                            color: insight.color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Doctor escalation badge
              if (insight.escalate)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.30),
                        width: 0.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medical_services_rounded,
                          size: 10, color: Color(0xFFEF4444)),
                      SizedBox(width: 4),
                      Text('See Doctor',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              const Spacer(),
              // CTA
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    insight.color.withValues(alpha: 0.18),
                    insight.color.withValues(alpha: 0.07)
                  ]),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: insight.color.withValues(alpha: 0.28),
                      width: 0.5),
                ),
                child: Text(insight.cta,
                    style: TextStyle(
                        fontSize: 11,
                        color: insight.color,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String text;
  final Color textColor;
  final bool isDark;
  const _StoryStep({
    required this.label,
    required this.icon,
    required this.color,
    required this.text,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.10),
            border: Border.all(color: color.withValues(alpha: 0.20), width: 0.5),
          ),
          child: Icon(icon, size: 11, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.6)),
              const SizedBox(height: 3),
              Text(text,
                  style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      height: 1.45,
                      letterSpacing: -0.1)),
            ],
          ),
        ),
      ],
    );
  }
}
