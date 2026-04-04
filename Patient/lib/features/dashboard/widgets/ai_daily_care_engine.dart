import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class AiDailyCareEngine extends StatelessWidget {
  final Map<String, dynamic> data;
  const AiDailyCareEngine({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = _buildTasks(data);

    // Auto-regroup: incomplete high→medium→low first, then done
    tasks.sort((a, b) {
      if (a.done != b.done) return a.done ? 1 : -1;
      const order = {'High': 0, 'Medium': 1, 'Low': 2};
      return (order[a.urgency] ?? 2).compareTo(order[b.urgency] ?? 2);
    });

    final completed = tasks.where((t) => t.done).length;
    final total = tasks.length;
    final progress = total > 0 ? completed / total : 0.0;
    final totalXp = tasks.fold<int>(0, (s, t) => s + (t.done ? t.xp : 0));
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashSectionLabel('🎯 Daily Care Engine', 'AI health missions'),
        const SizedBox(height: 10),
        GlassCard(
          radius: 24,
          blur: 20,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              // Mission ring + header
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) =>
                              CircularProgressIndicator(
                            value: val,
                            strokeWidth: 5.5,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF10B981)),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Center(
                          child: Text(
                            '$completed/$total',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Daily Missions',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                    letterSpacing: -0.2)),
                            const SizedBox(width: 6),
                            // Streak badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFF59E0B),
                                  Color(0xFFEF4444)
                                ]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('🔥 3',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('$completed of $total completed',
                                style:
                                    TextStyle(fontSize: 11, color: textSub)),
                            const Spacer(),
                            // "AI updated just now"
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('AI updated just now',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: textSub,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // XP badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.18),
                        const Color(0xFF10B981).withValues(alpha: 0.08),
                      ]),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          width: 0.5),
                    ),
                    child: Text('+$totalXp XP',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...tasks.map((t) => _TaskTile(task: t, isDark: isDark)),
            ],
          ),
        ),
      ],
    );
  }

  List<_Task> _buildTasks(Map<String, dynamic> d) {
    final meds = d['medication_reminders'] as List?;
    final hasMedPending =
        meds?.any((m) => (m as Map)['taken'] == false) ?? false;
    final mon = d['latest_monitoring'] as Map<String, dynamic>?;
    final hydration = (mon?['hydration_cups'] as num?)?.toDouble() ?? 0;

    return [
      _Task('Drink 8 cups of water', '💧 Hydration', 9, 'High',
          done: hydration >= 8, impact: '+12 recovery', xp: 15),
      _Task('Log today\'s meals', '🍽️ Nutrition', 7, 'Medium',
          done: false, impact: '+8 score', xp: 10),
      _Task('Take evening medication', '💊 Medication', 10, 'High',
          done: !hasMedPending, impact: '+15 adherence', xp: 20),
      _Task('Sleep before 11 PM', '😴 Sleep', 8, 'High',
          done: false, impact: '+8 migraine prevention', xp: 18),
      _Task('10-min breathing exercise', '🧘 Wellness', 5, 'Low',
          done: false, impact: '+5 stress relief', xp: 8),
    ];
  }
}

class _Task {
  final String label;
  final String category;
  final int impactScore;
  final String urgency;
  final bool done;
  final String impact;
  final int xp;
  const _Task(
    this.label,
    this.category,
    this.impactScore,
    this.urgency, {
    required this.done,
    required this.impact,
    required this.xp,
  });
}

class _TaskTile extends StatelessWidget {
  final _Task task;
  final bool isDark;
  const _TaskTile({required this.task, required this.isDark});

  Color get _urgencyColor {
    switch (task.urgency) {
      case 'High':   return const Color(0xFFEF4444);
      case 'Medium': return const Color(0xFFF59E0B);
      default:       return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = task.done
        ? (isDark
            ? Colors.white.withValues(alpha: 0.38)
            : AppColors.textSecondary)
        : (isDark ? Colors.white : AppColors.textPrimary);

    return AnimatedOpacity(
      opacity: task.done ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Animated checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.done
                    ? const Color(0xFF10B981).withValues(alpha: 0.14)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04)),
                border: Border.all(
                  color: task.done
                      ? const Color(0xFF10B981)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.14)
                          : Colors.black.withValues(alpha: 0.12)),
                  width: 1.5,
                ),
                boxShadow: task.done
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: task.done
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Color(0xFF10B981))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: textColor,
                      decoration:
                          task.done ? TextDecoration.lineThrough : null,
                      decorationColor: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(task.category,
                          style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.38)
                                  : AppColors.textSecondary)),
                      const SizedBox(width: 6),
                      // XP chip inline
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('+${task.xp} XP',
                            style: const TextStyle(
                                fontSize: 8.5,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: _urgencyColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(task.impact,
                      style: TextStyle(
                          fontSize: 9,
                          color: _urgencyColor,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _urgencyColor),
                    ),
                    const SizedBox(width: 3),
                    Text(task.urgency,
                        style: TextStyle(
                            fontSize: 8,
                            color: _urgencyColor,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
