import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// AI Reasoning Stream — shows safe high-level reasoning stages
/// during existing isTyping state. Uses shimmer + step progress animation.
/// Pure UI — reads only the isTyping boolean from ChatState.
class AiReasoningStream extends StatefulWidget {
  final String bodyRegion;
  final String specialization;

  const AiReasoningStream({
    super.key,
    this.bodyRegion = 'General',
    this.specialization = 'General Physician',
  });

  @override
  State<AiReasoningStream> createState() => _AiReasoningStreamState();
}

class _AiReasoningStreamState extends State<AiReasoningStream>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _currentStage = 0;

  static const _stages = [
    (
      icon: Icons.text_snippet_rounded,
      label: 'Parsing symptoms',
      color: Color(0xFF3B82F6),
    ),
    (
      icon: Icons.warning_amber_rounded,
      label: 'Checking red flags',
      color: Color(0xFFEF4444),
    ),
    (
      icon: Icons.compare_arrows_rounded,
      label: 'Comparing likely causes',
      color: Color(0xFFF59E0B),
    ),
    (
      icon: Icons.history_rounded,
      label: 'Considering history',
      color: Color(0xFF8B5CF6),
    ),
    (
      icon: Icons.psychology_rounded,
      label: 'Deciding next action',
      color: Color(0xFF10B981),
    ),
    (
      icon: Icons.local_hospital_rounded,
      label: 'Preparing route',
      color: Color(0xFF0EA5E9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (_currentStage < _stages.length - 1) {
              setState(() => _currentStage++);
              _ctrl.forward(from: 0);
            } else {
              // Loop back with pulse
              _ctrl.repeat(reverse: true);
            }
          }
        });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A9FF5), Color(0xFF2563EB)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GlassCard(
              radius: 16,
              blur: 12,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'AI Reasoning',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Pulse dot
                      AnimatedBuilder(
                        animation: _ctrl,
                        builder: (_, _) => Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.5 + 0.5 * _ctrl.value),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3 * _ctrl.value),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Processing…',
                        style: TextStyle(fontSize: 10, color: textSub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Reasoning stages
                  ...List.generate(_stages.length, (i) {
                    final stage = _stages[i];
                    final isComplete = i < _currentStage;
                    final isCurrent = i == _currentStage;
                    final isPending = i > _currentStage;

                    return AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, _) {
                        final opacity = isPending
                            ? 0.25
                            : isCurrent
                            ? 0.5 + 0.5 * _ctrl.value
                            : 1.0;

                        return Opacity(
                          opacity: opacity,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                // Step indicator
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isComplete
                                        ? stage.color.withValues(alpha: 0.18)
                                        : isCurrent
                                        ? stage.color.withValues(alpha: 0.12)
                                        : (isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.05,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.04,
                                                )),
                                    border: Border.all(
                                      color: isCurrent
                                          ? stage.color.withValues(alpha: 0.50)
                                          : Colors.transparent,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: isComplete
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 12,
                                          color: stage.color,
                                        )
                                      : Icon(
                                          stage.icon,
                                          size: 11,
                                          color: isCurrent
                                              ? stage.color
                                              : textSub,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  stage.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isCurrent
                                        ? (isDark
                                              ? Colors.white
                                              : AppColors.textPrimary)
                                        : textSub,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation(
                                        stage.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
