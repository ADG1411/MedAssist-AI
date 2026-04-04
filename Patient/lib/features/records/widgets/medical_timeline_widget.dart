import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Chronological medical memory timeline — shows recent record events.
/// Reads from existing allRecords list. Pure UI widget.
class MedicalTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const MedicalTimelineWidget({super.key, required this.records});

  String _timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (_) {
      return dateStr;
    }
  }

  IconData _typeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'prescription':
        return Icons.medication_rounded;
      case 'blood test':
        return Icons.science_rounded;
      case 'imaging':
        return Icons.image_rounded;
      case 'ai result':
        return Icons.auto_awesome;
      case 'discharge note':
        return Icons.local_hospital_rounded;
      case 'doctor note':
        return Icons.note_alt_rounded;
      case 'insurance':
        return Icons.shield_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color _typeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'prescription':
        return const Color(0xFF10B981);
      case 'blood test':
        return const Color(0xFF0EA5E9);
      case 'imaging':
        return const Color(0xFF8B5CF6);
      case 'ai result':
        return const Color(0xFFF59E0B);
      case 'discharge note':
        return const Color(0xFFEF4444);
      case 'doctor note':
        return const Color(0xFF6366F1);
      case 'insurance':
        return const Color(0xFF14B8A6);
      default:
        return AppColors.primary;
    }
  }

  String _eventText(Map<String, dynamic> record) {
    final title = record['title'] ?? 'Untitled';
    final meta = record['metadata'] as Map<String, dynamic>?;
    final hasAi = meta?['ai_summary'] != null;
    if (hasAi) return '$title — AI analyzed';
    return '$title uploaded';
  }

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;
    final sorted = List<Map<String, dynamic>>.from(records)
      ..sort((a, b) {
        final aDate = a['created_at'] ?? a['date'] ?? '';
        final bDate = b['created_at'] ?? b['date'] ?? '';
        return bDate.toString().compareTo(aDate.toString());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sorted.take(6).map((record) {
        final type = record['record_type'] ?? record['type'] ?? 'Document';
        final color = _typeColor(type);
        final dateStr =
            record['created_at']?.toString() ?? record['date']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line + dot
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.20),
                        border: Border.all(color: color, width: 1.5),
                      ),
                    ),
                    Container(
                      width: 1.5,
                      height: 32,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ],
                ),
              ),

              // Event content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(_typeIcon(type), size: 14, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _eventText(record),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: textPrimary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(_timeAgo(dateStr),
                          style: TextStyle(fontSize: 10, color: textSub)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
