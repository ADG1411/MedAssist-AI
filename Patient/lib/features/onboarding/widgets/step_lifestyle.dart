import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class StepLifestyle extends ConsumerWidget {
  const StepLifestyle({super.key});

  static const _smoking = ['Never', 'Occasional', 'Frequent'];
  static const _alcohol = ['None', 'Occasional', 'Frequent'];
  static const _stress = ['Low', 'Moderate', 'High'];
  static const _activity = ['Sedentary', 'Moderate', 'Active'];
  static const _diet = ['Regular', 'Vegetarian', 'Vegan', 'Keto', 'Other'];

  static const _icons = <String, IconData>{
    'Smoking Status': Icons.smoking_rooms_outlined,
    'Alcohol Consumption': Icons.local_bar_outlined,
    'Stress Level': Icons.psychology_outlined,
    'Activity Level': Icons.directions_run_rounded,
    'Diet Type': Icons.restaurant_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lifestyle',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lifestyle context improves AI medical accuracy',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Glass card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.90),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChoiceRow(
                      isDark: isDark,
                      title: 'Smoking Status',
                      icon: _icons['Smoking Status']!,
                      options: _smoking,
                      current: state.smokingStatus,
                      onSelect: (v) =>
                          notifier.updateLifestyle(smokingStatus: v),
                    ),
                    const SizedBox(height: 18),

                    _ChoiceRow(
                      isDark: isDark,
                      title: 'Alcohol Consumption',
                      icon: _icons['Alcohol Consumption']!,
                      options: _alcohol,
                      current: state.alcoholFrequency,
                      onSelect: (v) =>
                          notifier.updateLifestyle(alcoholFrequency: v),
                    ),
                    const SizedBox(height: 18),

                    // Sleep slider
                    _SleepSlider(
                      isDark: isDark,
                      value: state.sleepHoursAvg,
                      onChanged: (v) =>
                          notifier.updateLifestyle(sleepHoursAvg: v),
                    ),
                    const SizedBox(height: 18),

                    _ChoiceRow(
                      isDark: isDark,
                      title: 'Stress Level',
                      icon: _icons['Stress Level']!,
                      options: _stress,
                      current: state.stressLevel,
                      onSelect: (v) =>
                          notifier.updateLifestyle(stressLevel: v),
                    ),
                    const SizedBox(height: 18),

                    _ChoiceRow(
                      isDark: isDark,
                      title: 'Activity Level',
                      icon: _icons['Activity Level']!,
                      options: _activity,
                      current: state.activityLevel,
                      onSelect: (v) =>
                          notifier.updateLifestyle(activityLevel: v),
                    ),
                    const SizedBox(height: 18),

                    _ChoiceRow(
                      isDark: isDark,
                      title: 'Diet Type',
                      icon: _icons['Diet Type']!,
                      options: _diet,
                      current: state.dietType,
                      onSelect: (v) =>
                          notifier.updateLifestyle(dietType: v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Choice Row ────────────────────────────────────────────────────────────

class _ChoiceRow extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final List<String> options;
  final String current;
  final Function(String) onSelect;

  const _ChoiceRow({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.40)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final sel = current == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF3B82F6)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.40)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                    width: 0.6,
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.20),
                            blurRadius: 6,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel
                        ? Colors.white
                        : isDark
                            ? Colors.white.withValues(alpha: 0.50)
                            : const Color(0xFF475569),
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

// ── Sleep Slider ──────────────────────────────────────────────────────────

class _SleepSlider extends StatelessWidget {
  final bool isDark;
  final double value;
  final ValueChanged<double> onChanged;

  const _SleepSlider({
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bedtime_outlined,
                size: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              'Average Sleep',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.40)
                    : const Color(0xFF475569),
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${value.toStringAsFixed(1)} hrs',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF3B82F6),
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF3B82F6).withValues(alpha: 0.10),
            trackHeight: 4,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: 2,
            max: 12,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
