// Symptom AI Chat Screen — Premium Clinical Conversation Workspace
// UI-only rewrite. All backend logic preserved: chatProvider, symptomCheckProvider,
// sendMessage, VoiceInputSheet, navigation routes.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/severity_slider.dart';
import '../../shared/widgets/voice_input_sheet.dart';
import '../body_map/providers/symptom_check_provider.dart';
import 'providers/chat_provider.dart';
import 'widgets/clinical_case_summary_card.dart';
import 'widgets/ai_reasoning_stream.dart';
import 'widgets/condition_confidence_card.dart';
import 'widgets/doctor_escalation_card.dart';
import 'widgets/emergency_risk_banner.dart';
import 'widgets/smart_clinical_input_dock.dart';
import 'widgets/diagnosis_outcome_card.dart';
import 'widgets/memory_reference_chip.dart';

class SymptomChatScreen extends ConsumerStatefulWidget {
  const SymptomChatScreen({super.key});

  @override
  ConsumerState<SymptomChatScreen> createState() => _SymptomChatScreenState();
}

class _SymptomChatScreenState extends ConsumerState<SymptomChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  double _severity = 5;
  bool _sentInitialContext = false;
  bool _showSeverity = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Consult elapsed timer
  late Stopwatch _consultStopwatch;
  String _elapsed = '00:00';

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
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _consultStopwatch = Stopwatch()..start();
    _tickTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialContext();
    });
  }

  void _tickTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final secs = _consultStopwatch.elapsed.inSeconds;
      setState(() {
        _elapsed =
            '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';
      });
      _tickTimer();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fadeCtrl.dispose();
    _consultStopwatch.stop();
    super.dispose();
  }

  // ── Existing backend logic (unchanged) ──────────────────────────────────

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
      ref
          .read(chatProvider.notifier)
          .sendMessage(buffer.toString().trim(), _severity, region);
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

  // ── Status text derived from existing state ─────────────────────────────

  String _statusText(ChatState state) {
    if (state.isEmergency) return 'Emergency detected';
    if (state.isTyping) {
      if (state.messages.length <= 2) return 'Analyzing symptoms…';
      if (state.riskScore > 60) return 'Red flag check in progress';
      return 'Reasoning…';
    }
    if (state.action == 'consult_doctor') return 'Doctor escalation ready';
    if (state.conditions.isNotEmpty) return 'Analysis complete';
    return 'Online';
  }

  Color _statusColor(ChatState state) {
    if (state.isEmergency) return const Color(0xFFEF4444);
    if (state.isTyping) return const Color(0xFFF59E0B);
    if (state.action == 'consult_doctor') return const Color(0xFF0EA5E9);
    return const Color(0xFF10B981);
  }

  // ── BUILD ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(chatProvider);
    final messages = state.messages;
    final bodyRegion = _bodyPart;
    final symptomState = ref.read(symptomCheckProvider);
    final hasConditions = state.conditions.isNotEmpty;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ═══════════════════════════════════════════════════════
                // 1. LIVE CONSULT HEADER
                // ═══════════════════════════════════════════════════════
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.30)
                          : Colors.white.withValues(alpha: 0.60),
                      padding: EdgeInsets.fromLTRB(
                          16,
                          MediaQuery.paddingOf(context).top + 10,
                          16,
                          10),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.09)
                                    : Colors.white.withValues(alpha: 0.72),
                                border: Border.all(
                                    color: isDark
                                        ? Colors.white
                                            .withValues(alpha: 0.12)
                                        : Colors.white,
                                    width: 0.8),
                              ),
                              child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // AI avatar
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4A9FF5),
                                    Color(0xFF2563EB)
                                  ]),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome,
                                size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 10),

                          // Title + status
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('MedAssist AI',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                        letterSpacing: -0.3)),
                                Row(
                                  children: [
                                    // Pulse dot
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _statusColor(state),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _statusColor(state)
                                                .withValues(alpha: 0.40),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(_statusText(state),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: textSub)),
                                    const SizedBox(width: 8),
                                    // Timer
                                    Text(_elapsed,
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: textSub,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Specialization badge
                          if (state.specialization !=
                              'General Physician') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6)
                                    ]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(state.specialization,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 6),
                          ],

                          // Results button
                          if (hasConditions)
                            GestureDetector(
                              onTap: () => context.push('/ai-result'),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.15),
                                  border: Border.all(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.30),
                                      width: 0.8),
                                ),
                                child: const Icon(
                                    Icons
                                        .assignment_turned_in_rounded,
                                    size: 16,
                                    color: Color(0xFF10B981)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ═══════════════════════════════════════════════════════
                // 2. STICKY CLINICAL CONTEXT CARD
                // ═══════════════════════════════════════════════════════
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ClinicalCaseSummaryCard(
                    bodyRegion: bodyRegion,
                    symptoms: _symptomDescriptors,
                    severity: _severity,
                    duration: symptomState.duration,
                    riskScore: state.riskScore,
                    specialization: state.specialization,
                    action: state.action,
                    onSeverityTap: () =>
                        setState(() => _showSeverity = !_showSeverity),
                  ),
                ),

                // Severity slider (collapsible)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showSeverity
                      ? Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: SeveritySlider(
                            value: _severity,
                            onChanged: (val) =>
                                setState(() => _severity = val),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ═══════════════════════════════════════════════════════
                // 3 + 4. CHAT TIMELINE + INLINE WIDGETS
                // ═══════════════════════════════════════════════════════
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: messages.length +
                        (state.isTyping ? 1 : 0) +
                        _inlineWidgetCount(state),
                    itemBuilder: (context, index) =>
                        _buildTimelineItem(index, state, messages, isDark),
                  ),
                ),

                // ═══════════════════════════════════════════════════════
                // 5. PREMIUM SMART INPUT DOCK
                // ═══════════════════════════════════════════════════════
                SmartClinicalInputDock(
                  controller: _controller,
                  focusNode: _focusNode,
                  bodyRegion: bodyRegion,
                  isTyping: state.isTyping,
                  onSend: _sendMessage,
                  onVoice: () {
                    VoiceInputSheet.show(
                      context,
                      onResult: (text) {
                        ref
                            .read(chatProvider.notifier)
                            .sendMessage(text, _severity, _bodyPart);
                        _scrollToBottom();
                      },
                    );
                  },
                  onChipTap: (chip) {
                    _controller.text = chip;
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Timeline item builder ───────────────────────────────────────────────

  int _inlineWidgetCount(ChatState state) {
    int count = 0;
    // Emergency banner
    if (state.isEmergency) count++;
    // Conditions card
    if (state.conditions.isNotEmpty) count++;
    // Doctor escalation
    if (state.action == 'consult_doctor') count++;
    // Diagnosis outcome
    if (state.conditions.isNotEmpty && !state.isTyping) count++;
    // Memory reference
    if (state.messages.length > 3) count++;
    return count;
  }

  Widget _buildTimelineItem(
      int index, ChatState state, List<Map<String, dynamic>> messages,
      bool isDark) {
    final msgCount = messages.length;
    final typingOffset = state.isTyping ? 1 : 0;

    // Messages come first
    if (index < msgCount) {
      return _buildRichChatBubble(messages[index], state, isDark);
    }

    // Typing indicator (AI reasoning stream)
    if (state.isTyping && index == msgCount) {
      return AiReasoningStream(
        bodyRegion: _bodyPart,
        specialization: state.specialization,
      );
    }

    // Inline widgets after messages + typing
    final inlineIndex = index - msgCount - typingOffset;
    return _buildInlineWidget(inlineIndex, state, isDark);
  }

  Widget _buildInlineWidget(int inlineIndex, ChatState state, bool isDark) {
    final widgets = <Widget>[];

    // Emergency banner
    if (state.isEmergency) {
      widgets.add(EmergencyRiskBanner(
        likelyCause: state.conditions.isNotEmpty
            ? (state.conditions.first is Map
                ? (state.conditions.first['name']?.toString() ?? '')
                : state.conditions.first.toString())
            : '',
        onTriggerSOS: () => context.push('/sos'),
        onNearestHospital: () => context.push('/nearby-hospitals'),
      ));
    }

    // Memory reference
    if (state.messages.length > 3) {
      widgets.add(MemoryReferenceChip(
        messages: state.messages,
        currentBodyRegion: _bodyPart,
      ));
    }

    // Conditions card
    if (state.conditions.isNotEmpty) {
      widgets.add(ConditionConfidenceCard(conditions: state.conditions));
    }

    // Doctor escalation
    if (state.action == 'consult_doctor') {
      widgets.add(DoctorEscalationCard(
        specialization: state.specialization,
        doctorHandoff: state.doctorHandoff,
        onFindDoctor: () => context.push('/find-doctor',
            extra: {'specialization': state.specialization}),
        onBookConsult: () => context.push('/book-consultation'),
        onShareSummary: () => context.push('/ai-result'),
      ));
    }

    // Diagnosis outcome (final summary)
    if (state.conditions.isNotEmpty && !state.isTyping) {
      widgets.add(DiagnosisOutcomeCard(
        lastResult: state.lastResult,
        conditions: state.conditions,
        riskScore: state.riskScore,
        specialization: state.specialization,
        prescriptionHints: state.prescriptionHints,
        monitoringPlan: state.monitoringPlan,
        onViewFullResults: () => context.push('/ai-result'),
      ));
    }

    if (inlineIndex < widgets.length) return widgets[inlineIndex];
    return const SizedBox.shrink();
  }

  // ── Rich clinical message bubble ────────────────────────────────────────

  Widget _buildRichChatBubble(
      Map<String, dynamic> message, ChatState state, bool isDark) {
    final isUser = message['role'] == 'user';
    final text = message['text'] ?? '';
    final timestamp = message['timestamp'] ?? '';
    final isEmergencyMsg = message['emergency'] == true;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    // Determine AI message visual variant
    _MsgVariant variant = _MsgVariant.standard;
    if (!isUser) {
      if (isEmergencyMsg) {
        variant = _MsgVariant.emergency;
      } else if (text.toLowerCase().contains('consult') ||
          text.toLowerCase().contains('doctor')) {
        variant = _MsgVariant.escalation;
      } else if (text.contains('?')) {
        variant = _MsgVariant.followUp;
      } else if (text.toLowerCase().contains('rest') ||
          text.toLowerCase().contains('ice') ||
          text.toLowerCase().contains('avoid')) {
        variant = _MsgVariant.care;
      }
    }

    final variantColor = switch (variant) {
      _MsgVariant.emergency => const Color(0xFFEF4444),
      _MsgVariant.escalation => const Color(0xFF0EA5E9),
      _MsgVariant.followUp => const Color(0xFF8B5CF6),
      _MsgVariant.care => const Color(0xFF10B981),
      _ => AppColors.primary,
    };

    final variantIcon = switch (variant) {
      _MsgVariant.emergency => Icons.emergency_rounded,
      _MsgVariant.escalation => Icons.medical_services_rounded,
      _MsgVariant.followUp => Icons.help_outline_rounded,
      _MsgVariant.care => Icons.healing_rounded,
      _ => Icons.auto_awesome,
    };

    final variantLabel = switch (variant) {
      _MsgVariant.emergency => 'Emergency Alert',
      _MsgVariant.escalation => 'Doctor Referral',
      _MsgVariant.followUp => 'Follow-up Question',
      _MsgVariant.care => 'Care Instruction',
      _ => 'MedAssist AI',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  variantColor.withValues(alpha: 0.80),
                  variantColor,
                ]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: variantColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(variantIcon, size: 15, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)])
                    : null,
                color: isUser
                    ? null
                    : (isDark
                        ? variantColor.withValues(alpha: 0.08)
                        : variantColor.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: variantColor.withValues(alpha: 0.15),
                        width: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? AppColors.primary : Colors.black)
                        .withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Variant label for AI messages
                  if (!isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: variantColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(variantLabel,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: variantColor)),
                      ),
                    ),

                  // Message text
                  Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : textPrimary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Footer: timestamp + confidence
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUser) ...[
                        Icon(Icons.done_all,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.65)),
                        const SizedBox(width: 4),
                      ],
                      Text(timestamp,
                          style: TextStyle(
                              fontSize: 9,
                              color: isUser
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : textSub)),
                      if (!isUser && state.riskScore > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: variantColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                              'Risk ${state.riskScore}%',
                              style: TextStyle(
                                  fontSize: 8,
                                  color: variantColor,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

enum _MsgVariant { standard, followUp, emergency, escalation, care }


