import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Premium smart input dock — glass dock with voice, attach, smart symptom
/// chips, dynamic placeholder. Uses existing TextEditingController and
/// send callback. Pure UI widget.
class SmartClinicalInputDock extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String bodyRegion;
  final bool isTyping;
  final VoidCallback onSend;
  final VoidCallback? onVoice;
  final VoidCallback? onAttachImage;
  final ValueChanged<String>? onChipTap;

  const SmartClinicalInputDock({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.bodyRegion,
    required this.isTyping,
    required this.onSend,
    this.onVoice,
    this.onAttachImage,
    this.onChipTap,
  });

  List<String> get _smartChips {
    final region = bodyRegion.toLowerCase();
    if (region.contains('head')) {
      return ['Throbbing', 'Dizziness', 'After screen', 'Nausea', 'Blurred vision'];
    }
    if (region.contains('chest')) {
      return ['Sharp pain', 'Breathless', 'Palpitations', 'At rest', 'After exertion'];
    }
    if (region.contains('back') || region.contains('spine')) {
      return ['While sitting', 'Radiating', 'Numbness', 'After lifting', 'Morning stiffness'];
    }
    if (region.contains('knee') || region.contains('leg')) {
      return ['While walking', 'Swelling', 'Locking', 'After stairs', 'At night'];
    }
    if (region.contains('shoulder') || region.contains('arm')) {
      return ['Raising arm', 'Numbness', 'After gym', 'While sleeping', 'Sharp pain'];
    }
    if (region.contains('stomach') || region.contains('abdomen')) {
      return ['After eating', 'Bloating', 'Cramping', 'Burning', 'Nausea'];
    }
    return ['It aches constantly', 'Only when moving', 'Getting worse', 'Numbness', 'Burning'];
  }

  String get _dynamicHint {
    final region = bodyRegion.toLowerCase();
    if (region == 'general body') return 'Describe your symptoms in detail…';
    return 'Tell me what worsens the $bodyRegion pain…';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.40)
                : Colors.white.withValues(alpha: 0.75),
            border: Border(
              top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.7),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Smart symptom chips ──────────────────────────────
                if (!isTyping)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemCount: _smartChips.length,
                      itemBuilder: (_, i) {
                        final chip = _smartChips[i];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (onChipTap != null) {
                              onChipTap!(chip);
                            } else {
                              controller.text = chip;
                              controller.selection = TextSelection.fromPosition(
                                  TextPosition(offset: chip.length));
                              onSend();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : AppColors.primary
                                          .withValues(alpha: 0.15),
                                  width: 0.7),
                            ),
                            child: Text(chip,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white
                                            .withValues(alpha: 0.70)
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        );
                      },
                    ),
                  ),

                // ── Input row ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                  child: Row(
                    children: [
                      // Voice
                      if (onVoice != null)
                        _DockAction(
                          icon: Icons.mic_rounded,
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onVoice!();
                          },
                        ),
                      // Attach image
                      if (onAttachImage != null) ...[
                        const SizedBox(width: 4),
                        _DockAction(
                          icon: Icons.add_photo_alternate_rounded,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onAttachImage!();
                          },
                        ),
                      ],
                      const SizedBox(width: 8),

                      // Text field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.black.withValues(alpha: 0.07),
                                width: 0.7),
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onSubmitted: (_) => onSend(),
                            textInputAction: TextInputAction.send,
                            style: TextStyle(
                                fontSize: 14, color: textPrimary),
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: _dynamicHint,
                              hintStyle:
                                  TextStyle(fontSize: 13, color: textSub),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Send button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onSend();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF2563EB)
                            ]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.30),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.send_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DockAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: color.withValues(alpha: 0.22), width: 0.7),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
