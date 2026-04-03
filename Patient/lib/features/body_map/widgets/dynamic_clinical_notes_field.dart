import 'package:flutter/material.dart';

/// Dynamic Clinical Notes Field — contextual placeholder that changes
/// based on selected body region. Keyboard-safe. Pure UI widget.
class DynamicClinicalNotesField extends StatelessWidget {
  final String? region;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const DynamicClinicalNotesField({
    super.key,
    this.region,
    required this.controller,
    required this.onChanged,
  });

  String _placeholder() {
    final r = (region ?? '').toLowerCase();
    if (r.contains('head')) {
      return 'e.g. Pain behind eyes, light sensitivity, dizziness…';
    }
    if (r.contains('chest')) {
      return 'e.g. Tightness when breathing, radiating to arm…';
    }
    if (r.contains('abdomen') || r.contains('stomach')) {
      return 'e.g. Pain after spicy food, bloating, nausea…';
    }
    if (r.contains('arm') || r.contains('shoulder') || r.contains('elbow')) {
      return 'e.g. Started after gym push workout, pain while lifting…';
    }
    if (r.contains('knee') || r.contains('shin') || r.contains('thigh')) {
      return 'e.g. Swelling after running, clicking sound when bending…';
    }
    if (r.contains('foot')) {
      return 'e.g. Sharp pain when walking, swollen ankle…';
    }
    if (r.contains('neck')) {
      return 'e.g. Stiff neck, pain turning head, started after sleeping…';
    }
    if (r.contains('hip') || r.contains('pelvis')) {
      return 'e.g. Pain when sitting, radiating down leg…';
    }
    return 'e.g. Describe when it started, what makes it worse…';
  }

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
                color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('6',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF14B8A6))),
              ),
            ),
            const SizedBox(width: 8),
            Text('Tell us more',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B))),
            const SizedBox(width: 6),
            Text('(optional)',
                style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.30)
                        : Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          minLines: 2,
          onChanged: onChanged,
          style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: _placeholder(),
            hintStyle: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.grey.shade400),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF3B82F6), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
