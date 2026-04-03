import 'package:flutter/material.dart';

/// Full-screen DNA background used consistently across all shell-route screens.
class AppBackground extends StatelessWidget {
  final bool isDark;
  const AppBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF050E1A) : const Color(0xFFDCEEFB),
            image: DecorationImage(
              image: const AssetImage('assets/images/dashboard_bg.png'),
              fit: BoxFit.cover,
              // Light: heavy white wash → icons become a soft watermark
              // Dark:  strong dark veil → keeps the colourful image subtle
              colorFilter: isDark
                  ? ColorFilter.mode(
                      const Color(0xFF050E1A).withValues(alpha: 0.78),
                      BlendMode.darken,
                    )
                  : ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.52),
                      BlendMode.lighten,
                    ),
              onError: (e, _) {},
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.35, 1.0],
              colors: isDark
                  ? [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF050E1A).withValues(alpha: 0.40),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.30),
                      Colors.white.withValues(alpha: 0.72),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}
