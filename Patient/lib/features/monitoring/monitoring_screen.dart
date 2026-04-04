// Daily Check-in Screen — premium redesign.
// Preserves all provider logic. Adds visual improvements:
// real day-of-week stepper, glassmorphism cards, animated progress,
// premium mood picker with gradients, and a live recovery preview bar.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/dialogs/success_sheet.dart';
import 'providers/monitoring_provider.dart';
import 'providers/recovery_provider.dart';

class MonitoringScreen extends ConsumerWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(monitoringProvider);
    final notifier = ref.read(monitoringProvider.notifier);

    // Estimated recovery from current inputs
    final computedScore = _estimateScore(
      severity: state.symptomSeverity,
      hydration: state.hydrationCups,
      sleep: state.sleepHours,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                // ── App Bar ───────────────────────────────────────────
                _AppBar(isDark: isDark),

                // ── Day stepper ───────────────────────────────────────
                _DayStepper(isDark: isDark),

                // ── Live Recovery Preview ─────────────────────────────
                _RecoveryPreview(score: computedScore, isDark: isDark),

                // ── Scrollable content ────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      children: [
                        // Symptom
                        _SectionCard(
                          isDark: isDark,
                          icon: Icons.monitor_heart_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Symptom Severity',
                          subtitle: 'How intense are your symptoms today?',
                          child: _SeveritySection(
                            value: state.symptomSeverity,
                            onChanged: notifier.updateSeverity,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Hydration
                        _SectionCard(
                          isDark: isDark,
                          icon: Icons.water_drop_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                          title: 'Daily Hydration',
                          subtitle: 'Track your water intake',
                          child: _HydrationSection(
                            currentCups: state.hydrationCups,
                            onTap: notifier.incrementHydration,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Sleep
                        _SectionCard(
                          isDark: isDark,
                          icon: Icons.nightlight_round,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Sleep Duration',
                          subtitle: 'How many hours did you sleep?',
                          child: _SleepSection(
                            value: state.sleepHours,
                            onChanged: notifier.updateSleep,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mood
                        _SectionCard(
                          isDark: isDark,
                          icon: Icons.sentiment_satisfied_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'How do you feel?',
                          subtitle: 'Your overall mood today',
                          child: _MoodSection(
                            selected: state.mood,
                            onSelect: notifier.updateMood,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Save FAB ───────────────────────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: _SaveButton(
              isSaving: state.isSaving,
              onTap: () async {
                HapticFeedback.mediumImpact();
                final success = await notifier.saveDailyCheckin();
                if (context.mounted && success) {
                  // Force recovery report to reload with new data
                  ref.invalidate(recoveryProvider);
                  SuccessSheet.show(
                    context: context,
                    title: 'Check-in Saved',
                    message:
                        'Your daily health data has been vaulted securely.',
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Rough preview score so user sees real-time feedback.
  int _estimateScore({
    required double severity,
    required int hydration,
    required double sleep,
  }) {
    final pain = ((10 - severity) / 10.0).clamp(0.0, 1.0) * 40;
    final hyd = (hydration / 8.0).clamp(0.0, 1.0) * 30;
    double slp;
    if (sleep >= 7 && sleep <= 9) {
      slp = 30;
    } else if (sleep >= 5) {
      slp = (sleep - 5) / 2.0 * 20;
    } else {
      slp = 5;
    }
    return (pain + hyd + slp).clamp(0, 100).toInt();
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final bool isDark;
  const _AppBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.09)
                    : Colors.white.withValues(alpha: 0.80),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.border,
                  width: 0.5,
                ),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: isDark
                      ? Colors.white
                      : AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Check-in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    )),
                Text(
                  _todayString(),
                  style: TextStyle(fontSize: 11, color: textSub),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/recovery-report'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 0.7),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  const Text('Report',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// ── Day Stepper ───────────────────────────────────────────────────────────────

class _DayStepper extends StatelessWidget {
  final bool isDark;
  const _DayStepper({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Show the last 7 days, today last
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return d;
    });

    const short = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: List.generate(7, (i) {
          final isToday = i == 6;
          final isPast = i < 6;
          final d = days[i];
          final dayLetter = short[(d.weekday - 1) % 7];

          return Expanded(
            child: Column(
              children: [
                Text(
                  dayLetter,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isToday
                        ? AppColors.primary
                        : isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isToday
                        ? const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isToday
                        ? null
                        : isPast
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.04),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isToday
                        ? Text('${d.day}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ))
                        : isPast
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Color(0xFF10B981))
                            : Text('${d.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.30)
                                      : AppColors.textSecondary,
                                )),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Recovery Preview Bar ─────────────────────────────────────────────────────

class _RecoveryPreview extends StatelessWidget {
  final int score;
  final bool isDark;
  const _RecoveryPreview({required this.score, required this.isDark});

  Color get _color {
    if (score >= 70) return const Color(0xFF10B981);
    if (score >= 45) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _color.withValues(alpha: isDark ? 0.25 : 0.18),
            width: 0.7),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated Recovery Score',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.60)
                            : AppColors.textSecondary)),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: val,
                      minHeight: 5,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation(_color),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            score >= 70
                ? 'Great 🌟'
                : score >= 45
                    ? 'OK 👌'
                    : 'Low ⚠️',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: _color),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          width: 0.6,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -0.2)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.40)
                              : AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Severity Section ──────────────────────────────────────────────────────────

class _SeveritySection extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final bool isDark;
  const _SeveritySection(
      {required this.value, required this.onChanged, required this.isDark});

  Color get _color {
    if (value <= 3) return const Color(0xFF10B981);
    if (value <= 6) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _label {
    if (value <= 2) return 'Minimal';
    if (value <= 4) return 'Mild';
    if (value <= 6) return 'Moderate';
    if (value <= 8) return 'Severe';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mild',
                style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_label  ${value.toInt()}/10',
                style: TextStyle(
                    fontSize: 12,
                    color: _color,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Text('Severe',
                style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbColor: _color,
            activeTrackColor: _color,
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
            overlayColor: _color.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: onChanged,
          ),
        ),
        // Visual scale dots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(11, (i) {
            final isActive = i <= value.toInt();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? _color
                    : isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.10),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Hydration Section ─────────────────────────────────────────────────────────

class _HydrationSection extends StatelessWidget {
  final int currentCups;
  final VoidCallback onTap;
  final bool isDark;
  const _HydrationSection(
      {required this.currentCups, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress',
                style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.textSecondary)),
            Text('$currentCups / 8 cups',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0EA5E9))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(8, (i) {
            final filled = i < currentCups;
            return Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 48,
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0xFF0EA5E9).withValues(alpha: 0.15)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: filled
                          ? const Color(0xFF0EA5E9).withValues(alpha: 0.50)
                          : isDark
                              ? Colors.white.withValues(alpha: 0.09)
                              : Colors.black.withValues(alpha: 0.07),
                      width: filled ? 1.2 : 0.6,
                    ),
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 20,
                    color: filled
                        ? const Color(0xFF0EA5E9)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.14),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // Quick-add row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Tap a cup to add',
                style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.28)
                        : AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

// ── Sleep Section ─────────────────────────────────────────────────────────────

class _SleepSection extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final bool isDark;
  const _SleepSection(
      {required this.value, required this.onChanged, required this.isDark});

  String get _quality {
    if (value >= 8) return 'Excellent 💤';
    if (value >= 7) return 'Good 😴';
    if (value >= 5) return 'Fair 😐';
    return 'Poor 😔';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Duration',
                style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.textSecondary)),
            Row(
              children: [
                Text(value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8B5CF6),
                      letterSpacing: -1,
                    )),
                Text(' h',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : AppColors.textSecondary)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_quality,
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFF8B5CF6),
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
            overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: 4,
            max: 12,
            divisions: 16,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('4h', style: TextStyle(fontSize: 10, color: isDark ? Colors.white.withValues(alpha: 0.30) : AppColors.textSecondary)),
            Text('Optimal: 7–9h',
                style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.80),
                    fontWeight: FontWeight.w500)),
            Text('12h', style: TextStyle(fontSize: 10, color: isDark ? Colors.white.withValues(alpha: 0.30) : AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

// ── Mood Section ──────────────────────────────────────────────────────────────

class _MoodSection extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _MoodSection({required this.selected, required this.onSelect});

  static const _moods = [
    ('Terrible', '😣', Color(0xFFEF4444)),
    ('Bad', '😟', Color(0xFFF97316)),
    ('Neutral', '😐', Color(0xFFF59E0B)),
    ('Good', '😊', Color(0xFF10B981)),
    ('Excellent', '🤩', Color(0xFF6366F1)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: _moods.map((m) {
        final label = m.$1;
        final emoji = m.$2;
        final color = m.$3;
        final isSelected = selected == label;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(label);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.50)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                  width: isSelected ? 1.5 : 0.6,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.20),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(emoji, style: TextStyle(fontSize: isSelected ? 24 : 20)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? color
                          : isDark
                              ? Colors.white.withValues(alpha: 0.40)
                              : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Save Button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onTap;
  const _SaveButton({required this.isSaving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSaving
                ? [const Color(0xFF6B7280), const Color(0xFF4B5563)]
                : [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: isSaving ? 0.0 : 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_alt_rounded,
                        size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Check-in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
