import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import 'ai_ranking_reason_chip.dart';
import 'quick_book_cta_button.dart';

class DoctorProfilePreviewSheet extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final String? aiSpecialty;
  final VoidCallback? onBook;

  const DoctorProfilePreviewSheet({
    super.key,
    required this.doctor,
    this.aiSpecialty,
    this.onBook,
  });

  static void show(
    BuildContext context, {
    required Map<String, dynamic> doctor,
    String? aiSpecialty,
    VoidCallback? onBook,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DoctorProfilePreviewSheet(
        doctor: doctor,
        aiSpecialty: aiSpecialty,
        onBook: onBook,
      ),
    );
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

  int get _aiMatchPct {
    final specialty = doctor['specialty']?.toString() ?? '';
    if (aiSpecialty != null &&
        specialty.toLowerCase() == aiSpecialty!.toLowerCase()) { return 94; }
    final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
    return ((rating - 3.5) / 1.5 * 55 + 62).clamp(62, 91).toInt();
  }

  int get _casesHandled {
    final exp = (doctor['experience'] as num?)?.toInt() ?? 5;
    final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
    return (exp * 118 + (rating * 42).toInt()).clamp(200, 9999);
  }

  static const _conditionsBySpecialty = <String, List<String>>{
    'Gastroenterology':  ['GERD', 'IBS', 'Gastritis', 'Crohn\'s Disease', 'Liver disorders'],
    'Cardiology':        ['Hypertension', 'Coronary artery disease', 'Heart failure', 'Arrhythmia'],
    'General Practice':  ['Diabetes management', 'Preventive care', 'Infections', 'Wellness'],
    'Dermatology':       ['Acne', 'Eczema', 'Psoriasis', 'Skin cancer screening'],
    'Neurology':         ['Migraine', 'Epilepsy', 'Neuropathy', 'Sleep disorders'],
    'Orthopedic':        ['Joint replacement', 'Fractures', 'Sports injuries', 'Arthritis'],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name     = doctor['name']?.toString() ?? 'Doctor';
    final specialty = doctor['specialty']?.toString() ?? '';
    final experience = (doctor['experience'] as num?)?.toInt() ?? 0;
    final rating   = (doctor['rating'] as num?)?.toDouble() ?? 0.0;
    final fee      = (doctor['consultation_fee'] as num?)?.toInt() ?? 0;
    final bio      = doctor['bio']?.toString() ?? '';
    final slots    = (doctor['available_slots'] as List? ?? []).map((e) => e.toString()).toList();
    final conditions = _conditionsBySpecialty[specialty] ?? ['General consultation'];
    final initials = name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
    final rank = aiRankingReason(doctor, aiSpecialty);

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? Colors.white.withValues(alpha: 0.50) : AppColors.textSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.50,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.22), blurRadius: 40),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.58)
                  : Colors.white.withValues(alpha: 0.84),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 38, height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.18)
                          : Colors.black.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Scrollable body
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        // ── Doctor hero ──────────────────────────────────
                        Row(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    _specialtyColor.withValues(alpha: 0.22),
                                    _specialtyColor.withValues(alpha: 0.10),
                                  ],
                                ),
                                border: Border.all(
                                    color: _specialtyColor.withValues(alpha: 0.40),
                                    width: 2),
                              ),
                              child: Center(
                                child: Text(initials,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: _specialtyColor)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                          letterSpacing: -0.4)),
                                  const SizedBox(height: 2),
                                  Text(specialty,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: _specialtyColor,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded, size: 13,
                                          color: const Color(0xFFF59E0B)),
                                      const SizedBox(width: 3),
                                      Text('$rating',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary)),
                                      Text(' · ${experience}y exp · ₹$fee',
                                          style: TextStyle(
                                              fontSize: 11, color: textSub)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Stats row ────────────────────────────────────
                        Row(
                          children: [
                            _StatCard('$_aiMatchPct%', 'AI Match', const Color(0xFF6366F1), isDark),
                            const SizedBox(width: 8),
                            _StatCard('${_casesHandled >= 1000 ? "${(_casesHandled / 1000).toStringAsFixed(1)}k" : _casesHandled}', 'Cases', _specialtyColor, isDark),
                            const SizedBox(width: 8),
                            _StatCard('$experience yr', 'Experience', const Color(0xFF10B981), isDark),
                            const SizedBox(width: 8),
                            _StatCard('₹$fee', 'Fee', const Color(0xFFF59E0B), isDark),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── AI match reason ──────────────────────────────
                        AiRankingReasonChip(
                            reason: rank.reason,
                            icon: rank.icon,
                            color: rank.color),
                        const SizedBox(height: 14),

                        // ── About ────────────────────────────────────────
                        GlassCard(
                          radius: 18, blur: 14,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('About', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                              const SizedBox(height: 6),
                              Text(bio.isEmpty ? 'Experienced specialist with strong patient outcomes.' : bio,
                                  style: TextStyle(fontSize: 12, color: textSub, height: 1.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Top conditions ───────────────────────────────
                        GlassCard(
                          radius: 18, blur: 14,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Top Treated Conditions',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6, runSpacing: 6,
                                children: conditions.map((c) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _specialtyColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _specialtyColor.withValues(alpha: 0.22), width: 0.6),
                                  ),
                                  child: Text(c,
                                      style: TextStyle(fontSize: 11, color: _specialtyColor, fontWeight: FontWeight.w600)),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Available slots ──────────────────────────────
                        GlassCard(
                          radius: 18, blur: 14,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Available Slots',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                              const SizedBox(height: 8),
                              slots.isEmpty
                                  ? Text('No slots available',
                                      style: TextStyle(fontSize: 12, color: AppColors.danger))
                                  : Wrap(
                                      spacing: 8, runSpacing: 8,
                                      children: slots.map((slot) {
                                        final isToday = slot.startsWith('Today');
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isToday
                                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                                : (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.04)),
                                            borderRadius: BorderRadius.circular(9),
                                            border: Border.all(
                                              color: isToday
                                                  ? const Color(0xFF10B981).withValues(alpha: 0.35)
                                                  : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.07)),
                                              width: 0.7,
                                            ),
                                          ),
                                          child: Text(slot,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isToday ? const Color(0xFF10B981) : textSub)),
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Consultation types ───────────────────────────
                        GlassCard(
                          radius: 18, blur: 14,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              _ConsultType('Video', Icons.videocam_rounded, const Color(0xFF6366F1), isDark),
                              const SizedBox(width: 10),
                              _ConsultType('In-Person', Icons.local_hospital_rounded, const Color(0xFF10B981), isDark),
                              const SizedBox(width: 10),
                              _ConsultType('Emergency', Icons.emergency_rounded, const Color(0xFFEF4444), isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── CTA ──────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: QuickBookCtaButton(
                                label: 'Pay ₹$fee & Book',
                                icon: Icons.lock_rounded,
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/doctor-detail', extra: doctor);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/doctor-detail', extra: doctor);
                                },
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.30), width: 0.8),
                                    color: AppColors.primary.withValues(alpha: 0.07),
                                  ),
                                  child: Center(
                                    child: Text('Full Profile',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  const _StatCard(this.value, this.label, this.color, this.isDark);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.20), width: 0.6),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.50)
                          : AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _ConsultType extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _ConsultType(this.label, this.icon, this.color, this.isDark);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.22), width: 0.6),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      );
}
