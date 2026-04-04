import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Blue gradient palette ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF60A5FA);
  static const Color softBlue = Color(0xFFEFF6FF);
  static const Color paleBlue = Color(0xFFDBEAFE);

  // ── Semantic colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF0F5FF);
  static const Color cardLight = Color(0xFFF8FAFF);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // ── Gradients (reusable) ───────────────────────────────────────────────────
  static const List<Color> blueGradient = [
    Color(0xFF2563EB),
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
  ];

  static const List<Color> headerGradient = [
    Color(0xFF1E40AF),
    Color(0xFF2563EB),
    Color(0xFF3B82F6),
  ];

  static const List<Color> cardGradient = [
    Color(0xFFEFF6FF),
    Color(0xFFF8FAFF),
  ];

  // ── Shape constants ────────────────────────────────────────────────────────
  static const double radius = 20.0;
  static const double radiusSm = 12.0;
  static const double radiusLg = 28.0;
}

