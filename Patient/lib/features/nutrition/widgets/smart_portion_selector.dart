import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/meal_entity.dart';

/// Indian-friendly smart portion selector with presets + slider.
class SmartPortionSelector extends StatefulWidget {
  final MealEntity meal;
  final double initialAmountG;
  final ValueChanged<double> onChanged;

  const SmartPortionSelector({
    super.key,
    required this.meal,
    required this.initialAmountG,
    required this.onChanged,
  });

  @override
  State<SmartPortionSelector> createState() => _SmartPortionSelectorState();
}

class _SmartPortionSelectorState extends State<SmartPortionSelector> {
  late double _amount;

  // Indian food presets (label, grams)
  static const _indianPresets = <(String, double)>[
    ('1 Roti',    40.0),
    ('1 Bowl Dal', 200.0),
    ('1 Plate Rice', 160.0),
    ('1 Pkt Maggi', 70.0),
    ('1 Glass Milk', 240.0),
    ('1 Cup Tea', 150.0),
    ('½ Plate Rice', 80.0),
    ('2 Roti',    80.0),
  ];

  static const _commonPresets = <(String, double)>[
    ('50g',  50.0),
    ('100g', 100.0),
    ('150g', 150.0),
    ('200g', 200.0),
    ('250g', 250.0),
    ('300g', 300.0),
  ];

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmountG;
  }

  bool get _isLiquid => widget.meal.isLiquid;
  String get _unit => _isLiquid ? 'ml' : 'g';
  double get _max => _isLiquid ? 1000 : 500;

  void _setAmount(double v) {
    setState(() => _amount = v.clamp(1, _max));
    widget.onChanged(_amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.scale_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 7),
              Text('Portion Size',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
              const Spacer(),
              // Amount display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_amount.toInt()} $_unit',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor:
                  isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: _amount.clamp(1, _max),
              min: 1,
              max: _max,
              divisions: (_max / 5).toInt(),
              onChanged: _setAmount,
            ),
          ),

          // Quick gram chips
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _commonPresets.map((preset) {
                final isSelected =
                    (_amount - preset.$2).abs() < 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: GestureDetector(
                    onTap: () => _setAmount(preset.$2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : Colors.black.withValues(alpha: 0.07)),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        preset.$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : textSub,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Indian presets label
          Row(
            children: [
              Text('🇮🇳 Indian Presets',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSub)),
            ],
          ),
          const SizedBox(height: 6),

          // Indian presets grid
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _indianPresets.map((preset) {
              final isSelected = (_amount - preset.$2).abs() < 1;
              return GestureDetector(
                onTap: () => _setAmount(preset.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF97316).withValues(alpha: 0.15)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF97316).withValues(alpha: 0.40)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.09)
                              : Colors.black.withValues(alpha: 0.06)),
                      width: 0.7,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFF97316)
                              : textPrimary,
                        ),
                      ),
                      Text(
                        '${preset.$2.toInt()}g',
                        style: TextStyle(
                            fontSize: 9, color: textSub),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
