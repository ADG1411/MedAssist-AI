import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// AI Intelligence Preferences — toggles for AI modes, sensitivity,
/// strictness, interaction warnings. Each setting explains how it
/// changes AI behavior. Pure UI widget, no backend changes.
class AiPersonalizationCard extends StatefulWidget {
  const AiPersonalizationCard({super.key});

  @override
  State<AiPersonalizationCard> createState() => _AiPersonalizationCardState();
}

class _AiPersonalizationCardState extends State<AiPersonalizationCard> {
  // Local UI state for toggles — no backend mutation
  bool _deepMode = false;
  bool _doctorStyle = true;
  bool _minimalFollowUp = false;
  bool _highEmergencySensitivity = true;
  bool _strictNutrition = false;
  bool _chronicAwareness = true;
  bool _medInteractionWarnings = true;
  bool _predictiveInsights = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('AI Intelligence',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Text('Personalization Center',
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.40)
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),

          // AI Mode toggle
          _AiModeSelector(
            isDark: isDark,
            isDeep: _deepMode,
            onChanged: (v) => setState(() => _deepMode = v),
          ),
          const SizedBox(height: 8),

          // Setting toggles
          _SettingToggle(
            icon: Icons.medical_services_rounded,
            label: 'Doctor-style questioning',
            subtitle: 'AI asks structured clinical questions',
            color: const Color(0xFF0EA5E9),
            value: _doctorStyle,
            onChanged: (v) => setState(() => _doctorStyle = v),
          ),
          _SettingToggle(
            icon: Icons.speed_rounded,
            label: 'Minimal follow-up mode',
            subtitle: 'Fewer questions, faster results',
            color: const Color(0xFF10B981),
            value: _minimalFollowUp,
            onChanged: (v) => setState(() => _minimalFollowUp = v),
          ),
          _SettingToggle(
            icon: Icons.emergency_rounded,
            label: 'High emergency sensitivity',
            subtitle: 'Lower threshold for SOS alerts',
            color: const Color(0xFFEF4444),
            value: _highEmergencySensitivity,
            onChanged: (v) =>
                setState(() => _highEmergencySensitivity = v),
          ),
          _SettingToggle(
            icon: Icons.restaurant_rounded,
            label: 'Strict nutrition mode',
            subtitle: 'Enforce dietary restrictions in suggestions',
            color: const Color(0xFFF59E0B),
            value: _strictNutrition,
            onChanged: (v) => setState(() => _strictNutrition = v),
          ),
          _SettingToggle(
            icon: Icons.medical_information_rounded,
            label: 'Chronic condition awareness',
            subtitle: 'AI considers ongoing conditions in analysis',
            color: const Color(0xFF8B5CF6),
            value: _chronicAwareness,
            onChanged: (v) => setState(() => _chronicAwareness = v),
          ),
          _SettingToggle(
            icon: Icons.medication_rounded,
            label: 'Medication interaction warnings',
            subtitle: 'Alert on potential drug interactions',
            color: const Color(0xFFF97316),
            value: _medInteractionWarnings,
            onChanged: (v) =>
                setState(() => _medInteractionWarnings = v),
          ),
          _SettingToggle(
            icon: Icons.insights_rounded,
            label: 'Predictive health insights',
            subtitle: 'AI generates proactive health suggestions',
            color: const Color(0xFF14B8A6),
            value: _predictiveInsights,
            onChanged: (v) => setState(() => _predictiveInsights = v),
          ),
        ],
      ),
    );
  }
}

/// AI Mode Selector — Fast vs Deep
class _AiModeSelector extends StatelessWidget {
  final bool isDark;
  final bool isDeep;
  final ValueChanged<bool> onChanged;

  const _AiModeSelector({
    required this.isDark,
    required this.isDeep,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: !isDeep
                      ? const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)])
                      : null,
                  color: isDeep
                      ? Colors.transparent
                      : null,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 18,
                        color: !isDeep
                            ? Colors.white
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.40)
                                : AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('Fast AI',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !isDeep
                                ? Colors.white
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.40)
                                    : AppColors.textSecondary))),
                    Text('Quick responses',
                        style: TextStyle(
                            fontSize: 8,
                            color: !isDeep
                                ? Colors.white.withValues(alpha: 0.70)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : AppColors.textSecondary))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isDeep
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                      : null,
                  color: !isDeep
                      ? Colors.transparent
                      : null,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: [
                    Icon(Icons.psychology_rounded,
                        size: 18,
                        color: isDeep
                            ? Colors.white
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.40)
                                : AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('Deep Diagnostic',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDeep
                                ? Colors.white
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.40)
                                    : AppColors.textSecondary))),
                    Text('Clinical reasoning',
                        style: TextStyle(
                            fontSize: 8,
                            color: isDeep
                                ? Colors.white.withValues(alpha: 0.70)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : AppColors.textSecondary))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 9,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.40)
                            : AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
