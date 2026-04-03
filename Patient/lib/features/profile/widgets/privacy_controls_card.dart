import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Medical Privacy Controls — toggles for sharing, QR mode, AI memory,
/// report defaults, wearable consent, analytics, delete memory.
/// Pure UI widget — no backend changes.
class PrivacyControlsCard extends StatefulWidget {
  const PrivacyControlsCard({super.key});

  @override
  State<PrivacyControlsCard> createState() => _PrivacyControlsCardState();
}

class _PrivacyControlsCardState extends State<PrivacyControlsCard> {
  bool _autoShareDoctor = false;
  bool _qrLimitedMode = true;
  bool _aiMemoryLearning = true;
  bool _reportSharingDefault = false;
  bool _wearableConsent = false;
  bool _analyticsConsent = true;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.22),
                      width: 0.6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded,
                        size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text('Privacy Controls',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _PrivacyToggle(
            icon: Icons.share_rounded,
            label: 'Auto-share with doctor',
            subtitle: 'Reports shared on doctor assignment',
            color: const Color(0xFF3B82F6),
            value: _autoShareDoctor,
            onChanged: (v) => setState(() => _autoShareDoctor = v),
          ),
          _PrivacyToggle(
            icon: Icons.qr_code_rounded,
            label: 'QR emergency limited mode',
            subtitle: 'Only critical data visible on scan',
            color: const Color(0xFFEF4444),
            value: _qrLimitedMode,
            onChanged: (v) => setState(() => _qrLimitedMode = v),
          ),
          _PrivacyToggle(
            icon: Icons.psychology_rounded,
            label: 'AI memory learning',
            subtitle: 'Allow AI to learn from your history',
            color: const Color(0xFF6366F1),
            value: _aiMemoryLearning,
            onChanged: (v) => setState(() => _aiMemoryLearning = v),
          ),
          _PrivacyToggle(
            icon: Icons.description_rounded,
            label: 'Report sharing defaults',
            subtitle: 'New reports auto-shared with assigned doctors',
            color: const Color(0xFF0EA5E9),
            value: _reportSharingDefault,
            onChanged: (v) => setState(() => _reportSharingDefault = v),
          ),
          _PrivacyToggle(
            icon: Icons.watch_rounded,
            label: 'Wearable data sync consent',
            subtitle: 'Allow health device data collection',
            color: const Color(0xFF8B5CF6),
            value: _wearableConsent,
            onChanged: (v) => setState(() => _wearableConsent = v),
          ),
          _PrivacyToggle(
            icon: Icons.analytics_rounded,
            label: 'Analytics consent',
            subtitle: 'Help improve AI with anonymized data',
            color: const Color(0xFF14B8A6),
            value: _analyticsConsent,
            onChanged: (v) => setState(() => _analyticsConsent = v),
          ),

          const SizedBox(height: 6),
          // Delete health memory
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Health memory deletion requires confirmation via settings.')),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                    width: 0.6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_forever_rounded,
                      size: 14, color: Color(0xFFEF4444)),
                  const SizedBox(width: 5),
                  const Text('Delete Health Memory',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 9,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.40)
                            : AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
