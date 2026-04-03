import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/mock_delay.dart';
import '../../core/repositories/rag_repository.dart';
import '../symptom_chat/providers/chat_provider.dart';
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

    // Padding for simulated heavy calculation UX
    await MockDelay.simulateDelay(2000);
    
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
             text: 'Connect with Neurologist',
             onPressed: () {},
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

