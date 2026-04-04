import 'package:flutter/material.dart';

/// Full-screen background — clean blue-tinted gradient with subtle glassmorphism.
class AppBackground extends StatelessWidget {
  final bool isDark;
  final Widget? child;
  const AppBackground({super.key, required this.isDark, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35, 0.7, 1.0],
          colors: isDark
              ? [
                  const Color(0xFF0A1628),
                  const Color(0xFF0D1B2A),
                  const Color(0xFF0F1F32),
                  const Color(0xFF0A1628),
                ]
              : [
                  const Color(0xFFEBF2FF),
                  const Color(0xFFF0F5FF),
                  const Color(0xFFF5F8FF),
                  const Color(0xFFF8FAFF),
                ],
        ),
      ),
      child: child,
    );
  }
}
