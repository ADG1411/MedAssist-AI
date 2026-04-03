import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class AiDoctorMatchHero extends StatelessWidget {
  final String aiSpecialty;
  final VoidCallback? onApply;

  const AiDoctorMatchHero({
    super.key,
    required this.aiSpecialty,
    this.onApply,
  });

  static const _specialtyMeta = <String, _SpecialtyMeta>{
    'Gastroenterology': _SpecialtyMeta(
      emoji: '🫃',
      confidence: 94,
      reason:
          'Your gastritis risk score and spicy food trigger history strongly align with Gastroenterology.',
      urgency: 'Medium',
      symptoms: ['Acid reflux', 'Abdominal pain', 'Food triggers'],
    ),
    'Cardiology': _SpecialtyMeta(
      emoji: '❤️',
      confidence: 88,
      reason:
          'Elevated resting heart rate pattern and reported chest discomfort suggest cardiology review.',
      urgency: 'High',
      symptoms: ['Chest tightness', 'Irregular HR', 'Fatigue'],
    ),
    'Dermatology': _SpecialtyMeta(
      emoji: '🧴',
      confidence: 81,
      reason:
          'Recurring skin sensitivity patterns detected in your symptom history.',
      urgency: 'Low',
      symptoms: ['Skin irritation', 'Rash patterns', 'Sensitivity'],
    ),
    'Neurology': _SpecialtyMeta(
      emoji: '🧠',
      confidence: 85,
      reason:
          'Recurring migraine triggers identified — neurological consultation recommended.',
      urgency: 'Medium',
      symptoms: ['Migraines', 'Dizziness', 'Sleep disruption'],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _specialtyMeta[aiSpecialty] ??
        _SpecialtyMeta(
          emoji: '🏥',
          confidence: 80,
          reason: 'Based on your symptom history, this specialty is recommended.',
          urgency: 'Medium',
          symptoms: ['Reviewed symptoms', 'Health history'],
        );

    final urgencyColor = meta.urgency == 'High'
        ? const Color(0xFFEF4444)
        : meta.urgency == 'Medium'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub =
        isDark ? Colors.white.withValues(alpha: 0.55) : AppColors.textSecondary;

    return GlassCard(
      radius: 24,
      blur: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: AI badge + urgency
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 11, color: Colors.white),
                    SizedBox(width: 4),
                    Text('AI Doctor Match',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: urgencyColor.withValues(alpha: 0.30), width: 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: urgencyColor),
                    ),
                    const SizedBox(width: 5),
                    Text('${meta.urgency} Priority',
                        style: TextStyle(
                            fontSize: 10,
                            color: urgencyColor,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Text('${meta.confidence}% match',
                  style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6366F1),
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),

          // Specialty row
          Row(
            children: [
              Text(meta.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aiSpecialty,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text('Recommended Specialization',
                        style: TextStyle(fontSize: 11, color: textSub)),
                  ],
                ),
              ),
              // Confidence arc
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: meta.confidence / 100,
                      strokeWidth: 4.5,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.09)
                          : Colors.black.withValues(alpha: 0.06),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF6366F1)),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text('${meta.confidence}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6366F1))),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // AI reason box
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                  width: 0.6),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 14, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    meta.reason,
                    style: TextStyle(
                        fontSize: 12, color: textPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Symptom → specialty trail
          Row(
            children: [
              ...meta.symptoms.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s,
                          style: TextStyle(fontSize: 10, color: textSub)),
                    ),
                  )),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded,
                  size: 12, color: const Color(0xFF6366F1)),
              const SizedBox(width: 4),
              Text(aiSpecialty,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),

          // CTA
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onApply,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: Text('Show $aiSpecialty Doctors',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                        width: 0.7),
                  ),
                  child: const Center(
                    child: Text('Why this?',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecialtyMeta {
  final String emoji;
  final int confidence;
  final String reason;
  final String urgency;
  final List<String> symptoms;
  const _SpecialtyMeta({
    required this.emoji,
    required this.confidence,
    required this.reason,
    required this.urgency,
    required this.symptoms,
  });
}
