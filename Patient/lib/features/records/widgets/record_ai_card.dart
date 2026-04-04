import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/records_provider.dart';
import '../record_intelligence_viewer.dart';

class RecordAiCard extends ConsumerWidget {
  final Map<String, dynamic> record;

  const RecordAiCard({super.key, required this.record});

  Future<void> _deleteRecord(BuildContext context, WidgetRef ref) async {
    final recordId = record['id']?.toString();
    if (recordId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Record?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(
          'This will permanently delete "${record['title'] ?? 'this record'}" from your vault and cannot be undone.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref.read(recordsProvider.notifier).deleteRecord(
      recordId,
      fileUrl: record['file_url']?.toString(),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? '🗑️ Record deleted successfully.'
            : '⚠️ Failed to delete. Please try again.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _openSourceFile(BuildContext context) async {
    final fileUrl = record['file_url']?.toString() ?? '';
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No source file available for this record.')),
      );
      return;
    }

    final uri = Uri.tryParse(fileUrl);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metadata = record['metadata'] as Map<String, dynamic>? ?? {};
    final aiSummary = metadata['ai_summary'] as String?;
    final metrics = metadata['extracted_metrics'] as Map<String, dynamic>?;
    final fileUrl = record['file_url']?.toString() ?? '';
    final isPdf = record['file_type']?.toString().contains('pdf') == true ||
        fileUrl.toLowerCase().endsWith('.pdf');
    final hasFile = fileUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 22),
          ),
          title: Text(
            record['title'] ?? 'Record',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    record['record_type'] ?? 'General',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (isPdf) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('PDF',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  const SizedBox(height: 12),

                  // ── Image Preview ─────────────────────────────────────
                  if (hasFile && !isPdf) ...[
                    GestureDetector(
                      onTap: () => _openSourceFile(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          fileUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFilePlaceholder(
                              isDark, Icons.broken_image_rounded, 'Failed to load image'),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── PDF File Placeholder ──────────────────────────────
                  if (hasFile && isPdf) ...[
                    GestureDetector(
                      onTap: () => _openSourceFile(context),
                      child: _buildFilePlaceholder(
                          isDark, Icons.picture_as_pdf_rounded, 'Tap to open PDF'),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── AI Summary Section ────────────────────────────────
                  if (aiSummary != null && aiSummary.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 14),
                        SizedBox(width: 6),
                        Text('AI Summary',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        aiSummary,
                        style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.80) : AppColors.textPrimary,
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Extracted Metrics Section ─────────────────────────
                  if (metrics != null && metrics.isNotEmpty) ...[
                    Text('Key Metrics',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: isDark ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: metrics.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key.replaceAll('_', ' '),
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.55)
                                        : AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                              Text(
                                e.value.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── No AI yet placeholder ─────────────────────────────
                  if ((aiSummary == null || aiSummary.isEmpty) &&
                      (metrics == null || metrics.isEmpty)) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded,
                              size: 14,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.30)
                                  : AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'AI analysis pending…',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.40)
                                    : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Action Buttons ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecordIntelligenceViewer(record: record),
                            ),
                          ),
                          icon: const Icon(Icons.analytics_rounded, size: 15),
                          label: const Text('AI Report', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.40)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (hasFile) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openSourceFile(context),
                            icon: Icon(
                                isPdf
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.image_rounded,
                                size: 15),
                            label: Text('View ${isPdf ? 'PDF' : 'Image'}',
                                style: const TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // ── Delete Button ─────────────────────────────────────
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteRecord(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded, size: 15),
                      label: const Text('Delete Record',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: BorderSide(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePlaceholder(bool isDark, IconData icon, String label) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppColors.primary.withValues(alpha: 0.60)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
