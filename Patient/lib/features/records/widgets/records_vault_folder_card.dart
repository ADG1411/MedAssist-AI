import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Premium vault folder card for each record category.
/// Shows icon, report count, last updated, critical alerts, AI summary preview.
class RecordsVaultFolderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final int abnormalCount;
  final String lastUpdated;
  final String? aiPreview;
  final VoidCallback? onTap;

  const RecordsVaultFolderCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.count = 0,
    this.abnormalCount = 0,
    this.lastUpdated = '',
    this.aiPreview,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        radius: 18,
        blur: 14,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Folder icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: color.withValues(alpha: 0.22), width: 0.7),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary)),
                      ),
                      // Count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (lastUpdated.isNotEmpty) ...[
                        Icon(Icons.schedule_rounded,
                            size: 11, color: textSub),
                        const SizedBox(width: 3),
                        Text(lastUpdated,
                            style:
                                TextStyle(fontSize: 10, color: textSub)),
                        const SizedBox(width: 8),
                      ],
                      if (abnormalCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.25),
                                width: 0.6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 10, color: Color(0xFFEF4444)),
                              const SizedBox(width: 2),
                              Text('$abnormalCount abnormal',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (aiPreview != null && aiPreview!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(aiPreview!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: textSub),
          ],
        ),
      ),
    );
  }
}
