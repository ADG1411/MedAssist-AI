import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/intake_entry.dart';

class MealTimelineCard extends StatelessWidget {
  final MealType mealType;
  final List<IntakeEntry> entries;
  final VoidCallback? onAddFood;
  final VoidCallback? onDeleteEntry;

  const MealTimelineCard({
    super.key,
    required this.mealType,
    required this.entries,
    this.onAddFood,
    this.onDeleteEntry,
  });

  double get _totalKcal =>
      entries.fold(0, (sum, e) => sum + e.totalKcal);
  double get _totalCarbs =>
      entries.fold(0, (sum, e) => sum + e.totalCarbsG);
  double get _totalFat =>
      entries.fold(0, (sum, e) => sum + e.totalFatG);
  double get _totalProtein =>
      entries.fold(0, (sum, e) => sum + e.totalProteinG);

  String _mealQualityLabel() {
    if (entries.isEmpty) return 'Empty';
    final kcal = _totalKcal;
    final protein = _totalProtein;
    if (protein > 20 && kcal < 600) return 'Excellent';
    if (kcal > 900) return 'High Cal';
    if (protein < 5) return 'Low Protein';
    return 'Good';
  }

  Color _mealQualityColor() {
    final label = _mealQualityLabel();
    switch (label) {
      case 'Excellent': return const Color(0xFF10B981);
      case 'High Cal':  return const Color(0xFFEF4444);
      case 'Low Protein': return const Color(0xFFF59E0B);
      default:          return AppColors.primary;
    }
  }

  String _recoveryImpact() {
    if (entries.isEmpty) return '';
    final protein = _totalProtein;
    if (protein > 20) return '+muscle recovery';
    if (_totalFat > 25) return '-digestion stress';
    if (_totalKcal < 200) return '+light on gut';
    return '+energy balance';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = mealType.color;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;
    final qualityColor = _mealQualityColor();
    final recoveryText = _recoveryImpact();

    return GlassCard(
      radius: 20,
      blur: 16,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.18),
                    border: Border.all(
                        color: color.withValues(alpha: 0.35), width: 1.2),
                  ),
                  child: Center(
                    child: Text(mealType.emoji,
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mealType.label,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary)),
                      Text(mealType.timeRange,
                          style:
                              TextStyle(fontSize: 10, color: textSub)),
                    ],
                  ),
                ),
                // Total kcal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_totalKcal.toInt()} kcal',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color),
                    ),
                    Row(
                      children: [
                        // Quality badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                qualityColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _mealQualityLabel(),
                            style: TextStyle(
                                fontSize: 9,
                                color: qualityColor,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Food entries ──────────────────────────────────────────────
          if (entries.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 16, color: textSub),
                  const SizedBox(width: 8),
                  Text('No food logged yet',
                      style: TextStyle(fontSize: 12, color: textSub)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Column(
                children: entries.map((e) => _FoodRow(entry: e, isDark: isDark)).toList(),
              ),
            ),

          // ── Macro summary strip ───────────────────────────────────────
          if (entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: Row(
                children: [
                  _MacroChip('C', '${_totalCarbs.toInt()}g',
                      const Color(0xFFF59E0B), isDark),
                  const SizedBox(width: 6),
                  _MacroChip('F', '${_totalFat.toInt()}g',
                      const Color(0xFFEF4444), isDark),
                  const SizedBox(width: 6),
                  _MacroChip('P', '${_totalProtein.toInt()}g',
                      const Color(0xFF10B981), isDark),
                  const Spacer(),
                  // Recovery impact
                  if (recoveryText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: recoveryText.startsWith('+')
                            ? const Color(0xFF10B981).withValues(alpha: 0.10)
                            : const Color(0xFFEF4444).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recoveryText,
                        style: TextStyle(
                            fontSize: 10,
                            color: recoveryText.startsWith('+')
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),

          // ── Quick add ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: GestureDetector(
              onTap: onAddFood,
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: color.withValues(alpha: 0.20), width: 0.7),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: color),
                    const SizedBox(width: 5),
                    Text('Add food to ${mealType.label}',
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600)),
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

class _FoodRow extends StatelessWidget {
  final IntakeEntry entry;
  final bool isDark;
  const _FoodRow({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.textSecondary;
    final name = entry.meal.name ?? 'Unknown food';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'F';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Thumbnail / initial
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: entry.mealType.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: entry.meal.thumbnailImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      entry.meal.thumbnailImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(initial,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: entry.mealType.color)),
                      ),
                    ),
                  )
                : Center(
                    child: Text(initial,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: entry.mealType.color)),
                  ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    '${entry.amountG.toInt()}${entry.unit} · ${entry.totalProteinG.toInt()}g P',
                    style: TextStyle(fontSize: 10, color: textSub)),
              ],
            ),
          ),
          Text(
            '${entry.totalKcal.toInt()} kcal',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _MacroChip(this.label, this.value, this.color, this.isDark);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('$label $value',
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600)),
      );
}
