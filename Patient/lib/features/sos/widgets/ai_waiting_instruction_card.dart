import 'package:flutter/material.dart';

/// AI Emergency Waiting Instructions — dynamic care panel based on
/// emergency type. Shows step-by-step first-aid while waiting for help.
/// Pure UI widget — no backend changes.
class AiWaitingInstructionCard extends StatelessWidget {
  final String? emergencyType;

  const AiWaitingInstructionCard({super.key, this.emergencyType});

  List<_Instruction> _instructions() {
    final type = (emergencyType ?? '').toLowerCase();

    if (type.contains('chest') || type.contains('heart')) {
      return const [
        _Instruction(
            icon: Icons.chair_rounded,
            text: 'Sit down and try to stay calm',
            color: Color(0xFF3B82F6)),
        _Instruction(
            icon: Icons.do_not_disturb_on_rounded,
            text: 'Avoid any physical movement',
            color: Color(0xFFF59E0B)),
        _Instruction(
            icon: Icons.medication_rounded,
            text: 'Chew aspirin if not allergic (300mg)',
            color: Color(0xFF10B981)),
        _Instruction(
            icon: Icons.air_rounded,
            text: 'Take slow, deep breaths',
            color: Color(0xFF8B5CF6)),
        _Instruction(
            icon: Icons.lock_open_rounded,
            text: 'Unlock your door for responders',
            color: Color(0xFF0EA5E9)),
      ];
    }

    if (type.contains('fall') || type.contains('injury')) {
      return const [
        _Instruction(
            icon: Icons.do_not_disturb_on_rounded,
            text: 'Do not move your neck or spine',
            color: Color(0xFFEF4444)),
        _Instruction(
            icon: Icons.accessibility_new_rounded,
            text: 'Stay in current position',
            color: Color(0xFFF59E0B)),
        _Instruction(
            icon: Icons.ac_unit_rounded,
            text: 'Apply ice to swelling if available',
            color: Color(0xFF0EA5E9)),
        _Instruction(
            icon: Icons.phone_rounded,
            text: 'Keep phone nearby and stay on call',
            color: Color(0xFF10B981)),
      ];
    }

    if (type.contains('asthma') || type.contains('breath')) {
      return const [
        _Instruction(
            icon: Icons.medication_rounded,
            text: 'Use your inhaler (2 puffs)',
            color: Color(0xFF3B82F6)),
        _Instruction(
            icon: Icons.chair_rounded,
            text: 'Sit upright, lean slightly forward',
            color: Color(0xFF10B981)),
        _Instruction(
            icon: Icons.air_rounded,
            text: 'Breathe slowly: 4s in, 6s out',
            color: Color(0xFF8B5CF6)),
        _Instruction(
            icon: Icons.open_in_new_rounded,
            text: 'Open windows for fresh air',
            color: Color(0xFF0EA5E9)),
      ];
    }

    // Default general emergency
    return const [
      _Instruction(
          icon: Icons.chair_rounded,
          text: 'Stay calm and find a safe position',
          color: Color(0xFF3B82F6)),
      _Instruction(
          icon: Icons.air_rounded,
          text: 'Take slow, deep breaths',
          color: Color(0xFF10B981)),
      _Instruction(
          icon: Icons.lock_open_rounded,
          text: 'Unlock doors for responders',
          color: Color(0xFFF59E0B)),
      _Instruction(
          icon: Icons.phone_rounded,
          text: 'Keep your phone nearby',
          color: Color(0xFF8B5CF6)),
      _Instruction(
          icon: Icons.flashlight_on_rounded,
          text: 'Turn on lights or flashlight',
          color: Color(0xFF0EA5E9)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _instructions();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.12), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 11, color: Color(0xFFA78BFA)),
                    SizedBox(width: 3),
                    Text('While You Wait',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFA78BFA),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Text('AI first-aid guidance',
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.35),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),

          // Steps
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  // Step number
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: step.color)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(step.icon, size: 14, color: step.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(step.text,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Instruction {
  final IconData icon;
  final String text;
  final Color color;

  const _Instruction({
    required this.icon,
    required this.text,
    required this.color,
  });
}
