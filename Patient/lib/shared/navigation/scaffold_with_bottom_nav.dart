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

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav> {

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/symptom-check')) return 1;
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
        context.go('/symptom-check');
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
  _NavItemData(Icons.smart_toy_outlined, Icons.smart_toy_rounded, 'AI Check'),
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
          blur: 28,
          thickness: 32,
          lightIntensity: 0.25,
          glassColor: isDark
              ? const Color.fromARGB(35, 100, 150, 255)
              : const Color.fromARGB(65, 220, 235, 255),
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
                  : Colors.white.withValues(alpha: 0.70),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(32),
            color: isDark
                ? const Color.fromARGB(48, 10, 22, 40)
                : const Color.fromARGB(50, 240, 245, 255),
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
        ? Colors.white.withValues(alpha: 0.40)
        : const Color(0xFF8896AB);

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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? active.withValues(alpha: isDark ? 0.20 : 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
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

