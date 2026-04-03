import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RecordAiCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const RecordAiCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final metadata = record['metadata'] as Map<String, dynamic>? ?? {};
    final aiSummary = metadata['ai_summary'] as String?;
    final metrics = metadata['extracted_metrics'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: AppColors.primary),
          ),
          title: Text(record['title'] ?? 'Record', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            record['record_type'] ?? 'General',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // AI Summary Section
                  if (aiSummary != null) ...[
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: AppColors.warning, size: 20),
                        SizedBox(width: 8),
                        Text('AI Abstract', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Text(aiSummary, style: const TextStyle(color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Extracted Metrics Section
                  if (metrics != null && metrics.isNotEmpty) ...[
                    const Text('Extracted Key Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...metrics.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(color: AppColors.textSecondary)),
                              Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Source'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softBlue,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
