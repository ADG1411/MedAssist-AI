import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Movement Impact Selector — "Does it affect movement?" with chips:
/// no issue, mild discomfort, difficult movement, cannot move,
/// numbness/tingling, weakness. Helps ortho + neuro AI routing.
/// Pure UI widget.
class MovementImpactSelector extends StatelessWidget {
  final String? selectedImpact;
  final ValueChanged<String> onSelect;

  const MovementImpactSelector({
    super.key,
    this.selectedImpact,
    required this.onSelect,
  });

  static const _impacts = [
    _Impact('No movement issue', Icons.check_circle_rounded, Color(0xFF10B981)),
    _Impact('Mild discomfort', Icons.sentiment_neutral_rounded, Color(0xFFF59E0B)),
    _Impact('Difficult movement', Icons.accessibility_new_rounded, Color(0xFFF97316)),
    _Impact('Cannot move', Icons.block_rounded, Color(0xFFEF4444)),
    _Impact('Numbness / Tingling', Icons.electric_bolt_rounded, Color(0xFF8B5CF6)),
    _Impact('Weakness', Icons.trending_down_rounded, Color(0xFF6366F1)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('5',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF4444))),
              ),
            ),
            const SizedBox(width: 8),
            Text('Does it affect movement?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _impacts.map((imp) {
            final isSelected = selectedImpact == imp.label;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(imp.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? imp.color.withValues(alpha: isDark ? 0.18 : 0.10)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? imp.color.withValues(alpha: 0.45)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06)),
                      width: isSelected ? 1.0 : 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(imp.icon,
                        size: 14,
                        color: isSelected
                            ? imp.color
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.30)
                                : Colors.grey)),
                    const SizedBox(width: 5),
                    Text(imp.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? imp.color
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.50)
                                    : Colors.grey.shade600))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Impact {
  final String label;
  final IconData icon;
  final Color color;
  const _Impact(this.label, this.icon, this.color);
}
