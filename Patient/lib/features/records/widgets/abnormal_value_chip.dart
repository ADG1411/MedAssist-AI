import 'package:flutter/material.dart';

/// Premium abnormal/normal/borderline value chip for lab results.
/// Red = abnormal, Yellow = borderline, Green = normal.
/// Shows value label, status, and optional AI explanation.
class AbnormalValueChip extends StatelessWidget {
  final String label;
  final String value;
  final AbnormalStatus status;
  final String? explanation;

  const AbnormalValueChip({
    super.key,
    required this.label,
    required this.value,
    required this.status,
    this.explanation,
  });

  Color get _color => switch (status) {
        AbnormalStatus.critical => const Color(0xFFEF4444),
        AbnormalStatus.high => const Color(0xFFF97316),
        AbnormalStatus.low => const Color(0xFFF59E0B),
        AbnormalStatus.normal => const Color(0xFF10B981),
        AbnormalStatus.borderline => const Color(0xFFF59E0B),
      };

  String get _statusLabel => switch (status) {
        AbnormalStatus.critical => 'CRITICAL',
        AbnormalStatus.high => 'HIGH',
        AbnormalStatus.low => 'LOW',
        AbnormalStatus.normal => 'NORMAL',
        AbnormalStatus.borderline => 'BORDERLINE',
      };

  IconData get _icon => switch (status) {
        AbnormalStatus.critical => Icons.error_rounded,
        AbnormalStatus.high => Icons.arrow_upward_rounded,
        AbnormalStatus.low => Icons.arrow_downward_rounded,
        AbnormalStatus.normal => Icons.check_circle_rounded,
        AbnormalStatus.borderline => Icons.warning_amber_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _color.withValues(alpha: 0.22), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 14, color: _color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A))),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_statusLabel,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _color,
                        letterSpacing: 0.5)),
              ),
              const SizedBox(width: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _color)),
            ],
          ),
          if (explanation != null && explanation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(explanation!,
                style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.50)
                        : const Color(0xFF64748B),
                    height: 1.3)),
          ],
        ],
      ),
    );
  }
}

enum AbnormalStatus { critical, high, low, normal, borderline }
