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
    final completed = tasks.where((t) => t.done).length;
    final total = tasks.length;
    final progress = total > 0 ? completed / total : 0.0;
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
          padding: const EdgeInsets.all(18),
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
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 5.5,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                          valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF10B981)),
                          strokeCap: StrokeCap.round,
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
                        Text('Daily Missions',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary)),
                        const SizedBox(height: 2),
                        Text('$completed of $total completed today',
                            style:
                                TextStyle(fontSize: 12, color: textSub)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('+${completed * 8} HP',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
          done: hydration >= 8, impact: '+12 recovery'),
      _Task('Log today\'s meals', '🍽️ Nutrition', 7, 'Medium',
          done: false, impact: '+8 score'),
      _Task('Take evening medication', '💊 Medication', 10, 'High',
          done: !hasMedPending, impact: '+15 adherence'),
      _Task('Sleep before 11 PM', '😴 Sleep', 8, 'High',
          done: false, impact: '+8 migraine protection'),
      _Task('10-min breathing exercise', '🧘 Wellness', 5, 'Low',
          done: false, impact: '+5 stress relief'),
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
  const _Task(
    this.label,
    this.category,
    this.impactScore,
    this.urgency, {
    required this.done,
    required this.impact,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Checkbox circle
          Container(
            width: 26,
            height: 26,
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
                    color: textColor,
                    decoration:
                        task.done ? TextDecoration.lineThrough : null,
                    decorationColor: textColor,
                  ),
                ),
                Text(task.category,
                    style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.38)
                            : AppColors.textSecondary)),
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
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(task.impact,
                    style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 3),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: _urgencyColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
