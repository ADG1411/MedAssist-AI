import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/shimmer_box.dart';
import 'providers/doctor_provider.dart';
import 'widgets/ai_doctor_match_hero.dart';
import 'widgets/premium_doctor_card.dart';
import 'widgets/doctor_filter_command_bar.dart';
import 'widgets/doctor_profile_preview_sheet.dart';
import 'widgets/earliest_safe_slot_panel.dart';

class DoctorExplorerScreen extends ConsumerStatefulWidget {
  const DoctorExplorerScreen({super.key});

  @override
  ConsumerState<DoctorExplorerScreen> createState() =>
      _DoctorExplorerScreenState();
}

class _DoctorExplorerScreenState extends ConsumerState<DoctorExplorerScreen>
    with SingleTickerProviderStateMixin {
  static const _specialties = [
    'All', 'Cardiology', 'General Practice', 'Gastroenterology',
    'Dermatology', 'Neurology', 'Orthopedic',
  ];

  final _searchCtrl = TextEditingController();
  DoctorSort _activeSort = DoctorSort.aiMatch;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _sort(
      List<Map<String, dynamic>> doctors, String? aiSpecialty) {
    final list = List<Map<String, dynamic>>.from(doctors);
    switch (_activeSort) {
      case DoctorSort.aiMatch:
        list.sort((a, b) {
          final aMatch = (a['specialty']?.toString().toLowerCase() ==
                  aiSpecialty?.toLowerCase())
              ? 1
              : 0;
          final bMatch = (b['specialty']?.toString().toLowerCase() ==
                  aiSpecialty?.toLowerCase())
              ? 1
              : 0;
          if (aMatch != bMatch) return bMatch - aMatch;
          return ((b['rating'] as num?) ?? 0)
              .compareTo((a['rating'] as num?) ?? 0);
        });
      case DoctorSort.earliestSlot:
        list.sort((a, b) {
          final aToday = (a['available_slots'] as List? ?? [])
              .any((s) => s.toString().startsWith('Today'))
              ? 0
              : 1;
          final bToday = (b['available_slots'] as List? ?? [])
              .any((s) => s.toString().startsWith('Today'))
              ? 0
              : 1;
          return aToday - bToday;
        });
      case DoctorSort.topRated:
        list.sort((a, b) => ((b['rating'] as num?) ?? 0)
            .compareTo((a['rating'] as num?) ?? 0));
      case DoctorSort.mostExperienced:
        list.sort((a, b) => ((b['experience'] as num?) ?? 0)
            .compareTo((a['experience'] as num?) ?? 0));
      case DoctorSort.lowestFee:
        list.sort((a, b) => ((a['consultation_fee'] as num?) ?? 0)
            .compareTo((b['consultation_fee'] as num?) ?? 0));
      case DoctorSort.nearby:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeFilter = ref.watch(doctorFilterProvider);
    final asyncDoctors = ref.watch(doctorsListProvider);
    final asyncAiSpecialty = ref.watch(aiMatchProvider);
    final aiSpecialty = asyncAiSpecialty.value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // ── Background ─────────────────────────────────────────────────
          AppBackground(isDark: isDark),

          // ── Main scroll ────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Premium glass app bar ─────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 130,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(isDark, aiSpecialty),
                    collapseMode: CollapseMode.pin,
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(108),
                    child: DoctorFilterCommandBar(
                      searchController: _searchCtrl,
                      activeSpecialty: activeFilter,
                      activeSort: _activeSort,
                      specialties: _specialties,
                      onSpecialtyChanged: (s) => ref
                          .read(doctorFilterProvider.notifier)
                          .setFilter(s),
                      onSortChanged: (s) =>
                          setState(() => _activeSort = s),
                      onSearchChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                // ── Content ───────────────────────────────────────────────
                asyncDoctors.when(
                  loading: () => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildLoading(),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: _buildError(),
                  ),
                  data: (rawDoctors) {
                    // Client-side search filter
                    final q = _searchCtrl.text.toLowerCase();
                    var doctors = q.isEmpty
                        ? rawDoctors
                        : rawDoctors.where((d) {
                            return d['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(q) ||
                                    d['specialty']
                                        .toString()
                                        .toLowerCase()
                                        .contains(q) ||
                                    (d['bio'] ?? '')
                                        .toString()
                                        .toLowerCase()
                                        .contains(q);
                          }).toList();

                    doctors = _sort(doctors, aiSpecialty);

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 12),

                        // ── Urgency sticky banner ──────────────────────
                        _UrgencyBanner(
                          aiSpecialty: aiSpecialty,
                          isDark: isDark,
                          onBook: () {
                            if (doctors.isNotEmpty) {
                              context.push('/doctor-detail',
                                  extra: doctors.first);
                            }
                          },
                        ),

                        // ── AI Match Hero ──────────────────────────────
                        if (aiSpecialty != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: AiDoctorMatchHero(
                              aiSpecialty: aiSpecialty,
                              onApply: () => ref
                                  .read(doctorFilterProvider.notifier)
                                  .setFilter(aiSpecialty),
                            ),
                          ),

                        // ── Earliest Safe Slot Panel ───────────────────
                        if (doctors.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: EarliestSafeSlotPanel(
                              doctors: doctors,
                              urgency: aiSpecialty == 'Cardiology'
                                  ? 'High'
                                  : 'Medium',
                              onBookEarliest: () {
                                final earliest = doctors.firstWhere(
                                  (d) => (d['available_slots'] as List? ?? [])
                                      .any((s) =>
                                          s.toString().startsWith('Today')),
                                  orElse: () => doctors.first,
                                );
                                HapticFeedback.lightImpact();
                                context.push('/doctor-detail',
                                    extra: earliest);
                              },
                            ),
                          ),

                        // ── Results count ──────────────────────────────
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                '${doctors.length} specialist${doctors.length == 1 ? '' : 's'} found',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                          .withValues(alpha: 0.55)
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              if (aiSpecialty != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.auto_awesome,
                                          size: 10,
                                          color: Color(0xFF6366F1)),
                                      const SizedBox(width: 4),
                                      const Text('AI Ranked',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF6366F1),
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ── Doctor cards ───────────────────────────────
                        if (doctors.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 64, height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(Icons.person_search_rounded,
                                        size: 32, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('No doctors found',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  const SizedBox(height: 6),
                                  Text('Try adjusting filters or search',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.45)
                                              : AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...doctors.map((doc) => Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 12),
                                child: PremiumDoctorCard(
                                  doctor: doc,
                                  aiSpecialty: aiSpecialty,
                                  onTap: () =>
                                      DoctorProfilePreviewSheet.show(
                                    context,
                                    doctor: doc,
                                    aiSpecialty: aiSpecialty,
                                  ),
                                  onBook: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/doctor-detail',
                                        extra: doc);
                                  },
                                ),
                              )),

                        const SizedBox(height: 110),
                      ]),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, String? aiSpecialty) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.55),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.paddingOf(context).top + 12, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.09)
                        : Colors.white.withValues(alpha: 0.72),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                      width: 0.8,
                    ),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Your Specialist',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aiSpecialty != null
                          ? 'AI matched to $aiSpecialty based on your health data'
                          : 'Based on your symptom triage & health history',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.55)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Online now badge
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.30),
                          width: 0.6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulsingDot(),
                        SizedBox(width: 5),
                        Text('3 online',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() => Column(
        children: List.generate(
          3,
          (i) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: ShimmerBox(height: 220, borderRadius: 22),
          ),
        ),
      );

  Widget _buildError() => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.cloud_off_outlined,
                    size: 32, color: AppColors.danger),
              ),
              const SizedBox(height: 12),
              const Text('Could not load doctors',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(doctorsListProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
}

// ── Urgency sticky banner (high risk only) ────────────────────────────────────

class _UrgencyBanner extends StatelessWidget {
  final String? aiSpecialty;
  final bool isDark;
  final VoidCallback? onBook;

  const _UrgencyBanner(
      {required this.aiSpecialty,
      required this.isDark,
      required this.onBook});

  @override
  Widget build(BuildContext context) {
    final isHigh = aiSpecialty == 'Cardiology';
    if (!isHigh) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.30),
              width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_rounded,
                color: Color(0xFFEF4444), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Recommended specialist consultation within 2 hours',
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.3),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onBook?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Book Now',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing dot ───────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.3)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: Container(
          width: 7, height: 7,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Color(0xFF10B981)),
        ),
      );
}
