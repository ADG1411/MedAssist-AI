// Record Intelligence Viewer — AI Report Intelligence Screen
// NEW file. Uses existing record data from recordsProvider.
// No backend changes — reads record maps and metadata as-is.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_card.dart';
import 'widgets/ai_report_summary_card.dart';
import 'widgets/abnormal_value_chip.dart';
import 'widgets/doctor_share_sheet.dart';

class RecordIntelligenceViewer extends StatelessWidget {
  final Map<String, dynamic> record;

  const RecordIntelligenceViewer({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final title = record['title']?.toString() ?? 'Untitled Record';
    final type = record['record_type']?.toString() ??
        record['type']?.toString() ??
        'Document';
    final date = record['created_at']?.toString() ??
        record['date']?.toString() ??
        '';
    final doctorName = record['doctorName']?.toString() ?? '';
    final metadata = record['metadata'] as Map<String, dynamic>? ?? {};
    final aiSummary = metadata['ai_summary']?.toString() ?? '';
    final metrics =
        metadata['extracted_metrics'] as Map<String, dynamic>? ?? {};
    final confidence = (metadata['confidence'] ?? 0).toDouble();
    // Parse abnormal values from metrics
    final abnormalValues = _parseAbnormalValues(metrics);

    // AI next actions
    final nextActions = _generateNextActions(type, aiSummary, abnormalValues);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          CustomScrollView(
            slivers: [
              // ═════════════════════════════════════════════════════════
              // HEADER
              // ═════════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.30)
                          : Colors.white.withValues(alpha: 0.60),
                      padding: EdgeInsets.fromLTRB(
                          16,
                          MediaQuery.paddingOf(context).top + 10,
                          16,
                          14),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.09)
                                    : Colors.white.withValues(alpha: 0.72),
                              ),
                              child: Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Report Intelligence',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                        letterSpacing: -0.3)),
                                Text('AI-analyzed medical document',
                                    style: TextStyle(
                                        fontSize: 10, color: textSub)),
                              ],
                            ),
                          ),
                          // Share button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              DoctorShareSheet.show(context,
                                  record: record);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0EA5E9)
                                    .withValues(alpha: 0.12),
                              ),
                              child: const Icon(Icons.share_rounded,
                                  size: 15, color: Color(0xFF0EA5E9)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Download PDF
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Downloading PDF…')),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.12),
                              ),
                              child: const Icon(
                                  Icons.download_rounded,
                                  size: 15,
                                  color: Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ═════════════════════════════════════════════════════════
              // 1. FILE PREVIEW HERO
              // ═════════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: GlassCard(
                    radius: 18,
                    blur: 14,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _typeColor(type)
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Icon(_typeIcon(type),
                                  size: 22,
                                  color: _typeColor(type)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _typeColor(type)
                                              .withValues(
                                                  alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  6),
                                        ),
                                        child: Text(type,
                                            style: TextStyle(
                                                fontSize: 9,
                                                color:
                                                    _typeColor(type),
                                                fontWeight:
                                                    FontWeight
                                                        .w700)),
                                      ),
                                      if (date.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                            Icons
                                                .schedule_rounded,
                                            size: 11,
                                            color: textSub),
                                        const SizedBox(width: 3),
                                        Text(date,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: textSub)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (doctorName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person_rounded,
                                  size: 13, color: textSub),
                              const SizedBox(width: 5),
                              Text(doctorName,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: textSub,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                        if (confidence > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 12,
                                  color: Color(0xFF6366F1)),
                              const SizedBox(width: 4),
                              Text(
                                'AI Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: confidence,
                                    minHeight: 3,
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(
                                            alpha: 0.06)
                                        : Colors.black.withValues(
                                            alpha: 0.05),
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            Color(0xFF6366F1)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ═════════════════════════════════════════════════════════
              // 1.5. ACTUAL FILE PREVIEW (IMAGE / PDF)
              // ═════════════════════════════════════════════════════════
              if ((record['file_url']?.toString() ?? '').isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: GlassCard(
                      radius: 18,
                      blur: 14,
                      padding: const EdgeInsets.all(12),
                      child: Builder(builder: (ctx) {
                        final fileUrl = record['file_url']!.toString();
                        final isPdf = fileUrl.toLowerCase().endsWith('.pdf') ||
                            (record['file_type']?.toString().contains('pdf') == true);
                        if (isPdf) {
                          return GestureDetector(
                            onTap: () async {
                              final uri = Uri.tryParse(fileUrl);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.20)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.picture_as_pdf_rounded,
                                      size: 40, color: Color(0xFFEF4444)),
                                  const SizedBox(height: 6),
                                  Text('Tap to open PDF',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: const Color(0xFFEF4444).withValues(alpha: 0.80),
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          );
                        }
                        // IMAGE
                        return GestureDetector(
                          onTap: () async {
                            final uri = Uri.tryParse(fileUrl);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fileUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_rounded,
                                        size: 36, color: AppColors.primary),
                                    SizedBox(height: 6),
                                    Text('Preview unavailable',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary)),
                                  ],
                                ),
                              ),
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
                        );
                      }),
                    ),
                  ),
                ),

              // ═════════════════════════════════════════════════════════
              // 2. AI SUMMARY
              // ═════════════════════════════════════════════════════════
              if (aiSummary.isNotEmpty || metrics.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: AiReportSummaryCard(record: record),
                  ),
                ),

              // ═════════════════════════════════════════════════════════
              // 3. ABNORMAL VALUE HIGHLIGHTS
              // ═════════════════════════════════════════════════════════
              if (abnormalValues.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Text('Lab Value Analysis',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: abnormalValues.length,
                    itemBuilder: (_, i) => abnormalValues[i],
                  ),
                ),
              ],

              // ═════════════════════════════════════════════════════════
              // 4. AI NEXT ACTIONS
              // ═════════════════════════════════════════════════════════
              if (nextActions.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded,
                            size: 14, color: Color(0xFF0EA5E9)),
                        const SizedBox(width: 6),
                        Text('AI Recommended Actions',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassCard(
                      radius: 16,
                      blur: 12,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: nextActions.map((action) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: action.color
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(7),
                                  ),
                                  child: Icon(action.icon,
                                      size: 13,
                                      color: action.color),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(action.title,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                              color:
                                                  textPrimary)),
                                      if (action.subtitle
                                          .isNotEmpty)
                                        Text(
                                            action.subtitle,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color:
                                                    textSub)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],

              // ═════════════════════════════════════════════════════════
              // 5. ACTION BUTTONS
              // ═════════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.share_rounded,
                          label: 'Share with Doctor',
                          color: const Color(0xFF0EA5E9),
                          onTap: () => DoctorShareSheet.show(context,
                              record: record),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.download_rounded,
                          label: 'Download PDF',
                          color: const Color(0xFF10B981),
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content:
                                        Text('Downloading…')));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return const Color(0xFF10B981);
      case 'lab report':
        return const Color(0xFF0EA5E9);
      case 'imaging':
        return const Color(0xFF8B5CF6);
      case 'ai result':
        return const Color(0xFFF59E0B);
      case 'discharge summary':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return Icons.medication_rounded;
      case 'lab report':
        return Icons.science_rounded;
      case 'imaging':
        return Icons.image_rounded;
      case 'ai result':
        return Icons.auto_awesome;
      case 'discharge summary':
        return Icons.local_hospital_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  List<AbnormalValueChip> _parseAbnormalValues(
      Map<String, dynamic> metrics) {
    final chips = <AbnormalValueChip>[];

    for (final entry in metrics.entries) {
      final key = entry.key.replaceAll('_', ' ');
      final val = entry.value.toString();

      // Heuristic: detect if value looks like a lab result
      if (val.contains('low') || val.contains('LOW')) {
        chips.add(AbnormalValueChip(
          label: key,
          value: val,
          status: AbnormalStatus.low,
          explanation: 'Value below normal range',
        ));
      } else if (val.contains('high') || val.contains('HIGH')) {
        chips.add(AbnormalValueChip(
          label: key,
          value: val,
          status: AbnormalStatus.high,
          explanation: 'Value above normal range',
        ));
      } else if (val.contains('critical') || val.contains('CRITICAL')) {
        chips.add(AbnormalValueChip(
          label: key,
          value: val,
          status: AbnormalStatus.critical,
          explanation: 'Critical value — seek attention',
        ));
      }
    }
    return chips;
  }

  List<_NextAction> _generateNextActions(
      String type, String summary, List<AbnormalValueChip> abnormals) {
    final actions = <_NextAction>[];

    if (abnormals.isNotEmpty) {
      actions.add(const _NextAction(
        icon: Icons.medical_services_rounded,
        title: 'Consult a specialist',
        subtitle: 'Abnormal values detected — discuss with your doctor',
        color: Color(0xFFEF4444),
      ));
    }

    if (type.toLowerCase().contains('lab')) {
      actions.add(const _NextAction(
        icon: Icons.repeat_rounded,
        title: 'Repeat test in 7-14 days',
        subtitle: 'Track changes over time for accurate trend analysis',
        color: Color(0xFF0EA5E9),
      ));
    }

    actions.add(const _NextAction(
      icon: Icons.upload_file_rounded,
      title: 'Upload previous reports',
      subtitle: 'Enable AI to compare and detect trends',
      color: Color(0xFF8B5CF6),
    ));

    actions.add(const _NextAction(
      icon: Icons.share_rounded,
      title: 'Share with your doctor',
      subtitle: 'Generate secure expiring link for doctor handoff',
      color: Color(0xFF10B981),
    ));

    if (summary.toLowerCase().contains('diet') ||
        summary.toLowerCase().contains('iron') ||
        summary.toLowerCase().contains('vitamin')) {
      actions.add(const _NextAction(
        icon: Icons.restaurant_rounded,
        title: 'Adjust nutrition plan',
        subtitle: 'AI suggests dietary improvements based on report',
        color: Color(0xFFF59E0B),
      ));
    }

    return actions;
  }
}

class _NextAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _NextAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withValues(alpha: 0.22), width: 0.7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
