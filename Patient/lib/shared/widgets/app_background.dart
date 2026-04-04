import 'dart:ui';
import 'package:flutter/material.dart';

/// Full-screen background with Apple-like frosted blur used across all screens.
class AppBackground extends StatelessWidget {
  final bool isDark;
  const AppBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base image layer
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF050E1A) : const Color(0xFFF8FAFC),
            image: DecorationImage(
              image: const AssetImage('assets/images/splash_bg.jpg'),
              fit: BoxFit.cover,
              colorFilter: isDark
                  ? ColorFilter.mode(
                      const Color(0xFF050E1A).withValues(alpha: 0.82),
                      BlendMode.darken,
                    )
                  : ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.40),
                      BlendMode.lighten,
                    ),
              onError: (e, _) {},
            ),
          ),
        ),

        // Apple-style frosted glass blur
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: isDark
                  ? const Color(0xFF050E1A).withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ),

        // Subtle gradient veil
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: isDark
                  ? [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF050E1A).withValues(alpha: 0.35),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.50),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}
