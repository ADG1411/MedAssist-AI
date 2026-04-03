import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SeveritySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const SeveritySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Color _getSliderColor(double val) {
    if (val <= 3) return AppColors.success;
    if (val <= 7) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = _getSliderColor(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mild', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            Text('Severity: ${value.toInt()}', style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Severe', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            thumbColor: activeColor,
            inactiveTrackColor: AppColors.border,
            overlayColor: activeColor.withValues(alpha: 0.2),
            trackHeight: 8.0,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

