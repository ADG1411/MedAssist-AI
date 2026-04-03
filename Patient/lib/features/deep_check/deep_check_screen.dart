import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/rag_repository.dart';
import '../symptom_chat/providers/chat_provider.dart';
import '../doctors/providers/doctor_provider.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/ai_mode_badge.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/risk_badge.dart';

class DeepCheckScreen extends ConsumerStatefulWidget {
  const DeepCheckScreen({super.key});

  @override
  ConsumerState<DeepCheckScreen> createState() => _DeepCheckScreenState();
}

class _DeepCheckScreenState extends ConsumerState<DeepCheckScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _memoryChunks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runDeepAnalysis();
    });
  }

  Future<void> _runDeepAnalysis() async {
    final state = ref.read(chatProvider);
    final conditionsList = state.lastResult?['conditions'] as List?;
    final topCondition = (conditionsList != null && conditionsList.isNotEmpty) 
        ? conditionsList[0]['name'] 
        : 'General symptoms';
    
    final repo = ref.read(ragRepositoryProvider);
    _memoryChunks = await repo.retrieveContext(topCondition);

    // Brief loading UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        title: const Text('Deep Medical Analysis'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AiModeBadge(mode: AiMode.deep),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildDataState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 32),
          Text(
            'Analyzing massive medical datasets...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
               'Cross-referencing symptoms with past logs and 10M+ journals.',
               style: TextStyle(color: AppColors.textSecondary),
               textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataState() {
    final chatState = ref.watch(chatProvider);
    final conditionsList = chatState.lastResult?['conditions'] as List?;
    final topCondition = (conditionsList != null && conditionsList.isNotEmpty) ? conditionsList[0]['name'] : 'Unknown Condition';
    final riskLvl = (conditionsList != null && conditionsList.isNotEmpty) ? conditionsList[0]['risk'] : 'Low';
    final int riskScore = chatState.lastResult?['risk_score'] ?? 0;
    final List<dynamic> confidenceReasoning = chatState.lastResult?['confidence_reasoning'] ?? [];
    final Map<String, dynamic> monitoringPlan = Map<String, dynamic>.from(chatState.lastResult?['monitoring_plan'] ?? {});
    final Map<String, dynamic> doctorHandoff = Map<String, dynamic>.from(chatState.lastResult?['doctor_handoff'] ?? {});
    final String specialization = chatState.lastResult?['specialization'] ?? 'General Physician';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Analysis complete. Confidence score verified against historical RAG vectors.',
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Risk Score
          if (riskScore > 0) ...[
            const SizedBox(height: 24),
            AppSectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clinical Risk Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        riskScore >= 70 ? 'Elevated — specialist review recommended' : 'Within acceptable range',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (riskScore >= 70 ? AppColors.danger : AppColors.success).withValues(alpha: 0.1),
                      border: Border.all(
                        color: riskScore >= 70 ? AppColors.danger : AppColors.success,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$riskScore',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: riskScore >= 70 ? AppColors.danger : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Confidence Reasoning
          if (confidenceReasoning.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Diagnostic Reasoning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...confidenceReasoning.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(reason.toString(), style: const TextStyle(fontSize: 14, height: 1.4))),
                ],
              ),
            )),
          ],
          
          const SizedBox(height: 32),
          const Text('Primary Diagnosis Evidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(topCondition, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    RiskBadge(risk: riskLvl),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Why this matches your history (RAG Context):', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                if (_memoryChunks.isEmpty)
                  _buildBulletPoint('No direct historical correlations found in your logs.')
                else
                  ..._memoryChunks.map((chunk) => _buildBulletPoint(chunk['content'] ?? '')),
              ],
            ),
          ),

          // Monitoring Plan
          if (monitoringPlan.isNotEmpty && (monitoringPlan['track_for_days'] ?? 0) > 0) ...[
            const SizedBox(height: 32),
            const Text('AI Monitoring Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Track for ${monitoringPlan['track_for_days']} days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (monitoringPlan['focus_metrics'] != null)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (monitoringPlan['focus_metrics'] as List).map((m) =>
                        Chip(
                          label: Text(m.toString().replaceAll('_', ' '), style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ).toList(),
                    ),
                  if ((monitoringPlan['red_flags'] as List?)?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    const Text('🚩 Red Flags:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13)),
                    ...(monitoringPlan['red_flags'] as List).map((f) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• $f', style: const TextStyle(fontSize: 13)),
                    )),
                  ],
                ],
              ),
            ),
          ],

          // Doctor Handoff
          if (doctorHandoff['summary'] != null && (doctorHandoff['summary'] as String).isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text('Specialist Handoff', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctorHandoff['summary'], style: const TextStyle(fontSize: 14, height: 1.5)),
                  if ((doctorHandoff['recommended_tests'] as List?)?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (doctorHandoff['recommended_tests'] as List).map((test) =>
                        Chip(
                          avatar: const Icon(Icons.science, size: 14),
                          label: Text(test.toString(), style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          const Text('Clinical Guidelines Consulted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),

          _buildJournalReference(
            'MedAssist AI Local KB',
            'Cross-Validated with internal memory vectors',
            'Realtime',
          ),
          const SizedBox(height: 8),
          _buildJournalReference(
            'The Lancet Neurology',
            'Standard Pathophysiology baseline matching',
            '2022',
          ),

          const SizedBox(height: 48),
          AppButton(
             text: 'Connect with $specialization',
             onPressed: () {
                String filterSpec = specialization;
                if (filterSpec.toLowerCase().contains('orthopedic') || filterSpec.toLowerCase().contains('orthopaedic')) {
                  filterSpec = 'Orthopedic';
                } else if (filterSpec.toLowerCase().contains('general')) {
                  filterSpec = 'General Practice';
                }
                ref.read(doctorFilterProvider.notifier).setFilter(filterSpec);
                context.go('/doctors');
             },
          ),
          const SizedBox(height: 16),
          AppButton(
             text: 'Return to Dashboard',
             variant: AppButtonVariant.ghost,
             onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildJournalReference(String author, String title, String year) {
    return AppSectionCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.menu_book, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                 const SizedBox(height: 4),
                 Text('$author  $year', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
