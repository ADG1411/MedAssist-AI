import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Premium doctor share bottom sheet — share single record, bundle,
/// 30-day timeline, AI summary only, or emergency card.
/// Uses existing navigation. Pure UI widget.
class DoctorShareSheet extends StatelessWidget {
  final Map<String, dynamic>? record;
  final List<Map<String, dynamic>> allRecords;
  final VoidCallback? onShareSingle;
  final VoidCallback? onShareBundle;
  final VoidCallback? onShareTimeline;
  final VoidCallback? onShareAiSummary;
  final VoidCallback? onShareEmergencyCard;

  const DoctorShareSheet({
    super.key,
    this.record,
    this.allRecords = const [],
    this.onShareSingle,
    this.onShareBundle,
    this.onShareTimeline,
    this.onShareAiSummary,
    this.onShareEmergencyCard,
  });

  static Future<void> show(BuildContext context, {
    Map<String, dynamic>? record,
    List<Map<String, dynamic>> allRecords = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DoctorShareSheet(
        record: record,
        allRecords: allRecords,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.60)
              : Colors.white.withValues(alpha: 0.85),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.20)
                      : Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.share_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Share with Doctor',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary)),
                      Text('Secure expiring link',
                          style: TextStyle(fontSize: 11, color: textSub)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Share options
              if (record != null)
                _ShareOption(
                  icon: Icons.description_rounded,
                  label: 'Share This Record',
                  subtitle: record!['title']?.toString() ?? 'Record',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    onShareSingle?.call();
                  },
                ),
              _ShareOption(
                icon: Icons.folder_rounded,
                label: 'Share Report Bundle',
                subtitle: '${allRecords.length} records',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  onShareBundle?.call();
                },
              ),
              _ShareOption(
                icon: Icons.timeline_rounded,
                label: 'Share 30-Day Timeline',
                subtitle: 'Recent health activity',
                color: const Color(0xFF10B981),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  onShareTimeline?.call();
                },
              ),
              _ShareOption(
                icon: Icons.auto_awesome,
                label: 'Share AI Summary Only',
                subtitle: 'AI-generated health overview',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  onShareAiSummary?.call();
                },
              ),
              _ShareOption(
                icon: Icons.emergency_rounded,
                label: 'Share Emergency Card',
                subtitle: 'Critical medical info',
                color: const Color(0xFFEF4444),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  onShareEmergencyCard?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color.withValues(alpha: 0.18), width: 0.7),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}
