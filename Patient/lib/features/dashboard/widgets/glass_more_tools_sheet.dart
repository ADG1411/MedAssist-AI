import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class GlassMoreToolsSheet extends StatelessWidget {
  final bool isDark;
  const GlassMoreToolsSheet({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const tools = [
      _Tool('Health QR', Icons.qr_code_rounded, Color(0xFF10B981), '/medassist-card'),
      _Tool('Recovery\nReport', Icons.bar_chart_rounded, Color(0xFF6366F1), '/recovery-report'),
      _Tool('Hospitals', Icons.local_hospital_rounded, Color(0xFFEF4444), '/hospitals'),
      _Tool('Pharmacy', Icons.local_pharmacy_rounded, Color(0xFF06B6D4), '/pharmacy'),
      _Tool('Daily\nFollow-up', Icons.checklist_rounded, Color(0xFFF59E0B), '/daily-followup'),
      _Tool('Body Map', Icons.accessibility_new_rounded, Color(0xFF8B5CF6), '/body-map'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.22), blurRadius: 40)
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.82),
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 32 + MediaQuery.paddingOf(context).bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('More Tools',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Extended health toolkit',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : AppColors.textSecondary)),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: tools
                      .map((t) => _ToolTile(tool: t, isDark: isDark))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tool {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _Tool(this.label, this.icon, this.color, this.route);
}

class _ToolTile extends StatelessWidget {
  final _Tool tool;
  final bool isDark;
  const _ToolTile({required this.tool, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        context.push(tool.route);
      },
      child: GlassCard(
        radius: 16,
        blur: 14,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: tool.color.withValues(alpha: 0.14),
              ),
              child: Icon(tool.icon, size: 20, color: tool.color),
            ),
            const SizedBox(height: 7),
            Text(
              tool.label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
