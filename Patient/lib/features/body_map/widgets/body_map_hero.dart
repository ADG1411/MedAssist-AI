import 'package:flutter/material.dart';
import '../../../core/widgets/interactive_body_map.dart';

/// Interactive Diagnostic Hero — wraps the existing InteractiveBodyMap
/// with a selected-region breadcrumb, AI confidence text, and
/// front/back toggle. Pure UI widget — all tap detection untouched.
class BodyMapHero extends StatelessWidget {
  final BodyPart? selectedPart;
  final String? selectedRegionLabel;
  final bool isFrontView;
  final ValueChanged<BodyPart> onPartSelected;
  final VoidCallback onToggleView;

  const BodyMapHero({
    super.key,
    required this.selectedPart,
    this.selectedRegionLabel,
    required this.isFrontView,
    required this.onPartSelected,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Body map
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InteractiveBodyMap(
              selectedPart: selectedPart,
              onPartSelected: onPartSelected,
            ),
          ),
        ),

        // Front/Back toggle — top right
        Positioned(
          top: 8,
          right: 12,
          child: GestureDetector(
            onTap: onToggleView,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flip_rounded,
                      size: 14,
                      color: isDark ? Colors.white : const Color(0xFF3B82F6)),
                  const SizedBox(width: 4),
                  Text(
                    isFrontView ? 'Front' : 'Back',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? Colors.white : const Color(0xFF3B82F6)),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Selected region breadcrumb — bottom
        if (selectedRegionLabel != null)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      width: 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location_rounded,
                        size: 13, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    Text(
                      'AI identified pain in $selectedRegionLabel',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
