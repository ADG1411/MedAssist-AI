import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../core/theme/app_colors.dart';

class ScaffoldWithBottomNav extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNav({
    super.key,
    required this.child,
  });

  @override
  State<ScaffoldWithBottomNav> createState() => _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/doctors')) return 1;
    if (location.startsWith('/nutrition')) return 2;
    if (location.startsWith('/records')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/doctors');
        break;
      case 2:
        context.go('/nutrition');
        break;
      case 3:
        context.go('/records');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: widget.child,
      bottomNavigationBar: _LiquidGlassNavBar(
        selectedIndex: selectedIndex,
        onTap: (i) => _onItemTapped(i, context),
        isDark: isDark,
      ),
      floatingActionButton: _SosFab(pulseAnim: _pulseAnim),
    );
  }
}

// ── Liquid Glass Nav Bar ─────────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.icon, this.activeIcon, this.label);
}

const _navItems = [
  _NavItemData(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _NavItemData(Icons.medical_services_outlined, Icons.medical_services_rounded, 'Doctors'),
  _NavItemData(Icons.restaurant_menu_outlined, Icons.restaurant_menu_rounded, 'Nutrition'),
  _NavItemData(Icons.folder_outlined, Icons.folder_rounded, 'Records'),
  _NavItemData(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

class _LiquidGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _LiquidGlassNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final extraBottom = bottomPad == 0 ? 14.0 : bottomPad;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, extraBottom),
      child: LiquidGlass.withOwnLayer(
        fake: true,
        settings: LiquidGlassSettings(
          blur: 26,
          thickness: 34,
          lightIntensity: 0.30,
          glassColor: isDark
              ? const Color.fromARGB(40, 255, 255, 255)
              : const Color.fromARGB(75, 255, 255, 255),
        ),
        shape: const LiquidRoundedSuperellipse(borderRadius: 32),
        glassContainsChild: true,
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(32),
            color: isDark
                ? const Color.fromARGB(52, 5, 14, 26)
                : const Color.fromARGB(58, 255, 255, 255),
          ),
          child: Row(
            children: [
              for (int i = 0; i < _navItems.length; i++)
                _NavItem(
                  data: _navItems[i],
                  isSelected: selectedIndex == i,
                  isDark: isDark,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single Nav Item ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = AppColors.primary;
    final inactive = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? active.withValues(alpha: isDark ? 0.22 : 0.13)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                isSelected ? data.activeIcon : data.icon,
                color: isSelected ? active : inactive,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? active : inactive,
                letterSpacing: 0.2,
              ),
              child: Text(data.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SOS Floating Action Button ───────────────────────────────────────────────

class _SosFab extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _SosFab({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: pulseAnim.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withValues(alpha: 0.22),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push('/sos');
              },
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.touch_app_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text('Tap to open emergency SOS',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

