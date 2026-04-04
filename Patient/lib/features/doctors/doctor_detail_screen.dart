// Doctor Detail Screen — premium minimalist redesign.
// All booking logic is fully preserved from the original.
// Real data: photo_url, video_fee/in-person fee, bio, slots, rating, experience.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import 'providers/booking_provider.dart';

// Specialty → color palette
const _specColors = <String, Color>{
  'Cardiology':       Color(0xFFEF4444),
  'Gastroenterology': Color(0xFF10B981),
  'General Practice': Color(0xFF6366F1),
  'Dermatology':      Color(0xFFF59E0B),
  'Neurology':        Color(0xFF8B5CF6),
  'Orthopedic':       Color(0xFF06B6D4),
};

class DoctorDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingState = ref.watch(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);

    final name       = doctor['name']?.toString() ?? 'Doctor';
    final specialty  = doctor['specialty']?.toString() ?? 'General Practice';
    final rating     = (doctor['rating'] as num?)?.toDouble() ?? 4.5;
    final experience = (doctor['experience'] as num?)?.toInt() ?? 0;
    final bio        = doctor['bio']?.toString() ?? '';
    final photoUrl   = doctor['photo_url']?.toString();
    final videoFee   = (doctor['video_fee'] as num?)?.toInt()
                    ?? (doctor['consultation_fee'] as num?)?.toInt()
                    ?? 500;
    final inPersonFee = (doctor['in_person_fee'] as num?)?.toInt() ?? videoFee;
    final slots      = List<String>.from(doctor['available_slots'] ?? []);
    final isVerified = doctor['verification_status']?.toString() == 'verified';
    final specColor  = _specColors[specialty] ?? AppColors.primary;
    final initials   = name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero SliverAppBar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroBanner(
                    name: name,
                    specialty: specialty,
                    initials: initials,
                    photoUrl: photoUrl,
                    specColor: specColor,
                    isVerified: isVerified,
                    rating: rating,
                    experience: experience,
                    videoFee: videoFee,
                    isDark: isDark,
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stats row ─────────────────────────────────
                      _StatsRow(
                        rating: rating,
                        experience: experience,
                        videoFee: videoFee,
                        inPersonFee: inPersonFee,
                        isDark: isDark,
                        specColor: specColor,
                      ),
                      const SizedBox(height: 16),

                      // ── About ─────────────────────────────────────
                      if (bio.isNotEmpty) ...[
                        _SectionHeader('About', isDark),
                        const SizedBox(height: 8),
                        _BioCard(bio: bio, isDark: isDark),
                        const SizedBox(height: 16),
                      ],

                      // ── Fee selector ──────────────────────────────
                      _SectionHeader('Consultation Type', isDark),
                      const SizedBox(height: 8),
                      _FeeSelector(
                        videoFee: videoFee,
                        inPersonFee: inPersonFee,
                        isDark: isDark,
                        specColor: specColor,
                        selected: bookingState.consultationType ?? 'video',
                        onSelect: (type) =>
                            notifier.setConsultationType(type),
                      ),
                      const SizedBox(height: 16),

                      // ── Slots ─────────────────────────────────────
                      _SectionHeader('Available Slots', isDark),
                      const SizedBox(height: 8),
                      _SlotPicker(
                        slots: slots,
                        selected: bookingState.selectedSlot,
                        isLocked: bookingState.isPaymentSuccess,
                        onSelect: notifier.selectSlot,
                        isDark: isDark,
                        specColor: specColor,
                      ),

                      // ── Error ─────────────────────────────────────
                      if (bookingState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(message: bookingState.errorMessage!),
                      ],

                      // ── Payment success ───────────────────────────
                      if (bookingState.isPaymentSuccess) ...[
                        const SizedBox(height: 16),
                        _SuccessBanner(
                          doctorName: name,
                          roomId: bookingState.jitsiRoomId,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom CTA (preserved booking logic) ─────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCta(
              bookingState: bookingState,
              notifier: notifier,
              doctor: doctor,
              videoFee: videoFee,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String name, specialty, initials;
  final String? photoUrl;
  final Color specColor;
  final bool isVerified, isDark;
  final double rating;
  final int experience, videoFee;

  const _HeroBanner({
    required this.name,
    required this.specialty,
    required this.initials,
    this.photoUrl,
    required this.specColor,
    required this.isVerified,
    required this.rating,
    required this.experience,
    required this.videoFee,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                specColor.withValues(alpha: 0.85),
                specColor.withValues(alpha: 0.40),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Content
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: specColor.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _InitialsWidget(
                            initials: initials,
                            specColor: specColor,
                          ),
                        )
                      : _InitialsWidget(
                          initials: initials,
                          specColor: specColor,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + specialty + verified
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 10, color: Colors.white),
                                SizedBox(width: 3),
                                Text('Verified',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Blur fade at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 40,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      (isDark
                              ? const Color(0xFF0A0F1E)
                              : const Color(0xFFF8FAFF))
                          .withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsWidget extends StatelessWidget {
  final String initials;
  final Color specColor;
  const _InitialsWidget({required this.initials, required this.specColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: specColor.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: specColor,
          ),
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final double rating;
  final int experience, videoFee, inPersonFee;
  final bool isDark;
  final Color specColor;

  const _StatsRow({
    required this.rating,
    required this.experience,
    required this.videoFee,
    required this.inPersonFee,
    required this.isDark,
    required this.specColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.90);

    return Row(
      children: [
        _StatChip(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFF59E0B),
          value: rating.toStringAsFixed(1),
          label: 'Rating',
          isDark: isDark,
          cardBg: cardBg,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.work_history_rounded,
          iconColor: specColor,
          value: '${experience}y',
          label: 'Experience',
          isDark: isDark,
          cardBg: cardBg,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.videocam_rounded,
          iconColor: const Color(0xFF10B981),
          value: '₹$videoFee',
          label: 'Video',
          isDark: isDark,
          cardBg: cardBg,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.local_hospital_rounded,
          iconColor: const Color(0xFF6366F1),
          value: '₹$inPersonFee',
          label: 'In-Person',
          isDark: isDark,
          cardBg: cardBg,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value, label;
  final bool isDark;
  final Color cardBg;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.40)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader(this.title, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ── Bio Card ──────────────────────────────────────────────────────────────────

class _BioCard extends StatefulWidget {
  final String bio;
  final bool isDark;
  const _BioCard({required this.bio, required this.isDark});

  @override
  State<_BioCard> createState() => _BioCardState();
}

class _BioCardState extends State<_BioCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.90);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.bio,
            maxLines: _expanded ? 999 : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.70)
                  : AppColors.textSecondary,
            ),
          ),
          if (widget.bio.length > 120) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Show less' : 'Read more',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Fee Selector ──────────────────────────────────────────────────────────────

class _FeeSelector extends StatelessWidget {
  final int videoFee, inPersonFee;
  final bool isDark;
  final Color specColor;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FeeSelector({
    required this.videoFee,
    required this.inPersonFee,
    required this.isDark,
    required this.specColor,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FeeOption(
          type: 'video',
          icon: Icons.videocam_rounded,
          label: 'Video Call',
          fee: videoFee,
          isSelected: selected == 'video',
          specColor: specColor,
          isDark: isDark,
          onTap: () => onSelect('video'),
        ),
        const SizedBox(width: 10),
        _FeeOption(
          type: 'inperson',
          icon: Icons.local_hospital_rounded,
          label: 'In-Person',
          fee: inPersonFee,
          isSelected: selected == 'inperson',
          specColor: const Color(0xFF6366F1),
          isDark: isDark,
          onTap: () => onSelect('inperson'),
        ),
      ],
    );
  }
}

class _FeeOption extends StatelessWidget {
  final String type, label;
  final IconData icon;
  final int fee;
  final bool isSelected, isDark;
  final Color specColor;
  final VoidCallback onTap;

  const _FeeOption({
    required this.type,
    required this.icon,
    required this.label,
    required this.fee,
    required this.isSelected,
    required this.isDark,
    required this.specColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? specColor.withValues(alpha: isDark ? 0.18 : 0.10)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.80)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? specColor.withValues(alpha: 0.55)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05)),
              width: isSelected ? 1.5 : 0.7,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected
                      ? specColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.40)
                          : AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? specColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : AppColors.textSecondary),
                ),
              ),
              Text(
                '₹$fee',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? specColor
                      : (isDark ? Colors.white : AppColors.textPrimary),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Slot Picker ───────────────────────────────────────────────────────────────

class _SlotPicker extends StatelessWidget {
  final List<String> slots;
  final String? selected;
  final bool isLocked, isDark;
  final Color specColor;
  final ValueChanged<String> onSelect;

  const _SlotPicker({
    required this.slots,
    this.selected,
    required this.isLocked,
    required this.isDark,
    required this.specColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text('Schedule available on request',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.50)
                        : AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isSelected = selected == slot;
        final isToday = slot.toLowerCase().startsWith('today');

        return GestureDetector(
          onTap: isLocked ? null : () {
            HapticFeedback.lightImpact();
            onSelect(slot);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? specColor
                  : isToday
                      ? const Color(0xFF10B981).withValues(alpha: 0.10)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.90)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? specColor
                    : isToday
                        ? const Color(0xFF10B981).withValues(alpha: 0.40)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.09)
                            : Colors.black.withValues(alpha: 0.06)),
                width: isSelected ? 0 : 0.7,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: specColor.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isToday
                      ? Icons.flash_on_rounded
                      : Icons.access_time_rounded,
                  size: 13,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? const Color(0xFF10B981)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : AppColors.textSecondary),
                ),
                const SizedBox(width: 5),
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFF10B981)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.70)
                                : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Error/Success Banners ─────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.25),
            width: 0.7),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Color(0xFFEF4444), fontSize: 12))),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String doctorName;
  final String? roomId;
  const _SuccessBanner({required this.doctorName, this.roomId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 40, color: Color(0xFF10B981)),
          const SizedBox(height: 10),
          const Text(
            'Booking Confirmed!',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 6),
          Text(
            'Your consultation with $doctorName is confirmed.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF10B981).withValues(alpha: 0.80)),
          ),
          if (roomId != null) ...[
            const SizedBox(height: 4),
            Text('Room: $roomId',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final bookingState;
  final notifier;
  final Map<String, dynamic> doctor;
  final int videoFee;
  final bool isDark;

  const _BottomCta({
    required this.bookingState,
    required this.notifier,
    required this.doctor,
    required this.videoFee,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFee = bookingState.consultationType == 'inperson'
        ? ((doctor['in_person_fee'] as num?)?.toInt() ?? videoFee)
        : videoFee;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.75),
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.paddingOf(context).bottom + 12),
          child: bookingState.isPaymentSuccess
              ? _GradientButton(
                  label: bookingState.isGeneratingHandoff
                      ? 'Preparing Consultation…'
                      : '🎥  Join Video Consultation',
                  isLoading: bookingState.isGeneratingHandoff as bool,
                  onTap: bookingState.isGeneratingHandoff
                      ? null
                      : () => context.push('/consultation', extra: {
                            'bookingId':
                                bookingState.bookingId ?? 'unknown',
                            'doctorName':
                                doctor['name'] ?? 'Doctor',
                            'jitsiRoom':
                                bookingState.jitsiRoomId ??
                                    'medassist_fallback',
                          }),
                )
              : _GradientButton(
                  label: bookingState.isProcessingPayment as bool
                      ? 'Processing…'
                      : 'Pay ₹$selectedFee  &  Book',
                  isLoading: bookingState.isProcessingPayment as bool,
                  onTap:
                      bookingState.selectedSlot == null ||
                              (bookingState.isProcessingPayment as bool)
                          ? null
                          : () => notifier.initiatePayment(
                                doctor['id'],
                                selectedFee,
                                doctorName: doctor['name'],
                                doctorSpecialty: doctor['specialty'],
                              ),
                ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.mediumImpact();
              onTap!();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: onTap == null
                ? [const Color(0xFF6B7280), const Color(0xFF4B5563)]
                : [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
      ),
    );
  }
}
