import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HydrationTracker extends StatelessWidget {
  final int currentCups;
  final int totalCups;
  final VoidCallback onTap;

  const HydrationTracker({
    super.key,
    required this.currentCups,
    this.totalCups = 8,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daily Hydration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              '$currentCups / $totalCups cups',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(totalCups, (index) {
            bool isFilled = index < currentCups;
            return GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: isFilled ? AppColors.softBlue : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFilled ? AppColors.primary : AppColors.border,
                    width: isFilled ? 2 : 1,
                  ),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: isFilled ? AppColors.primary : AppColors.border,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

