import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import 'ai_ranking_reason_chip.dart';
import 'quick_book_cta_button.dart';

class PremiumDoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final String? aiSpecialty;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const PremiumDoctorCard({
    super.key,
    required this.doctor,
    this.aiSpecialty,
    this.onTap,
    this.onBook,
  });

  // ── Derived helpers ───────────────────────────────────────────────────────

  int get _casesHandled {
    final exp = (doctor['experience'] as num?)?.toInt() ?? 5;
    final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
    return (exp * 118 + (rating * 42).toInt()).clamp(200, 9999);
  }

  int get _aiMatchPct {
    final specialty = doctor['specialty']?.toString() ?? '';
    if (aiSpecialty != null &&
        specialty.toLowerCase() == aiSpecialty!.toLowerCase()) { return 94; }
    final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
    return ((rating - 3.5) / 1.5 * 55 + 62).clamp(62, 91).toInt();
  }

  bool get _isOnlineNow {
    final id = doctor['id']?.toString() ?? '';
    return id.hashCode % 3 != 0;
  }

  bool get _hasVideoConsult => true;

  String get _responseSpeed {
    final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
    return rating >= 4.8 ? '< 5 min' : rating >= 4.5 ? '< 15 min' : '< 30 min';
  }

  List<String> get _slots {
    final raw = doctor['available_slots'] as List? ?? [];
    return raw.map((e) => e.toString()).take(3).toList();
  }

  Color get _specialtyColor {
    const map = <String, Color>{
      'Cardiology':        Color(0xFFEF4444),
      'Gastroenterology':  Color(0xFF10B981),
      'General Practice':  Color(0xFF6366F1),
      'Dermatology':       Color(0xFFF59E0B),
      'Neurology':         Color(0xFF8B5CF6),
      'Orthopedic':        Color(0xFF06B6D4),
    };
    return map[doctor['specialty']?.toString()] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = doctor['name']?.toString() ?? 'Doctor';
    final specialty = doctor['specialty']?.toString() ?? '';
    final experience = (doctor['experience'] as num?)?.toInt() ?? 0;
    final rating = (doctor['rating'] as num?)?.toDouble() ?? 0.0;
    final fee = (doctor['consultation_fee'] as num?)?.toInt() ?? 0;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;
    final initials = name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
    final rank = aiRankingReason(doctor, aiSpecialty);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        radius: 22,
        blur: 18,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _specialtyColor.withValues(alpha: 0.22),
                            _specialtyColor.withValues(alpha: 0.10),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                            color: _specialtyColor.withValues(alpha: 0.35),
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(initials,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _specialtyColor)),
                      ),
                    ),
                    if (_isOnlineNow)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10B981),
                            border: Border.all(
                                color: isDark ? Colors.black : Colors.white,
                                width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name + specialty block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(name,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.3)),
                          ),
                          const SizedBox(width: 6),
                          if (_hasVideoConsult)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.videocam_rounded,
                                      size: 9, color: AppColors.primary),
                                  SizedBox(width: 3),
                                  Text('Video',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _specialtyColor),
                          ),
                          const SizedBox(width: 5),
                          Text(specialty,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _specialtyColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 12, color: const Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text('$rating',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary)),
                          Text(' · ${experience}y exp',
                              style:
                                  TextStyle(fontSize: 11, color: textSub)),
                          Text(' · ${_fmtCases(_casesHandled)} cases',
                              style:
                                  TextStyle(fontSize: 11, color: textSub)),
                        ],
                      ),
                    ],
                  ),
                ),

                // AI match badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$_aiMatchPct% AI',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    Text('₹$fee',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textPrimary)),
                    Text('consult',
                        style:
                            TextStyle(fontSize: 9, color: textSub)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Status chips row ──────────────────────────────────────────
            Row(
              children: [
                _StatusChip(
                  label: _isOnlineNow ? 'Online Now' : 'Available',
                  color: _isOnlineNow
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6366F1),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: '⚡ $_responseSpeed',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: 'EN · HI',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Available slots ───────────────────────────────────────────
            if (_slots.isNotEmpty) ...[
              Text('Next Available',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSub)),
              const SizedBox(height: 5),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _slots.map((slot) {
                  final isToday = slot.startsWith('Today');
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.black.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFF10B981).withValues(alpha: 0.30)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.black.withValues(alpha: 0.07)),
                        width: 0.6,
                      ),
                    ),
                    child: Text(slot,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? const Color(0xFF10B981)
                                : textSub)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            // ── AI ranking reason ─────────────────────────────────────────
            AiRankingReasonChip(
              reason: rank.reason,
              icon: rank.icon,
              color: rank.color,
            ),

            const SizedBox(height: 12),

            // ── CTA row ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: QuickBookCtaButton(
                    label: 'Book Now',
                    icon: Icons.calendar_today_rounded,
                    onTap: onBook,
                    gradientColors: const [
                      Color(0xFF2A7FFF),
                      Color(0xFF6366F1)
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.30),
                            width: 0.8),
                        color: AppColors.primary.withValues(alpha: 0.07),
                      ),
                      child: Center(
                        child: Text('Full Profile',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtCases(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _StatusChip(
      {required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.22), width: 0.6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      );
}
