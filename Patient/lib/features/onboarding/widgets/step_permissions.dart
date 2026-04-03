import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class StepPermissions extends ConsumerWidget {
  const StepPermissions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Almost Done!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enable features to get the most out of MedAssist OS.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 48),

          _buildPermItem(
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            desc: 'Get medication reminders and AI chat responses.',
            value: state.notificationPermission,
            onChanged: (v) => notifier.updatePermissions(notifications: v),
          ),
          const SizedBox(height: 24),

          _buildPermItem(
            icon: Icons.location_on_outlined,
            title: 'Location Services',
            desc: 'Required for SOS GPS coordinates and finding nearby hospitals.',
            value: state.locationPermission,
            onChanged: (v) => notifier.updatePermissions(location: v),
          ),
          const SizedBox(height: 24),

          _buildPermItem(
            icon: Icons.watch_outlined,
            title: 'Health Connect / Wearables',
            desc: 'Sync step count and sleep data automatically.',
            value: state.wearablePermission,
            onChanged: (v) => notifier.updatePermissions(wearable: v),
          ),
          
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your data is encrypted and stored securely. We comply with HIPAA data standards.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: value ? AppColors.primary.withValues(alpha: 0.1) : AppColors.border.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: value ? AppColors.primary : AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}
