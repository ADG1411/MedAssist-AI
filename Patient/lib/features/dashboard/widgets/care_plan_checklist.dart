import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CarePlanItem {
  final String task;
  final IconData icon;
  final bool isAiGenerated;
  bool isDone;

  CarePlanItem({
    required this.task,
    required this.icon,
    this.isAiGenerated = false,
    this.isDone = false,
  });
}

class CarePlanChecklist extends StatefulWidget {
  final List<CarePlanItem>? items;

  const CarePlanChecklist({super.key, this.items});

  @override
  State<CarePlanChecklist> createState() => _CarePlanChecklistState();
}

class _CarePlanChecklistState extends State<CarePlanChecklist> {
  late List<CarePlanItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items ??
        [
          CarePlanItem(task: 'Drink 5 more glasses of water', icon: Icons.water_drop_outlined, isAiGenerated: true),
          CarePlanItem(task: 'Avoid spicy or oily food', icon: Icons.no_food_outlined, isAiGenerated: true),
          CarePlanItem(task: 'Sleep before 11 PM', icon: Icons.bedtime_outlined),
          CarePlanItem(task: 'Doctor consult at 6 PM', icon: Icons.video_call_outlined),
          CarePlanItem(task: 'Take evening medication', icon: Icons.medication_outlined),
        ];
  }

  double get _progress {
    if (_items.isEmpty) return 0;
    return _items.where((e) => e.isDone).length / _items.length;
  }

  int get _doneCount => _items.where((e) => e.isDone).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border;

    final progressColor = _progress >= 0.8
        ? const Color(0xFF10B981)
        : _progress >= 0.5
            ? const Color(0xFFF59E0B)
            : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.checklist_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Care Plan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          '$_doneCount of ${_items.length} tasks done',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, child) => LinearProgressIndicator(
                      value: val,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ..._items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == _items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: () => setState(() => item.isDone = !item.isDone),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: item.isDone
                                ? const Color(0xFF10B981)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: item.isDone
                                  ? const Color(0xFF10B981)
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: item.isDone
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: (item.isDone
                                    ? const Color(0xFF10B981)
                                    : AppColors.primary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.icon,
                            size: 14,
                            color: item.isDone
                                ? const Color(0xFF10B981)
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.task,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: item.isDone
                                  ? textSecondary
                                  : textPrimary,
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: textSecondary,
                            ),
                          ),
                        ),
                        if (item.isAiGenerated)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.auto_awesome,
                                    size: 8, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  'AI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(height: 1, color: borderColor),
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
