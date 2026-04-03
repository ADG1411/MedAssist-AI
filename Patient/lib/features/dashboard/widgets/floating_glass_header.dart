import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/providers/auth_provider.dart';

class FloatingGlassHeader extends ConsumerWidget {
  const FloatingGlassHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider) ?? {};
    final userName = user['name']?.toString().split(' ').first ?? 'Guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final greetEmoji = hour < 12 ? '☀️' : hour < 17 ? '🌤️' : '🌙';

    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return GlassCard(
      radius: 26,
      blur: 22,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Text block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(greetEmoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      '$greeting, $userName',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(dateStr,
                    style: TextStyle(fontSize: 11, color: textSub)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const _PulsingDot(),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '💚 Recovery momentum up 12% today',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Bell button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.4).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF10B981),
          ),
        ),
      );
}
