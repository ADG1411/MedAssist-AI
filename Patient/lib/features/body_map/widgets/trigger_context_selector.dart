import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Trigger Context Selector — "What caused this?" with chips:
/// after exercise, fall, lifting, sleeping, food, walking, stress,
/// no clear trigger. Improves AI diagnosis. Pure UI widget.
class TriggerContextSelector extends StatelessWidget {
  final String? selectedTrigger;
  final ValueChanged<String> onSelect;

  const TriggerContextSelector({
    super.key,
    this.selectedTrigger,
    required this.onSelect,
  });

  static const _triggers = [
    _Trigger('After exercise', Icons.fitness_center_rounded, Color(0xFF3B82F6)),
    _Trigger('After a fall', Icons.arrow_downward_rounded, Color(0xFFEF4444)),
    _Trigger('After lifting', Icons.upload_rounded, Color(0xFFF97316)),
    _Trigger('While sleeping', Icons.bedtime_rounded, Color(0xFF6366F1)),
    _Trigger('After food', Icons.restaurant_rounded, Color(0xFFF59E0B)),
    _Trigger('After walking', Icons.directions_walk_rounded, Color(0xFF10B981)),
    _Trigger('Stress related', Icons.psychology_rounded, Color(0xFF8B5CF6)),
    _Trigger('No clear trigger', Icons.help_outline_rounded, Color(0xFF64748B)),
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
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('4',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF59E0B))),
              ),
            ),
            const SizedBox(width: 8),
            Text('What caused this?',
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
          children: _triggers.map((t) {
            final isSelected = selectedTrigger == t.label;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(t.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? t.color.withValues(alpha: isDark ? 0.18 : 0.10)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? t.color.withValues(alpha: 0.45)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06)),
                      width: isSelected ? 1.0 : 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon,
                        size: 14,
                        color: isSelected
                            ? t.color
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.30)
                                : Colors.grey)),
                    const SizedBox(width: 5),
                    Text(t.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? t.color
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

class _Trigger {
  final String label;
  final IconData icon;
  final Color color;
  const _Trigger(this.label, this.icon, this.color);
}
