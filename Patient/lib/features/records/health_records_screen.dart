// Health Records Screen — Premium AI Medical Memory Dashboard
// UI-only rewrite. All backend logic preserved: recordsProvider,
// uploadAndProcessRecord, setFilter, refresh, navigation routes.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_box.dart';
import 'widgets/records_vault_folder_card.dart';
import 'widgets/medical_timeline_widget.dart';
import 'widgets/report_trend_card.dart';
import 'widgets/doctor_share_sheet.dart';
import 'widgets/record_ai_card.dart';
import 'widgets/ai_trend_timeline.dart';
import 'providers/records_provider.dart';

class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key});

  static const _categories = [
    (title: 'Prescriptions', icon: Icons.medication_rounded, color: Color(0xFF10B981), type: 'Prescription'),
    (title: 'Blood Tests', icon: Icons.science_rounded, color: Color(0xFF0EA5E9), type: 'Blood Test'),
    (title: 'Imaging / X-ray', icon: Icons.image_rounded, color: Color(0xFF8B5CF6), type: 'Imaging'),
    (title: 'Discharge Notes', icon: Icons.local_hospital_rounded, color: Color(0xFFEF4444), type: 'Discharge Note'),
    (title: 'Doctor Notes', icon: Icons.note_alt_rounded, color: Color(0xFF6366F1), type: 'Doctor Note'),
    (title: 'Insurance', icon: Icons.shield_rounded, color: Color(0xFF14B8A6), type: 'Insurance'),
    (title: 'Documents', icon: Icons.description_rounded, color: Color(0xFF64748B), type: 'Other'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncState = ref.watch(recordsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          asyncState.when(
            loading: () => _buildLoading(context, isDark),
            error: (e, _) => _buildError(context, ref, isDark),
            data: (state) => _buildDashboard(context, ref, state, isDark),
          ),
        ],
      ),
      floatingActionButton: _buildUploadFAB(context, ref, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Existing backend logic (unchanged) ──────────────────────────────────

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Scanning & processing with AI…'),
          duration: Duration(seconds: 1)),
    );

    final success =
        await ref.read(recordsProvider.notifier).uploadAndProcessRecord();

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Record added to vault and AI-summarized.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload cancelled or failed.')));
      }
    }
  }

  // ── Upload FAB ──────────────────────────────────────────────────────────

  Widget _buildUploadFAB(BuildContext context, WidgetRef ref, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0), // Elevate above bottom navbar
      child: GestureDetector(
        onTap: () {
        HapticFeedback.mediumImpact();
        _handleUpload(context, ref);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_rounded, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text('Upload to Vault',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        ),
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context, bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 60),
            ...List.generate(
                5,
                (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerBox(height: 72, borderRadius: 16),
                    )),
          ],
        ),
      ),
    );
  }

  // ── Error ───────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, WidgetRef ref, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.30)
                  : AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Failed to load records',
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.read(recordsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Main Dashboard ──────────────────────────────────────────────────────

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, RecordsState state, bool isDark) {
    final records = state.allRecords;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    // Compute stats from existing records
    final totalCount = records.length;
    final abnormalCount = records.where((r) {
      final meta = r['metadata'] as Map<String, dynamic>? ?? {};
      final summary = meta['ai_summary']?.toString().toLowerCase() ?? '';
      return summary.contains('abnormal') ||
          summary.contains('critical') ||
          summary.contains('high') ||
          summary.contains('low');
    }).length;
    final lastUploaded = records.isNotEmpty
        ? (records.first['title']?.toString() ?? 'N/A')
        : 'None';

    return CustomScrollView(
      slivers: [
        // ═══════════════════════════════════════════════════════════════
        // HEADER
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.30)
                    : Colors.white.withValues(alpha: 0.60),
                padding: EdgeInsets.fromLTRB(
                    16, MediaQuery.paddingOf(context).top + 10, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.folder_special_rounded,
                          size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Medical Vault',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                  letterSpacing: -0.3)),
                          Text('AI-powered record intelligence',
                              style:
                                  TextStyle(fontSize: 11, color: textSub)),
                        ],
                      ),
                    ),
                    // Health ID
                    GestureDetector(
                      onTap: () => context.push('/medassist-card'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.09)
                              : Colors.white.withValues(alpha: 0.72),
                          border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white,
                              width: 0.8),
                        ),
                        child: Icon(Icons.qr_code_rounded,
                            size: 16,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Share
                    GestureDetector(
                      onTap: () => DoctorShareSheet.show(context,
                          allRecords: records),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0EA5E9)
                              .withValues(alpha: 0.12),
                          border: Border.all(
                              color: const Color(0xFF0EA5E9)
                                  .withValues(alpha: 0.22),
                              width: 0.8),
                        ),
                        child: const Icon(Icons.share_rounded,
                            size: 15, color: Color(0xFF0EA5E9)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // VAULT HERO STATS
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: GlassCard(
              radius: 18,
              blur: 14,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _StatPill(
                      label: 'Total',
                      value: '$totalCount',
                      icon: Icons.description_rounded,
                      color: const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _StatPill(
                      label: 'Abnormal',
                      value: '$abnormalCount',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Last Upload',
                            style: TextStyle(fontSize: 9, color: textSub)),
                        Text(lastUploaded,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: textPrimary)),
                      ],
                    ),
                  ),
                  // AI sync badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.22),
                          width: 0.6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded,
                            size: 10, color: Color(0xFF10B981)),
                        SizedBox(width: 3),
                        Text('Synced',
                            style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // FILTER CHIPS
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterPill('All', state.activeFilter == 'All', isDark,
                    () => ref.read(recordsProvider.notifier).setFilter('All')),
                ..._categories.map((c) => _FilterPill(
                    c.title,
                    state.activeFilter == c.type,
                    isDark,
                    () => ref
                        .read(recordsProvider.notifier)
                        .setFilter(c.type))),
              ],
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // CATEGORY VAULT FOLDERS (when 'All' filter)
        // ═══════════════════════════════════════════════════════════════
        if (state.activeFilter == 'All') ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text('Vault Categories',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final catRecords = records
                    .where((r) =>
                        (r['record_type'] ?? r['type']) == cat.type)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RecordsVaultFolderCard(
                    title: cat.title,
                    icon: cat.icon,
                    color: cat.color,
                    count: catRecords.length,
                    lastUpdated: catRecords.isNotEmpty
                        ? (catRecords.first['date']?.toString() ?? '')
                        : '',
                    aiPreview: catRecords.isNotEmpty
                        ? ((catRecords.first['metadata']
                                    as Map<String, dynamic>?)?['ai_summary']
                                ?.toString() ??
                            '')
                        : null,
                    onTap: () => ref
                        .read(recordsProvider.notifier)
                        .setFilter(cat.type),
                  ),
                );
              },
            ),
          ),

          // ── MEDICAL TIMELINE ────────────────────────────────────────
          if (records.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text('Medical Memory Timeline',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  radius: 18,
                  blur: 14,
                  padding: const EdgeInsets.all(14),
                  child: MedicalTimelineWidget(records: records),
                ),
              ),
            ),
          ],

          // ── REPORT TRENDS ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ReportTrendCard(records: records),
            ),
          ),
        ],

        // ═══════════════════════════════════════════════════════════════
        // FILTERED RECORDS LIST
        // ═══════════════════════════════════════════════════════════════
        if (state.activeFilter != 'All') ...[
          // Show AI longitudinal trend for this specific category
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: AiTrendTimeline(category: state.activeFilter),
            ),
          ),
          
          if (state.filteredRecords.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        size: 48,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.20)
                            : AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text('No ${state.activeFilter} records',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary)),
                    Text('Upload your first document',
                        style: TextStyle(fontSize: 12, color: textSub)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              sliver: SliverList.builder(
                itemCount: state.filteredRecords.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RecordAiCard(record: state.filteredRecords[i]),
                ),
              ),
            ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

// ── Stat Pill ───────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: color.withValues(alpha: 0.22), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 8,
                      color: color.withValues(alpha: 0.70),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filter Pill ─────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterPill(this.label, this.isSelected, this.isDark, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)])
                : null,
            color: isSelected
                ? null
                : (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.60)),
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 0.6),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.60)
                          : AppColors.textSecondary))),
        ),
      ),
    );
  }
}

