import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/chat_bubble.dart';
import '../../shared/widgets/typing_indicator.dart';
import '../../shared/widgets/ai_mode_badge.dart';
import '../../shared/widgets/severity_slider.dart';
import '../../shared/widgets/voice_input_sheet.dart';
import '../../shared/widgets/gradient_search_bar.dart';
import '../body_map/providers/symptom_check_provider.dart';
import 'providers/chat_provider.dart';

class SymptomChatScreen extends ConsumerStatefulWidget {
  const SymptomChatScreen({super.key});

  @override
  ConsumerState<SymptomChatScreen> createState() => _SymptomChatScreenState();
}

class _SymptomChatScreenState extends ConsumerState<SymptomChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  double _severity = 5;
  bool _sentInitialContext = false;
  bool _showSeverity = false;

  late AnimationController _bannerController;
  late Animation<double> _bannerAnimation;

  String get _bodyPart {
    final symptomState = ref.read(symptomCheckProvider);
    return symptomState.selectedRegion ?? 'General Body';
  }

  List<String> get _symptomDescriptors {
    final symptomState = ref.read(symptomCheckProvider);
    return symptomState.selectedSymptoms.toList();
  }

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bannerAnimation = CurvedAnimation(parent: _bannerController, curve: Curves.easeOutBack);
    _bannerController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialContext();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _sendInitialContext() {
    if (_sentInitialContext) return;
    _sentInitialContext = true;

    final symptomState = ref.read(symptomCheckProvider);
    final region = _bodyPart;
    final descriptors = _symptomDescriptors;

    if (region != 'General Body' || descriptors.isNotEmpty) {
      final buffer = StringBuffer('I have pain in my $region. ');
      if (descriptors.isNotEmpty) {
        buffer.write('It feels ${descriptors.join(", ").toLowerCase()}. ');
      }
      if (symptomState.duration.isNotEmpty) {
        buffer.write('Duration: ${symptomState.duration}. ');
      }
      if (symptomState.additionalNotes.isNotEmpty) {
        buffer.write('Additional details: ${symptomState.additionalNotes}');
      }
      ref.read(chatProvider.notifier).sendMessage(buffer.toString().trim(), _severity, region);
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text, _severity, _bodyPart);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Color _severityColor(double val) {
    if (val <= 3) return AppColors.success;
    if (val <= 7) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final messages = state.messages;
    final bodyRegion = _bodyPart;
    final hasConditions = state.lastResult?['conditions'] != null &&
        (state.lastResult!['conditions'] as List).isNotEmpty;

    return BaseScreen(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A9FF5), Color(0xFF2563EB)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MedAssist AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: state.isTyping ? AppColors.warning : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.isTyping ? 'Analyzing...' : 'Online',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: AiModeBadge(mode: AiMode.fast),
          ),
          if (hasConditions)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () => context.push('/ai-result'),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment_turned_in, color: AppColors.success, size: 18),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Body region banner
          ScaleTransition(
            scale: _bannerAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bodyRegion,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                        ),
                        if (_symptomDescriptors.isNotEmpty)
                          Text(
                            _symptomDescriptors.join('  '),
                            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.6), fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  // Severity indicator
                  GestureDetector(
                    onTap: () => setState(() => _showSeverity = !_showSeverity),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _severityColor(_severity).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _severityColor(_severity).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.speed, size: 14, color: _severityColor(_severity)),
                          const SizedBox(width: 4),
                          Text(
                            '${_severity.toInt()}/10',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _severityColor(_severity)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Severity slider (collapsible)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showSeverity
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SeveritySlider(
                      value: _severity,
                      onChanged: (val) => setState(() => _severity = val),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: messages.length + (state.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && state.isTyping) {
                  return const TypingIndicator();
                }
                return ChatBubble(message: messages[index]);
              },
            ),
          ),

          // Suggested Replies
          if (!state.isTyping && messages.length > 1)
            Container(
              height: 44,
              padding: const EdgeInsets.only(bottom: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSuggestChip('It aches constantly', Icons.access_time),
                  _buildSuggestChip('Only when I move', Icons.directions_run),
                  _buildSuggestChip('I feel nauseous', Icons.sick),
                  _buildSuggestChip('It\'s getting worse', Icons.trending_up),
                  _buildFinishChip(),
                ],
              ),
            ),

          // Input bar
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 8, top: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.15))),
            ),
            child: GradientSearchBar(
              controller: _controller,
              focusNode: _focusNode,
              hintText: 'Describe your $bodyRegion symptoms...',
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onMicPressed: () {
                VoiceInputSheet.show(
                  context,
                  onResult: (text) {
                    ref.read(chatProvider.notifier).sendMessage(text, _severity, _bodyPart);
                    _scrollToBottom();
                  },
                );
              },
              onSearchPressed: _sendMessage,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: AppColors.primary),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: Theme.of(context).cardColor,
        labelStyle: const TextStyle(color: AppColors.primary),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          _controller.text = label;
          _sendMessage();
        },
      ),
    );
  }

  Widget _buildFinishChip() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: const Icon(Icons.check_circle, size: 14, color: Colors.white),
        label: const Text('View Results', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        labelStyle: const TextStyle(color: Colors.white),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () => context.push('/ai-result'),
      ),
    );
  }
}


