import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import 'quick_book_cta_button.dart';

class EarliestSafeSlotPanel extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  final String urgency;
  final VoidCallback? onBookEarliest;

  const EarliestSafeSlotPanel({
    super.key,
    required this.doctors,
    this.urgency = 'Medium',
    this.onBookEarliest,
  });

  @override
  State<EarliestSafeSlotPanel> createState() => _EarliestSafeSlotPanelState();
}

class _EarliestSafeSlotPanelState extends State<EarliestSafeSlotPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _getEarliestSlot() {
    for (final doc in widget.doctors) {
      final slots = doc['available_slots'] as List? ?? [];
      for (final s in slots) {
        if (s.toString().startsWith('Today')) return s.toString();
      }
    }
    for (final doc in widget.doctors) {
      final slots = doc['available_slots'] as List? ?? [];
      if (slots.isNotEmpty) return slots.first.toString();
    }
    return 'No slots available';
  }

  String _getEarliestDoctorName() {
    for (final doc in widget.doctors) {
      final slots = doc['available_slots'] as List? ?? [];
      if (slots.any((s) => s.toString().startsWith('Today'))) {
        return doc['name']?.toString() ?? 'Doctor';
      }
    }
    if (widget.doctors.isNotEmpty) {
      return widget.doctors.first['name']?.toString() ?? 'Doctor';
    }
    return 'Doctor';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHigh = widget.urgency == 'High';
    final urgencyColor =
        isHigh ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final timeframe = isHigh ? '2 hours' : '6 hours';
    final earliest = _getEarliestSlot();
    final docName = _getEarliestDoctorName();
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.55) : AppColors.textSecondary;

    return GlassCard(
      radius: 20,
      blur: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Pulsing dot
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: urgencyColor,
                    boxShadow: [
                      BoxShadow(
                          color: urgencyColor.withValues(alpha: 0.55),
                          blurRadius: 8,
                          spreadRadius: 1),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('Earliest Safe Consultation',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isHigh ? 'Urgent' : 'Recommended',
                  style: TextStyle(
                      fontSize: 10,
                      color: urgencyColor,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recommended within $timeframe based on ${widget.urgency.toLowerCase()} risk symptoms',
            style: TextStyle(fontSize: 12, color: textSub, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Slot info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 13, color: urgencyColor),
                        const SizedBox(width: 5),
                        Text(earliest,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: urgencyColor)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('with $docName',
                        style: TextStyle(fontSize: 11, color: textSub)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              QuickBookCtaButton(
                label: 'Book Now',
                icon: Icons.flash_on_rounded,
                onTap: widget.onBookEarliest,
                gradientColors: [urgencyColor, urgencyColor.withValues(alpha: 0.75)],
                height: 38,
                fontSize: 12,
              ),
            ],
          ),
          if (isHigh) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                    width: 0.6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 13, color: Color(0xFFEF4444)),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'Delay may escalate risk. Book the earliest available slot.',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.80)
                              : AppColors.textPrimary,
                          height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
