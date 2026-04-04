import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import 'glass_more_tools_sheet.dart';

class ActionMatrixGrid extends StatelessWidget {
  const ActionMatrixGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const acts = [
      _Action('Symptom AI', Icons.psychology_rounded, Color(0xFF6366F1),
          '/symptom-check', 'Body map check', true),
      _Action('Doctors', Icons.medical_services_rounded, Color(0xFF10B981),
          '/doctors', 'Find & consult', false),
      _Action('Nutrition', Icons.restaurant_rounded, Color(0xFFF59E0B),
          '/nutrition', 'Food diary', false),
      _Action('Records', Icons.folder_special_rounded, Color(0xFF06B6D4),
          '/records', 'AI health vault', false),
      _Action('Vitals', Icons.monitor_heart_rounded, Color(0xFFEF4444),
          '/monitoring', 'Track health', false),
      _Action('Emergency', Icons.emergency_rounded, Color(0xFFDC2626),
          '/sos', 'SOS & ICE info', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashSectionLabel('⚡ Smart Actions', 'AI-curated health tools'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.88,
          children: acts
              .map((a) => _ActionPod(action: a, isDark: isDark))
              .toList(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => GlassMoreToolsSheet(isDark: isDark),
            );
          },
          child: GlassCard(
            radius: 16,
            blur: 16,
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('More Tools',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_up_rounded,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  final String sub;
  final bool aiSuggested;
  const _Action(
      this.label, this.icon, this.color, this.route, this.sub, this.aiSuggested);
}

class _ActionPod extends StatefulWidget {
  final _Action action;
  final bool isDark;
  const _ActionPod({required this.action, required this.isDark});

  @override
  State<_ActionPod> createState() => _ActionPodState();
}

class _ActionPodState extends State<_ActionPod> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(a.route);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          radius: 18,
          blur: 16,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: a.color.withValues(alpha: 0.14),
                    ),
                    child: Icon(a.icon, size: 18, color: a.color),
                  ),
                  if (a.aiSuggested) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6)
                        ]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 7, color: Colors.white),
                          SizedBox(width: 2),
                          Text('AI',
                              style: TextStyle(
                                  fontSize: 7.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(a.label,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: widget.isDark
                          ? Colors.white
                          : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(a.sub,
                  style: TextStyle(
                      fontSize: 9.5,
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.48)
                          : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
