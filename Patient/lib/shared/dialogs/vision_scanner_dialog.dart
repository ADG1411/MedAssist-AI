import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VisionScannerDialog extends StatelessWidget {
  const VisionScannerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => const VisionScannerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom scanning animation
              Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                     width: 100,
                     height: 100,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 8),
                     ),
                   ),
                   const CircularProgressIndicator(
                     color: AppColors.primary,
                     strokeWidth: 4,
                   ),
                   const Icon(Icons.document_scanner, size: 40, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Analyzing Food Vision...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Extracting macronutrients, sodium levels, and tracking GERD risk bounds against your history.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

