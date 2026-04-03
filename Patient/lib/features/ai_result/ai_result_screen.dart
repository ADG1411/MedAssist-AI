import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/condition_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/ai_mode_badge.dart';
import '../symptom_chat/providers/chat_provider.dart';

class AiResultScreen extends ConsumerWidget {
  const AiResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final result = chatState.lastResult;
    
    final List<dynamic> conditions = result?['conditions'] ?? [
      {'name': 'Gathering Analysis...', 'confidence': 0, 'risk': 'unknown'}
    ];
    final String specialization = result?['specialization'] ?? 'General Physician';
    final String action = result?['action'] ?? 'monitor';
    final bool isEmergency = result?['emergency'] == true;
    final List<dynamic> prescriptionHints = result?['prescription_hints'] ?? [];
    final String aiReply = result?['reply'] ?? '';
    final int riskScore = result?['risk_score'] ?? 0;
    final List<dynamic> confidenceReasoning = result?['confidence_reasoning'] ?? [];
    final Map<String, dynamic> monitoringPlan = Map<String, dynamic>.from(result?['monitoring_plan'] ?? {});
    final Map<String, dynamic> doctorHandoff = Map<String, dynamic>.from(result?['doctor_handoff'] ?? {});

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Analysis Complete'),
        leading: BackButton(onPressed: () => context.go('/home')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AiModeBadge(mode: AiMode.fast),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            // Emergency Banner
            if (isEmergency) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.danger, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency, color: AppColors.danger, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚠️ EMERGENCY DETECTED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.danger)),
                          const SizedBox(height: 4),
                          const Text('Please seek immediate medical attention or call emergency services.', style: TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/sos'),
                              icon: const Icon(Icons.sos, size: 18),
                              label: const Text('CALL SOS NOW'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Risk Score Gauge
            if (riskScore > 0) ...[
              _buildRiskScoreGauge(context, riskScore),
              const SizedBox(height: 24),
            ],

            // Header
            Icon(
              isEmergency ? Icons.warning_amber : Icons.check_circle,
              size: 64,
              color: isEmergency ? AppColors.danger : AppColors.success,
            ),
            const SizedBox(height: 16),
            Text(
              conditions.isNotEmpty && (conditions.first['confidence'] ?? 0) > 0
                  ? 'Clinical Assessment'
                  : 'Analysis in Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on your symptoms and medical history',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Doctor's Summary
            if (aiReply.isNotEmpty) ...[
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF4A9FF5), Color(0xFF2563EB)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Text("Doctor's Assessment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      aiReply,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Confidence Reasoning Chips
            if (confidenceReasoning.isNotEmpty) ...[
              const SectionHeader(title: 'Diagnostic Reasoning'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: confidenceReasoning.map((reason) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.psychology, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(child: Text(reason.toString(), style: TextStyle(fontSize: 13, color: AppColors.primary))),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Top Conditions
            if (conditions.isNotEmpty && (conditions.first['confidence'] ?? 0) > 0) ...[
              const SectionHeader(title: 'Possible Conditions'),
              const SizedBox(height: 16),
              ...conditions.map((cond) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ConditionCard(
                    conditionName: cond['name'] ?? 'Unknown', 
                    confidence: cond['confidence']?.toInt() ?? 0, 
                    riskLevel: cond['risk'] ?? 'Low',
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Prescription Hints
            if (prescriptionHints.isNotEmpty) ...[
              const SectionHeader(title: 'Suggested Care'),
              const SizedBox(height: 16),
              AppSectionCard(
                child: Column(
                  children: prescriptionHints.asMap().entries.map((entry) {
                    final hint = entry.value.toString();
                    final isLast = entry.key == prescriptionHints.length - 1;

                    IconData icon = Icons.check_circle;
                    Color iconColor = AppColors.success;
                    if (hint.toLowerCase().contains('avoid') || hint.toLowerCase().contains('stop')) {
                      icon = Icons.do_not_disturb;
                      iconColor = AppColors.danger;
                    } else if (hint.toLowerCase().contains('take') || hint.toLowerCase().contains('medication')) {
                      icon = Icons.medication;
                      iconColor = AppColors.primary;
                    } else if (hint.toLowerCase().contains('drink') || hint.toLowerCase().contains('water')) {
                      icon = Icons.water_drop;
                      iconColor = const Color(0xFF06B6D4);
                    } else if (hint.toLowerCase().contains('rest') || hint.toLowerCase().contains('sleep')) {
                      icon = Icons.bedtime;
                      iconColor = const Color(0xFF8B5CF6);
                    } else if (hint.toLowerCase().contains('eat') || hint.toLowerCase().contains('food') || hint.toLowerCase().contains('diet')) {
                      icon = Icons.restaurant;
                      iconColor = AppColors.warning;
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, size: 16, color: iconColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(hint, style: const TextStyle(fontSize: 14, height: 1.4))),
                            ],
                          ),
                        ),
                        if (!isLast) Divider(color: AppColors.border.withValues(alpha: 0.3), height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Monitoring Plan
            if (monitoringPlan.isNotEmpty && (monitoringPlan['track_for_days'] ?? 0) > 0) ...[
              const SectionHeader(title: 'Monitoring Plan'),
              const SizedBox(height: 16),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF06B6D4).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.monitor_heart, size: 20, color: Color(0xFF06B6D4)),
                        ),
                        const SizedBox(width: 12),
                        Text('Track for ${monitoringPlan['track_for_days']} days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (monitoringPlan['focus_metrics'] != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (monitoringPlan['focus_metrics'] as List).map((metric) {
                          return Chip(
                            label: Text(metric.toString().replaceAll('_', ' '), style: const TextStyle(fontSize: 12)),
                            backgroundColor: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    if ((monitoringPlan['red_flags'] as List?)?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      const Text('🚩 Red Flags (seek ER if):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.danger)),
                      const SizedBox(height: 4),
                      ...(monitoringPlan['red_flags'] as List).map((flag) =>
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber, size: 14, color: AppColors.danger),
                              const SizedBox(width: 6),
                              Expanded(child: Text(flag.toString(), style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Doctor Handoff CTA
            if (doctorHandoff['summary'] != null && (doctorHandoff['summary'] as String).isNotEmpty) ...[
              const SectionHeader(title: 'Doctor Handoff Brief'),
              const SizedBox(height: 16),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.assignment, size: 20, color: Color(0xFF8B5CF6)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ready for specialist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              if (doctorHandoff['urgency'] != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _urgencyColor(doctorHandoff['urgency']).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (doctorHandoff['urgency'] as String).toUpperCase(),
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _urgencyColor(doctorHandoff['urgency'])),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(doctorHandoff['summary'], style: const TextStyle(fontSize: 14, height: 1.5)),
                    if ((doctorHandoff['recommended_tests'] as List?)?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      const Text('Suggested Tests:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (doctorHandoff['recommended_tests'] as List).map((test) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.science, size: 14, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Text(test.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Specialist Recommendation
            const SectionHeader(title: 'Recommended Specialist'),
            const SizedBox(height: 16),
            AppSectionCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(specialization, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          action == 'emergency_room'
                              ? 'Please visit the emergency room immediately'
                              : action == 'consult_doctor'
                                  ? 'We recommend consulting a $specialization'
                                  : 'Monitor your symptoms over the next 24 hours',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Actions
            if (action == 'consult_doctor' || action == 'emergency_room') ...[
              AppButton(
                text: 'Find $specialization',
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => context.push('/doctors?specialization=$specialization'),
              ),
              const SizedBox(height: 16),
            ],

            AppButton(
              text: 'Run Deep Medical Check',
              variant: action == 'consult_doctor' ? AppButtonVariant.secondary : AppButtonVariant.primary,
              onPressed: () => context.push('/deep-check'),
            ),
            const SizedBox(height: 16),

            if (action == 'emergency_room')
              AppButton(
                text: ' Emergency SOS',
                onPressed: () => context.push('/sos'),
              ),

            if (action != 'emergency_room')
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Save to Records',
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Result saved to Health Records')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'Create Ticket',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/symptom-check'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Risk Score Gauge Widget
  Widget _buildRiskScoreGauge(BuildContext context, int score) {
    final color = score >= 80 ? AppColors.danger
        : score >= 60 ? AppColors.warning
        : score >= 40 ? const Color(0xFFF59E0B)
        : AppColors.success;

    final label = score >= 80 ? 'HIGH RISK'
        : score >= 60 ? 'MODERATE RISK'
        : score >= 40 ? 'LOW-MODERATE'
        : 'LOW RISK';

    return AppSectionCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Risk Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: score / 100,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.6), color]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$score / 100', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _urgencyColor(String? urgency) {
    switch (urgency) {
      case 'emergency': return AppColors.danger;
      case 'urgent': return const Color(0xFFEF4444);
      case 'priority': return AppColors.warning;
      default: return AppColors.success;
    }
  }
}
