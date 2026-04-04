import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sensation Chip Grid — "What does it feel like?" with premium
/// multi-select chips: Burning, Sharp, Dull, Throbbing, Aching,
/// Stabbing, Cramping, Tingling. Pure UI widget.
class SensationChipGrid extends StatelessWidget {
  final Set<String> selectedSymptoms;
  final ValueChanged<String> onToggle;

  const SensationChipGrid({
    super.key,
    required this.selectedSymptoms,
    required this.onToggle,
  });

  static const _sensations = [
    _Chip('Burning', Icons.local_fire_department_rounded, Color(0xFFEF4444)),
    _Chip('Sharp', Icons.flash_on_rounded, Color(0xFFF59E0B)),
    _Chip('Dull', Icons.circle_outlined, Color(0xFF64748B)),
    _Chip('Throbbing', Icons.waves_rounded, Color(0xFF8B5CF6)),
    _Chip('Aching', Icons.compress_rounded, Color(0xFF3B82F6)),
    _Chip('Stabbing', Icons.arrow_downward_rounded, Color(0xFFEF4444)),
    _Chip('Cramping', Icons.autorenew_rounded, Color(0xFFF97316)),
    _Chip('Tingling', Icons.electric_bolt_rounded, Color(0xFF0EA5E9)),
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
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('2',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8B5CF6))),
              ),
            ),
            const SizedBox(width: 8),
            Text('What does it feel like?',
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
          children: _sensations.map((chip) {
            final isSelected = selectedSymptoms.contains(chip.label);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onToggle(chip.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chip.color.withValues(alpha: isDark ? 0.18 : 0.10)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? chip.color.withValues(alpha: 0.45)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06)),
                      width: isSelected ? 1.0 : 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(chip.icon,
                        size: 14,
                        color: isSelected
                            ? chip.color
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.30)
                                : Colors.grey)),
                    const SizedBox(width: 5),
                    Text(chip.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? chip.color
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

class _Chip {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip(this.label, this.icon, this.color);
}
