import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/intake_entry.dart';

/// AI next meal suggestions based on current daily summary.
class AiNextMealSuggestions extends StatelessWidget {
  final DailySummary summary;
  final MealType currentMealType;

  const AiNextMealSuggestions({
    super.key,
    required this.summary,
    required this.currentMealType,
  });

  List<_Suggestion> _buildSuggestions() {
    final suggestions = <_Suggestion>[];
    final s = summary;
    final proteinLeft = s.proteinGoal - s.proteinLogged;
    final carbsLeft = s.carbsGoal - s.carbsLogged;
    final calLeft = s.caloriesRemaining;

    if (proteinLeft > 20) {
      suggestions.add(_Suggestion(
        icon: '💪',
        color: const Color(0xFF10B981),
        text: 'Protein target ${proteinLeft.toInt()}g short — add paneer, eggs or dal at next meal.',
        tag: 'Protein gap',
      ));
    }
    if (calLeft < 200 && calLeft > 0) {
      suggestions.add(const _Suggestion(
        icon: '🥗',
        color: Color(0xFF0EA5E9),
        text: 'Only ~${200}kcal left for the day — choose a light salad or fruits.',
        tag: 'Calorie budget',
      ));
    }
    if (calLeft < 0) {
      suggestions.add(_Suggestion(
        icon: '⚠️',
        color: const Color(0xFFEF4444),
        text: 'Calorie goal exceeded by ${(-calLeft).toInt()}kcal — skip next snack.',
        tag: 'Over budget',
      ));
    }
    if (carbsLeft < 30 && carbsLeft > 0) {
      suggestions.add(const _Suggestion(
        icon: '🥦',
        color: Color(0xFF10B981),
        text: 'Carb quota nearly full — choose low-carb vegetables for next meal.',
        tag: 'Carb limit',
      ));
    }
    if (s.proteinLogged < s.proteinGoal * 0.4 &&
        currentMealType == MealType.dinner) {
      suggestions.add(const _Suggestion(
        icon: '🍗',
        color: Color(0xFF6366F1),
        text: 'Protein intake very low today — include chicken, fish or tofu at dinner.',
        tag: 'Recovery need',
      ));
    }
    if (suggestions.isEmpty) {
      suggestions.add(const _Suggestion(
        icon: '✅',
        color: Color(0xFF10B981),
        text: 'Nutrition is well-balanced today. Stay hydrated and maintain this pattern.',
        tag: 'On track',
      ));
    }
    return suggestions.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggestions = _buildSuggestions();
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  size: 16, color: Color(0xFF6366F1)),
              const SizedBox(width: 7),
              Text('AI Next Meal Suggestions',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SuggestionTile(suggestion: s, isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final _Suggestion suggestion;
  final bool isDark;
  const _SuggestionTile({required this.suggestion, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: suggestion.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: suggestion.color.withValues(alpha: 0.20), width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(suggestion.icon,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: suggestion.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(suggestion.tag,
                      style: TextStyle(
                          fontSize: 9,
                          color: suggestion.color,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.text,
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.white : AppColors.textPrimary,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final String icon;
  final Color color;
  final String text;
  final String tag;
  const _Suggestion({
    required this.icon,
    required this.color,
    required this.text,
    required this.tag,
  });
}
