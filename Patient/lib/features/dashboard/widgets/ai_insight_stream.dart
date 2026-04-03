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
            '🧠 AI Insight Stream', 'Predictive health intelligence'),
        const SizedBox(height: 10),
        ...insights.map((ins) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightCard(insight: ins, isDark: isDark),
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
        text:
            'Active condition: ${ai['condition']} — ${ai['risk']} risk level detected.',
        confidence: (ai['confidence'] as num?)?.toInt() ?? 80,
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
          text:
              'Low sleep pattern (${sleep.toStringAsFixed(1)}h) may increase migraine probability tonight by 18%.',
          confidence: 79,
          cta: 'Sleep Guide',
        ));
      }
    }

    list.add(_Insight(
      tag: 'Recovery ETA',
      icon: Icons.healing_rounded,
      color: const Color(0xFF10B981),
      text:
          '2 more days of consistent hydration may fully stabilize gastritis symptoms.',
      confidence: 85,
      cta: 'See Recovery Plan',
    ));

    list.add(_Insight(
      tag: 'Preventive Alert',
      icon: Icons.shield_rounded,
      color: const Color(0xFF06B6D4),
      text:
          'Activity levels suggest elevated stress markers. A rest day this week is recommended.',
      confidence: 72,
      cta: 'AI Recommendation',
    ));

    return list;
  }
}

class _Insight {
  final String tag;
  final IconData icon;
  final Color color;
  final String text;
  final int confidence;
  final String cta;
  const _Insight({
    required this.tag,
    required this.icon,
    required this.color,
    required this.text,
    required this.confidence,
    required this.cta,
  });
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  final bool isDark;
  const _InsightCard({required this.insight, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      blur: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Text('${insight.confidence}% conf',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.text,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.88)
                  : AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
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
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.28)
                      : AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
