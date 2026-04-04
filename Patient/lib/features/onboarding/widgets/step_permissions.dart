import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class StepPermissions extends ConsumerWidget {
  const StepPermissions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Almost Done!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enable features to get the most out of MedAssist OS',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Glass card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.90),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _PermToggle(
                      isDark: isDark,
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      desc: 'Medication reminders & AI chat responses',
                      value: state.notificationPermission,
                      color: const Color(0xFF3B82F6),
                      onChanged: (v) =>
                          notifier.updatePermissions(notifications: v),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE2E8F0)
                                .withValues(alpha: 0.60),
                      ),
                    ),
                    _PermToggle(
                      isDark: isDark,
                      icon: Icons.location_on_outlined,
                      title: 'Location Services',
                      desc: 'SOS GPS coordinates & nearby hospitals',
                      value: state.locationPermission,
                      color: const Color(0xFFEF4444),
                      onChanged: (v) =>
                          notifier.updatePermissions(location: v),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE2E8F0)
                                .withValues(alpha: 0.60),
                      ),
                    ),
                    _PermToggle(
                      isDark: isDark,
                      icon: Icons.watch_outlined,
                      title: 'Health Connect / Wearables',
                      desc: 'Sync step count & sleep data',
                      value: state.wearablePermission,
                      color: const Color(0xFF10B981),
                      onChanged: (v) =>
                          notifier.updatePermissions(wearable: v),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // HIPAA badge
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFF10B981).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981)
                            .withValues(alpha: 0.10),
                      ),
                      child: Icon(Icons.verified_user_rounded,
                          size: 18,
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.70)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HIPAA Compliant',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.70)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your data is encrypted end-to-end and stored securely.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Permission Toggle Row ─────────────────────────────────────────────────

class _PermToggle extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String desc;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _PermToggle({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.desc,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value
                ? color.withValues(alpha: 0.12)
                : isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
          ),
          child: Icon(icon,
              size: 20,
              color: value
                  ? color
                  : isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.80)
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.35)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 28,
          child: FittedBox(
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: color,
              inactiveTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ),
      ],
    );
  }
}
