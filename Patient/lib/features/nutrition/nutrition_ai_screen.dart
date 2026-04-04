// NutriAssist AI Coach — Premium Clinical Nutrition Workspace
// UI rewrite matching symptom chat quality. All backend logic preserved.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import 'providers/nutrition_ai_provider.dart';

class NutritionAiScreen extends ConsumerStatefulWidget {
  const NutritionAiScreen({super.key});

  @override
  ConsumerState<NutritionAiScreen> createState() => _NutritionAiScreenState();
}

class _NutritionAiScreenState extends ConsumerState<NutritionAiScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _quickChips = [
    'What should I eat today?',
    'Review my meals',
    'Healthy snack ideas',
    'Am I hitting my macros?',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _sendMessage([String? override]) {
    final text = (override ?? _textController.text).trim();
    if (text.isEmpty) return;
    _textController.clear();
    FocusScope.of(context).unfocus();
    ref.read(nutritionAiProvider.notifier).sendMessage(text);
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

  // ── Status helpers ──────────────────────────────────────────────────────

  String _statusText(NutritionAiState state) {
    if (state.isTyping) return 'Analyzing…';
    if (state.messages.length > 2) return 'Ready';
    return 'Online';
  }

  Color _statusColor(NutritionAiState state) {
    if (state.isTyping) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  // ── BUILD ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(nutritionAiProvider);
    final messages = state.messages;
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
                // 1. FROSTED HEADER
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
                        10,
                      ),
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
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.white,
                                  width: 0.8,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // AI avatar
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Title + status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. NutriAssist',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _statusColor(state),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _statusColor(
                                              state,
                                            ).withValues(alpha: 0.40),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _statusText(state),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Nutrition badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Nutrition AI',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ═══════════════════════════════════════════════════════
                // 2. CHAT TIMELINE
                // ═══════════════════════════════════════════════════════
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && state.isTyping) {
                        return _buildTypingIndicator(isDark);
                      }
                      return _buildRichBubble(messages[index], state, isDark);
                    },
                  ),
                ),

                // ═══════════════════════════════════════════════════════
                // 3. INPUT DOCK
                // ═══════════════════════════════════════════════════════
                _buildInputDock(isDark, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Rich chat bubble ──────────────────────────────────────────────────

  Widget _buildRichBubble(
    Map<String, dynamic> msg,
    NutritionAiState state,
    bool isDark,
  ) {
    final isUser = msg['role'] == 'user';
    final text = msg['text'] ?? '';
    final timestamp = msg['timestamp'] ?? '';
    final flags = msg['flags'] as List<dynamic>?;
    final dailyTip = msg['daily_tip'] as String?;
    final mealSuggestion = msg['meal_suggestion'] as String?;
    final macroNote = msg['macro_note'] as String?;
    final isError = msg['isError'] == true;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    // Determine variant
    _NutriVariant variant = _NutriVariant.standard;
    if (!isUser) {
      if (isError) {
        variant = _NutriVariant.error;
      } else if (flags != null && flags.isNotEmpty) {
        variant = _NutriVariant.warning;
      } else if (text.contains('?')) {
        variant = _NutriVariant.question;
      } else if (text.toLowerCase().contains('great') ||
          text.toLowerCase().contains('excellent') ||
          text.toLowerCase().contains('good choice')) {
        variant = _NutriVariant.praise;
      }
    }

    final variantColor = switch (variant) {
      _NutriVariant.warning => const Color(0xFFF59E0B),
      _NutriVariant.error => const Color(0xFFEF4444),
      _NutriVariant.question => const Color(0xFF8B5CF6),
      _NutriVariant.praise => const Color(0xFF10B981),
      _ => const Color(0xFF10B981),
    };

    final variantIcon = switch (variant) {
      _NutriVariant.warning => Icons.warning_amber_rounded,
      _NutriVariant.error => Icons.error_outline_rounded,
      _NutriVariant.question => Icons.help_outline_rounded,
      _NutriVariant.praise => Icons.thumb_up_alt_rounded,
      _ => Icons.eco_rounded,
    };

    final variantLabel = switch (variant) {
      _NutriVariant.warning => 'Food Alert',
      _NutriVariant.error => 'Connection Issue',
      _NutriVariant.question => 'Follow-up',
      _NutriVariant.praise => 'Great Choice!',
      _ => 'Dr. NutriAssist',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [variantColor.withValues(alpha: 0.80), variantColor],
                ),
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
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          )
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
                            width: 0.7,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser ? const Color(0xFF10B981) : Colors.black)
                            .withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Variant label
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: variantColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              variantLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: variantColor,
                              ),
                            ),
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

                      // Timestamp
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isUser) ...[
                            Icon(
                              Icons.done_all,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            timestamp,
                            style: TextStyle(
                              fontSize: 9,
                              color: isUser
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : textSub,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flags inline cards
                if (!isUser && flags != null && flags.isNotEmpty)
                  _buildFlagCards(flags, isDark),

                // Tip card
                if (!isUser && dailyTip != null && dailyTip.isNotEmpty)
                  _buildInfoCard(
                    Icons.lightbulb_outline_rounded,
                    'Daily Tip',
                    dailyTip,
                    const Color(0xFFF59E0B),
                    isDark,
                  ),

                // Meal suggestion card
                if (!isUser &&
                    mealSuggestion != null &&
                    mealSuggestion.isNotEmpty)
                  _buildInfoCard(
                    Icons.restaurant_rounded,
                    'Meal Idea',
                    mealSuggestion,
                    const Color(0xFF10B981),
                    isDark,
                  ),

                // Macro note
                if (!isUser && macroNote != null && macroNote.isNotEmpty)
                  _buildInfoCard(
                    Icons.bar_chart_rounded,
                    'Macro Check',
                    macroNote,
                    const Color(0xFF3B82F6),
                    isDark,
                  ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ── Flag cards ────────────────────────────────────────────────────────

  Widget _buildFlagCards(List<dynamic> flags, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: flags.map<Widget>((flag) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                width: 0.6,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.80),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${flag['food']} — ${flag['issue']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${flag['advice']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.60)
                        : const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Info card (tip / meal / macro) ─────────────────────────────────────

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String text,
    Color color,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 0.6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.65)
                          : const Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Typing indicator ──────────────────────────────────────────────────

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF10B981).withValues(alpha: 0.08)
                  : const Color(0xFF10B981).withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      const Color(0xFF10B981).withValues(alpha: 0.60),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Analyzing your nutrition…',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.50)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input dock ────────────────────────────────────────────────────────

  Widget _buildInputDock(bool isDark, NutritionAiState state) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.65),
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.paddingOf(context).bottom + 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick suggestion chips
              if (state.messages.length <= 2)
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickChips.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        onTap: () => _sendMessage(_quickChips[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.20),
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            _quickChips[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (state.messages.length <= 2) const SizedBox(height: 8),

              // Input row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFE2E8F0),
                          width: 0.6,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask about meals, diets, nutrition…',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: state.isTyping ? null : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: state.isTyping
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                        color: state.isTyping
                            ? (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : const Color(0xFFF1F5F9))
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: state.isTyping
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: state.isTyping
                            ? (isDark
                                  ? Colors.white.withValues(alpha: 0.20)
                                  : const Color(0xFF94A3B8))
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NutriVariant { standard, warning, error, question, praise }
