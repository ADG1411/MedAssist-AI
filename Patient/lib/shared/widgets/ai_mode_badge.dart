import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AiMode { fast, deep }

class AiModeBadge extends StatelessWidget {
  final AiMode mode;
  
  const AiModeBadge({super.key, this.mode = AiMode.fast});

  @override
  Widget build(BuildContext context) {
    bool isFast = mode == AiMode.fast;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isFast ? AppColors.softBlue : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFast ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFast ? Icons.bolt : Icons.psychology,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            isFast ? 'MED AI' : 'DEEP CHECK',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

