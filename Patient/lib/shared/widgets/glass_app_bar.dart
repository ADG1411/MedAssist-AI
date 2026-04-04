import 'dart:ui';
import 'package:flutter/material.dart';

/// Wraps any [PreferredSizeWidget] AppBar with a frosted-glass backdrop blur,
/// consistent with the liquid-glass nav bar theme.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget child;

  const GlassAppBar({super.key, required this.child});

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: isDark
                  ? const Color.fromARGB(18, 255, 255, 255)
                  : const Color.fromARGB(165, 255, 255, 255),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.55),
                  width: 0.5,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
