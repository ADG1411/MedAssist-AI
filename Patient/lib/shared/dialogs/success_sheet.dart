import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_button.dart';

class SuccessSheet extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDone;

  const SuccessSheet({
    super.key,
    required this.title,
    required this.message,
    required this.onDone,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SuccessSheet(
        title: title,
        message: message,
        onDone: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                 child: const Icon(Icons.check_circle, size: 80, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Done',
                  onPressed: onDone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

