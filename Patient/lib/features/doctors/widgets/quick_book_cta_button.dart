import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium gradient pill CTA button used across doctor booking flows.
class QuickBookCtaButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Color> gradientColors;
  final double height;
  final double fontSize;

  const QuickBookCtaButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.gradientColors = const [Color(0xFF2A7FFF), Color(0xFF6366F1)],
    this.height = 44,
    this.fontSize = 13,
  });

  @override
  State<QuickBookCtaButton> createState() => _QuickBookCtaButtonState();
}

class _QuickBookCtaButtonState extends State<QuickBookCtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: widget.onTap == null ? 0.45 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  const SizedBox(width: 14),
                  Icon(widget.icon!, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: widget.icon == null ? 20 : 12),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
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
