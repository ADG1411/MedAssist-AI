import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pain Severity Selector — doctor-style question "How severe is it?"
/// with premium chips: Mild, Moderate, Severe. Color-coded. Pure UI widget.
class PainSeveritySelector extends StatelessWidget {
  final Set<String> selectedSymptoms;
  final ValueChanged<String> onToggle;

  const PainSeveritySelector({
    super.key,
    required this.selectedSymptoms,
    required this.onToggle,
  });

  static const _severities = [
    _Severity('Mild', Color(0xFF10B981), Icons.sentiment_satisfied_rounded),
    _Severity('Moderate', Color(0xFFF59E0B), Icons.sentiment_neutral_rounded),
    _Severity('Severe', Color(0xFFEF4444), Icons.sentiment_very_dissatisfied_rounded),
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
                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('1',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3B82F6))),
              ),
            ),
            const SizedBox(width: 8),
            Text('How severe is it?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: _severities.map((s) {
            final isSelected = selectedSymptoms.contains(s.label);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: s == _severities.last ? 0 : 6),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onToggle(s.label);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? s.color.withValues(alpha: isDark ? 0.20 : 0.10)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? s.color.withValues(alpha: 0.50)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06)),
                          width: isSelected ? 1.2 : 0.6),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: s.color.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(s.icon,
                            size: 22,
                            color: isSelected
                                ? s.color
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.30)
                                    : Colors.grey)),
                        const SizedBox(height: 4),
                        Text(s.label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? s.color
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.50)
                                        : Colors.grey))),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Severity {
  final String label;
  final Color color;
  final IconData icon;
  const _Severity(this.label, this.color, this.icon);
}
