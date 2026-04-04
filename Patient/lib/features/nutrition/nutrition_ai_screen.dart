// NutriAssist AI Coach — Clean Blue Theme
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import 'providers/nutrition_ai_provider.dart';

// ── Accent color (unified blue) ────────────────────────────────────────────
const _kNutri = AppColors.primary;
const _kNutriDark = Color(0xFF2563EB);

class NutritionAiScreen extends ConsumerStatefulWidget {
  const NutritionAiScreen({super.key});

  @override
  ConsumerState<NutritionAiScreen> createState() => _NutritionAiScreenState();
}

class _NutritionAiScreenState extends ConsumerState<NutritionAiScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  static const _chips = [
    'What should I eat today?',
    'Review my meals',
    'Healthy snack ideas',
    'Am I hitting my macros?',
  ];

  @override
<<<<<<< HEAD
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
=======
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send([String? override]) {
    final text = (override ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _ctrl.clear();
    FocusScope.of(context).unfocus();
    ref.read(nutritionAiProvider.notifier).sendMessage(text);
    _scrollBottom();
  }

  void _scrollBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final st = ref.watch(nutritionAiProvider);
    final msgs = st.messages;
    final tp = isDark ? Colors.white : AppColors.textPrimary;
    final ts = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
<<<<<<< HEAD
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
=======
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [_kNutri, _kNutriDark]),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco_rounded, size: 20, color: Colors.white),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NutriAssist', style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800, color: tp, letterSpacing: -0.5)),
                            const SizedBox(height: 1),
                            Row(children: [
                              Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: st.isTyping ? const Color(0xFFF59E0B) : _kNutri,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                st.isTyping ? 'Analyzing…' : 'Online',
                                style: TextStyle(fontSize: 11, color: ts),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kNutri.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.eco_rounded, size: 12, color: _kNutri),
                          const SizedBox(width: 4),
                          Text('AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kNutri)),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Chat ───────────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
<<<<<<< HEAD
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && state.isTyping) {
                        return _buildTypingIndicator(isDark);
                      }
                      return _buildRichBubble(messages[index], state, isDark);
=======
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    itemCount: msgs.length + (st.isTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == msgs.length && st.isTyping) return _typing(isDark);
                      return _bubble(msgs[i], isDark);
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                    },
                  ),
                ),

                // ── Input dock ─────────────────────────────────────────
                _inputDock(isDark, st),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUBBLE
  // ═══════════════════════════════════════════════════════════════════════════

<<<<<<< HEAD
  Widget _buildRichBubble(
    Map<String, dynamic> msg,
    NutritionAiState state,
    bool isDark,
  ) {
=======
  Widget _bubble(Map<String, dynamic> msg, bool isDark) {
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
    final isUser = msg['role'] == 'user';
    final text = msg['text'] ?? '';
    final ts = msg['timestamp'] ?? '';
    final flags = msg['flags'] as List<dynamic>?;
    final tip = msg['daily_tip'] as String?;
    final meal = msg['meal_suggestion'] as String?;
    final macro = msg['macro_note'] as String?;
    final isErr = msg['isError'] == true;
    final tp = isDark ? Colors.white : AppColors.textPrimary;
    final tsColor = isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.textSecondary;

    // Variant
    Color vc = _kNutri;
    IconData vi = Icons.eco_rounded;
    String vl = 'NutriAssist';
    if (!isUser) {
      if (isErr) { vc = const Color(0xFFEF4444); vi = Icons.error_outline_rounded; vl = 'Error'; }
      else if (flags != null && flags.isNotEmpty) { vc = const Color(0xFFF59E0B); vi = Icons.warning_amber_rounded; vl = 'Food Alert'; }
      else if (text.toString().contains('?')) { vc = const Color(0xFF8B5CF6); vi = Icons.help_outline_rounded; vl = 'Follow-up'; }
      else if (text.toString().toLowerCase().contains('great') || text.toString().toLowerCase().contains('excellent')) {
        vc = _kNutri; vi = Icons.thumb_up_alt_rounded; vl = 'Great Choice!';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
<<<<<<< HEAD
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
=======
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
<<<<<<< HEAD
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
=======
              width: 30, height: 30,
              decoration: BoxDecoration(shape: BoxShape.circle, color: vc.withValues(alpha: 0.12)),
              child: Icon(vi, size: 14, color: vc),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
<<<<<<< HEAD
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
=======
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isUser
<<<<<<< HEAD
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          )
                        : null,
                    color: isUser
                        ? null
                        : (isDark
                              ? variantColor.withValues(alpha: 0.08)
                              : variantColor.withValues(alpha: 0.05)),
=======
                        ? const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)])
                        : null,
                    color: isUser ? null : (isDark ? vc.withValues(alpha: 0.06) : vc.withValues(alpha: 0.04)),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
<<<<<<< HEAD
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
=======
                    border: isUser ? null : Border.all(color: vc.withValues(alpha: 0.12), width: 0.5),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Padding(
<<<<<<< HEAD
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
=======
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(vl, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: vc)),
                        ),
                      Text(text, style: TextStyle(color: isUser ? Colors.white : tp, fontSize: 14, height: 1.4)),
                      const SizedBox(height: 4),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        if (isUser) ...[
                          Icon(Icons.done_all, size: 12, color: Colors.white.withValues(alpha: 0.60)),
                          const SizedBox(width: 3),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                        ],
                        Text(ts, style: TextStyle(
                          fontSize: 9, color: isUser ? Colors.white.withValues(alpha: 0.60) : tsColor)),
                      ]),
                    ],
                  ),
                ),
<<<<<<< HEAD

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
=======
                // Extra cards
                if (!isUser && flags != null && flags.isNotEmpty) _flagCards(flags, isDark),
                if (!isUser && tip != null && tip.isNotEmpty)
                  _infoCard(Icons.lightbulb_outline_rounded, 'Daily Tip', tip, const Color(0xFFF59E0B), isDark),
                if (!isUser && meal != null && meal.isNotEmpty)
                  _infoCard(Icons.restaurant_rounded, 'Meal Idea', meal, _kNutri, isDark),
                if (!isUser && macro != null && macro.isNotEmpty)
                  _infoCard(Icons.bar_chart_rounded, 'Macro Check', macro, AppColors.primary, isDark),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Flag cards ─────────────────────────────────────────────────────────

  Widget _flagCards(List<dynamic> flags, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
<<<<<<< HEAD
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
=======
        children: flags.map<Widget>((f) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.15), width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Expanded(child: Text('${f['food']} — ${f['issue']}', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309)))),
            ]),
            const SizedBox(height: 3),
            Text('${f['advice']}', style: TextStyle(
              fontSize: 11, height: 1.3,
              color: isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF475569))),
          ]),
        )).toList(),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
      ),
    );
  }

  // ── Info card ──────────────────────────────────────────────────────────

<<<<<<< HEAD
  Widget _buildInfoCard(
    IconData icon,
    String label,
    String text,
    Color color,
    bool isDark,
  ) {
=======
  Widget _infoCard(IconData icon, String label, String text, Color c, bool isDark) {
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: isDark ? 0.07 : 0.04),
          borderRadius: BorderRadius.circular(12),
<<<<<<< HEAD
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
=======
          border: Border.all(color: c.withValues(alpha: 0.12), width: 0.5),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.10)),
            child: Icon(icon, size: 12, color: c),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
            const SizedBox(height: 2),
            Text(text, style: TextStyle(
              fontSize: 12, height: 1.3,
              color: isDark ? Colors.white.withValues(alpha: 0.60) : const Color(0xFF334155))),
          ])),
        ]),
      ),
    );
  }

  // ── Typing indicator ──────────────────────────────────────────────────

  Widget _typing(bool isDark) {
    return Padding(
<<<<<<< HEAD
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
=======
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _kNutri.withValues(alpha: 0.12)),
          child: const Icon(Icons.eco_rounded, size: 14, color: _kNutri),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _kNutri.withValues(alpha: isDark ? 0.06 : 0.04),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: _kNutri.withValues(alpha: 0.12), width: 0.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(_kNutri.withValues(alpha: 0.60))),
            ),
            const SizedBox(width: 8),
            Text('Analyzing…', style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B))),
          ]),
        ),
      ]),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT DOCK
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _inputDock(bool isDark, NutritionAiState st) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
<<<<<<< HEAD
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
=======
          color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.60),
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.paddingOf(context).bottom + 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Quick chips
            if (st.messages.length <= 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _chips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _send(_chips[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : _kNutri.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kNutri.withValues(alpha: 0.15), width: 0.5),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                        ),
                        child: Text(_chips[i], style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: isDark ? _kNutri : _kNutriDark)),
                      ),
                    ),
                  ),
                ),
<<<<<<< HEAD
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
=======
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
              ),

            // Input row
            Row(children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border.withValues(alpha: 0.5),
                      width: 0.5),
                    boxShadow: [
                      if (!isDark) BoxShadow(color: _kNutri.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask about meals, nutrition…',
                      hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.25) : AppColors.textHint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: st.isTyping ? null : () => _send(),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: st.isTyping ? null : const LinearGradient(colors: [_kNutri, _kNutriDark]),
                    color: st.isTyping ? (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)) : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: st.isTyping ? null : [
                      BoxShadow(color: _kNutri.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.send_rounded, size: 18,
                    color: st.isTyping ? (isDark ? Colors.white.withValues(alpha: 0.20) : AppColors.textHint) : Colors.white),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
