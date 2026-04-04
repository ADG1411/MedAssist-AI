import 'package:flutter/material.dart';

/// AI Triage Preview Card — shows live AI analysis preview before
/// submission. Displays likely diagnostic paths based on selected
/// region, severity, and symptoms. Red flag detector included.
/// Pure UI widget.
class AiTriagePreviewCard extends StatelessWidget {
  final String? region;
  final Set<String> symptoms;
  final String? movementImpact;

  const AiTriagePreviewCard({
    super.key,
    this.region,
    this.symptoms = const {},
    this.movementImpact,
  });

  bool get _hasRedFlags {
    final s = symptoms.map((e) => e.toLowerCase()).toSet();
    final m = (movementImpact ?? '').toLowerCase();
    return s.contains('severe') ||
        m.contains('numbness') ||
        m.contains('weakness') ||
        m.contains('cannot move');
  }

  List<_TriagePath> _paths() {
    final r = (region ?? '').toLowerCase();
    final s = symptoms.map((e) => e.toLowerCase()).toSet();

    if (r.contains('head')) {
      return [
        const _TriagePath('Tension headache', Color(0xFF3B82F6), 0.45),
        const _TriagePath('Migraine pattern', Color(0xFF8B5CF6), 0.25),
        const _TriagePath('Sinusitis', Color(0xFF0EA5E9), 0.15),
        const _TriagePath('Neurological review', Color(0xFFEF4444), 0.10),
      ];
    }
    if (r.contains('chest')) {
      return [
        const _TriagePath('Musculoskeletal strain', Color(0xFF3B82F6), 0.35),
        const _TriagePath('Gastric reflux', Color(0xFFF59E0B), 0.25),
        const _TriagePath('Cardiac screening', Color(0xFFEF4444), 0.20),
        const _TriagePath('Respiratory check', Color(0xFF0EA5E9), 0.15),
      ];
    }
    if (r.contains('abdomen') || r.contains('stomach')) {
      return [
        const _TriagePath('Gastritis / Acid reflux', Color(0xFFF59E0B), 0.35),
        const _TriagePath('IBS pattern', Color(0xFF8B5CF6), 0.25),
        const _TriagePath('Appendicitis screening', Color(0xFFEF4444), 0.15),
        const _TriagePath('Food intolerance', Color(0xFF10B981), 0.15),
      ];
    }
    if (r.contains('knee') || r.contains('shin') || r.contains('thigh')) {
      return [
        const _TriagePath('Muscle strain', Color(0xFF3B82F6), 0.35),
        const _TriagePath('Ligament injury', Color(0xFFF97316), 0.25),
        const _TriagePath('Arthritis pattern', Color(0xFF8B5CF6), 0.20),
        if (s.contains('severe'))
          const _TriagePath('Fracture risk', Color(0xFFEF4444), 0.15),
      ];
    }
    // Default for arms, shoulders, etc.
    return [
      const _TriagePath('Muscle strain', Color(0xFF3B82F6), 0.40),
      const _TriagePath('Tendon irritation', Color(0xFFF59E0B), 0.25),
      const _TriagePath('Nerve compression', Color(0xFF8B5CF6), 0.20),
      if (_hasRedFlags)
        const _TriagePath('Fracture risk', Color(0xFFEF4444), 0.10),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (region == null || symptoms.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paths = _paths();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Red flag warning
        if (_hasRedFlags) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                  width: 0.7),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Possible nerve or fracture risk — AI may recommend urgent review.',
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Triage header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                width: 0.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 10, color: Colors.white),
                        SizedBox(width: 3),
                        Text('AI Preview',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Likely analysis paths',
                      style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.40)
                              : Colors.grey,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 10),

              // Paths
              ...paths.map((path) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: path.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(path.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B))),
                        ),
                        SizedBox(
                          width: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: path.probability,
                              minHeight: 3,
                              backgroundColor:
                                  path.color.withValues(alpha: 0.10),
                              valueColor:
                                  AlwaysStoppedAnimation(path.color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _TriagePath {
  final String label;
  final Color color;
  final double probability;
  const _TriagePath(this.label, this.color, this.probability);
}
