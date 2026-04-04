import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_box.dart';
import 'providers/doctor_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SORT ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum _Sort { aiMatch, topRated, earliest, lowestFee }

extension _SortExt on _Sort {
  String get label => switch (this) {
    _Sort.aiMatch   => 'AI Match',
    _Sort.topRated  => 'Top Rated',
    _Sort.earliest  => 'Earliest',
    _Sort.lowestFee => 'Lowest Fee',
  };
  IconData get icon => switch (this) {
    _Sort.aiMatch   => Icons.auto_awesome_rounded,
    _Sort.topRated  => Icons.star_rounded,
    _Sort.earliest  => Icons.flash_on_rounded,
    _Sort.lowestFee => Icons.savings_rounded,
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// SPECIALTIES
// ═══════════════════════════════════════════════════════════════════════════════

const _specialties = [
  'All', 'Cardiology', 'General Practice', 'Gastroenterology',
  'Dermatology', 'Neurology', 'Orthopedic',
];

const _specColors = <String, Color>{
  'Cardiology':       Color(0xFFEF4444),
  'Gastroenterology': Color(0xFF10B981),
  'General Practice': Color(0xFF6366F1),
  'Dermatology':      Color(0xFFF59E0B),
  'Neurology':        Color(0xFF8B5CF6),
  'Orthopedic':       Color(0xFF06B6D4),
};

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class DoctorExplorerScreen extends ConsumerStatefulWidget {
  const DoctorExplorerScreen({super.key});

  @override
  ConsumerState<DoctorExplorerScreen> createState() => _DoctorExplorerScreenState();
}

class _DoctorExplorerScreenState extends ConsumerState<DoctorExplorerScreen> {
  final _searchCtrl = TextEditingController();
  _Sort _sort = _Sort.aiMatch;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applySorting(
      List<Map<String, dynamic>> docs, String? aiSpec) {
    final list = List<Map<String, dynamic>>.from(docs);
    switch (_sort) {
      case _Sort.aiMatch:
        list.sort((a, b) {
          final am = a['specialty']?.toString().toLowerCase() == aiSpec?.toLowerCase() ? 1 : 0;
          final bm = b['specialty']?.toString().toLowerCase() == aiSpec?.toLowerCase() ? 1 : 0;
          if (am != bm) return bm - am;
          return ((b['rating'] as num?) ?? 0).compareTo((a['rating'] as num?) ?? 0);
        });
      case _Sort.topRated:
        list.sort((a, b) => ((b['rating'] as num?) ?? 0).compareTo((a['rating'] as num?) ?? 0));
      case _Sort.earliest:
        list.sort((a, b) {
          final at = (a['available_slots'] as List? ?? []).any((s) => s.toString().startsWith('Today')) ? 0 : 1;
          final bt = (b['available_slots'] as List? ?? []).any((s) => s.toString().startsWith('Today')) ? 0 : 1;
          return at - bt;
        });
      case _Sort.lowestFee:
        list.sort((a, b) => ((a['consultation_fee'] as num?) ?? 0).compareTo((b['consultation_fee'] as num?) ?? 0));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(doctorFilterProvider);
    final asyncDocs = ref.watch(doctorsListProvider);
    final aiSpec = ref.watch(aiMatchProvider).value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _Header(isDark: isDark),
                ),
                const SizedBox(height: 16),

                // ── Search ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SearchBar(
                    controller: _searchCtrl,
                    isDark: isDark,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Specialty chips ────────────────────────────────────
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _specialties.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final s = _specialties[i];
                      final active = filter == s;
                      return GestureDetector(
                        onTap: () => ref.read(doctorFilterProvider.notifier).setFilter(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: active ? null : Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
                              width: 0.5,
                            ),
                            boxShadow: active ? [
                              BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
                            ] : null,
                          ),
                          child: Text(s, style: TextStyle(
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.60) : AppColors.textSecondary),
                          )),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // ── Sort pills ─────────────────────────────────────────
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _Sort.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final s = _Sort.values[i];
                      final active = _sort == s;
                      return GestureDetector(
                        onTap: () => setState(() => _sort = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(s.icon, size: 12, color: active ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.40) : AppColors.textHint)),
                              const SizedBox(width: 4),
                              Text(s.label, style: TextStyle(
                                fontSize: 11,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                color: active ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary),
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── Doctor list ────────────────────────────────────────
                Expanded(
                  child: asyncDocs.when(
                    loading: () => _buildLoading(),
                    error: (e, _) => _buildError(),
                    data: (raw) {
                      final q = _searchCtrl.text.toLowerCase();
                      var docs = q.isEmpty ? raw : raw.where((d) =>
                        d['name'].toString().toLowerCase().contains(q) ||
                        d['specialty'].toString().toLowerCase().contains(q) ||
                        (d['bio'] ?? '').toString().toLowerCase().contains(q)
                      ).toList();
                      docs = _applySorting(docs, aiSpec);

                      if (docs.isEmpty) return _buildEmpty(isDark);

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                        itemCount: (aiSpec != null ? 1 : 0) + docs.length,
                        itemBuilder: (_, i) {
                          // AI recommendation banner at top
                          if (aiSpec != null && i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _AiMatchBanner(
                                aiSpecialty: aiSpec,
                                isDark: isDark,
                                onApply: () => ref.read(doctorFilterProvider.notifier).setFilter(aiSpec),
                              ),
                            );
                          }
                          final idx = aiSpec != null ? i - 1 : i;
                          final doc = docs[idx];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DoctorCard(
                              doctor: doc,
                              aiSpecialty: aiSpec,
                              isDark: isDark,
                              onTap: () => context.push('/doctor-detail', extra: doc),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(children: List.generate(3, (_) => const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: ShimmerBox(height: 140, borderRadius: 20),
    ))),
  );

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.cloud_off_outlined, size: 32, color: AppColors.danger),
      ),
      const SizedBox(height: 14),
      const Text('Could not load doctors', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: () => ref.invalidate(doctorsListProvider),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry'),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
    ]),
  );

  Widget _buildEmpty(bool isDark) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.person_search_rounded, size: 32, color: AppColors.primary),
      ),
      const SizedBox(height: 14),
      const Text('No doctors found', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 4),
      Text('Try adjusting filters or search',
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.textSecondary)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find a Doctor', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text('Book trusted specialists near you', style: TextStyle(fontSize: 14, color: textSub)),
            ],
          ),
        ),
        // Online badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
            const SizedBox(width: 5),
            const Text('3 Online', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
          ]),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border.withValues(alpha: 0.5),
          width: 0.5,
        ),
        boxShadow: [
          if (!isDark) BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 20,
              color: isDark ? Colors.white.withValues(alpha: 0.40) : AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name, specialty...',
                hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.30) : AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () { controller.clear(); onChanged(''); },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.close_rounded, size: 18,
                    color: isDark ? Colors.white.withValues(alpha: 0.40) : AppColors.textHint),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AI MATCH BANNER
// ═══════════════════════════════════════════════════════════════════════════════

class _AiMatchBanner extends StatelessWidget {
  final String aiSpecialty;
  final bool isDark;
  final VoidCallback onApply;
  const _AiMatchBanner({required this.aiSpecialty, required this.isDark, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF60A5FA)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Recommends $aiSpecialty', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                )),
                const SizedBox(height: 2),
                Text('Based on your symptoms & health data', style: TextStyle(
                  fontSize: 12, color: isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary,
                )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); onApply(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Text('Apply', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOCTOR CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final String? aiSpecialty;
  final bool isDark;
  final VoidCallback onTap;
  const _DoctorCard({required this.doctor, this.aiSpecialty, required this.isDark, required this.onTap});

  bool get _isAiMatch =>
      aiSpecialty != null && doctor['specialty']?.toString().toLowerCase() == aiSpecialty?.toLowerCase();

  bool get _isOnline => (doctor['id']?.toString().hashCode ?? 0) % 3 != 0;

  @override
  Widget build(BuildContext context) {
    final name = doctor['name']?.toString() ?? 'Doctor';
    final specialty = doctor['specialty']?.toString() ?? '';
    final rating = (doctor['rating'] as num?)?.toDouble() ?? 0;
    final experience = (doctor['experience'] as num?)?.toInt() ?? 0;
    final fee = (doctor['consultation_fee'] as num?)?.toInt() ?? 0;
    final slots = (doctor['available_slots'] as List? ?? []).map((e) => e.toString()).take(2).toList();
    final initials = name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
    final specColor = _specColors[specialty] ?? AppColors.primary;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + info + fee ────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: specColor.withValues(alpha: 0.10),
                        border: Border.all(color: specColor.withValues(alpha: 0.30), width: 1.5),
                      ),
                      child: Center(child: Text(initials, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: specColor))),
                    ),
                    if (_isOnline)
                      Positioned(right: 1, bottom: 1, child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: const Color(0xFF10B981),
                          border: Border.all(color: isDark ? const Color(0xFF1A2332) : Colors.white, width: 2),
                        ),
                      )),
                  ],
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(name, style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.2),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (_isAiMatch) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF60A5FA)]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('AI Match', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: specColor)),
                        const SizedBox(width: 5),
                        Text(specialty, style: TextStyle(fontSize: 12, color: specColor, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text('$rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary)),
                        Text('  ·  ${experience}y exp', style: TextStyle(fontSize: 11, color: textSub)),
                      ]),
                    ],
                  ),
                ),

                // Fee
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹$fee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                    Text('consult', style: TextStyle(fontSize: 10, color: textSub)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Slots + Book button ────────────────────────────────────
            Row(
              children: [
                // Slot chips
                if (slots.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: slots.map((slot) {
                        final isToday = slot.startsWith('Today');
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFF10B981).withValues(alpha: 0.10)
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.softBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(slot, style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isToday ? const Color(0xFF10B981) : textSub,
                          )),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Expanded(child: Text('Schedule available', style: TextStyle(fontSize: 11, color: textSub))),

                const SizedBox(width: 10),

                // Book button
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); onTap(); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Text('Book', style: TextStyle(
                      fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700,
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
