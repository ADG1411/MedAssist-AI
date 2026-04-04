import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Care & Lifestyle Preferences — diet, triggers, language, doctor
/// preferences, consultation mode, sleep/hydration goals.
/// Improves AI recommendations. Pure UI widget.
class CarePreferencesCard extends StatelessWidget {
  const CarePreferencesCard({super.key});

  static const _preferences = [
    _Pref(
        icon: Icons.restaurant_rounded,
        label: 'Diet Preference',
        value: 'Not set',
        color: Color(0xFF10B981)),
    _Pref(
        icon: Icons.no_food_rounded,
        label: 'Dietary Restrictions',
        value: 'Not set',
        color: Color(0xFFF59E0B)),
    _Pref(
        icon: Icons.bolt_rounded,
        label: 'Known Triggers',
        value: 'Not set',
        color: Color(0xFFEF4444)),
    _Pref(
        icon: Icons.translate_rounded,
        label: 'Consultation Language',
        value: 'English',
        color: Color(0xFF3B82F6)),
    _Pref(
        icon: Icons.person_search_rounded,
        label: 'Preferred Doctor Gender',
        value: 'No preference',
        color: Color(0xFF8B5CF6)),
    _Pref(
        icon: Icons.video_call_rounded,
        label: 'Consultation Mode',
        value: 'Video + In-person',
        color: Color(0xFF0EA5E9)),
    _Pref(
        icon: Icons.bedtime_rounded,
        label: 'Sleep Goal',
        value: '8 hours',
        color: Color(0xFF6366F1)),
    _Pref(
        icon: Icons.water_drop_rounded,
        label: 'Hydration Goal',
        value: '3L / day',
        color: Color(0xFF14B8A6)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.40)
        : AppColors.textSecondary;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                      width: 0.6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded,
                        size: 12, color: Color(0xFFF59E0B)),
                    SizedBox(width: 4),
                    Text('Care Preferences',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Text('Improves AI accuracy',
                  style: TextStyle(
                      fontSize: 9,
                      color: textSub,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),

          ..._preferences.map((pref) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: pref.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child:
                          Icon(pref.icon, size: 14, color: pref.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(pref.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: pref.value == 'Not set'
                            ? (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04))
                            : pref.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                            color: pref.value == 'Not set'
                                ? (isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : Colors.black.withValues(alpha: 0.06))
                                : pref.color.withValues(alpha: 0.20),
                            width: 0.6),
                      ),
                      child: Text(pref.value,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: pref.value == 'Not set'
                                  ? textSub
                                  : pref.color)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Pref {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Pref({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
