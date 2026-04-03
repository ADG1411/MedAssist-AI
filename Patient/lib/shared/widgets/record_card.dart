import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_section_card.dart';
import 'app_button.dart';

class RecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const RecordCard({super.key, required this.record});

  IconData _getIconForType(String type) {
    if (type == 'Prescription') return Icons.medication;
    if (type == 'Lab Report') return Icons.science;
    if (type == 'AI Result') return Icons.psychology;
    return Icons.file_copy;
  }

  Color _getColorForType(String type) {
    if (type == 'Prescription') return AppColors.success;
    if (type == 'Lab Report') return AppColors.warning;
    if (type == 'AI Result') return AppColors.primary;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final type = record['type'] ?? 'Unknown';
    final iconColor = _getColorForType(type);

    return AppSectionCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconForType(type), color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$type  ${record['date']}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    if (record['doctorName'] != null)
                      Text(
                        'Issued by ${record['doctorName']}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'View Document',
              variant: AppButtonVariant.ghost,
              onPressed: () {
                // Future: Open PDF viewer or Result Screen
              },
            ),
          )
        ],
      ),
    );
  }
}

