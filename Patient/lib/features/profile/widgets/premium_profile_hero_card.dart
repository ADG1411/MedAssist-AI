import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Medical Identity Hero Card — avatar, name, email, MedAssist ID,
/// profile completion %, AI accuracy score, emergency readiness badge.
/// Reads from existing profileProvider data. Pure UI widget.
class PremiumProfileHeroCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback? onEdit;

  const PremiumProfileHeroCard({
    super.key,
    required this.profile,
    this.onEdit,
  });

  int _completionPercent() {
    int filled = 0;
    const fields = [
      'name', 'email', 'phone', 'blood_group', 'bloodGroup',
      'age', 'gender', 'height_cm', 'weight_kg',
      'allergies', 'chronic_conditions', 'chronicConditions',
      'emergency_contacts',
    ];
    for (final f in fields) {
      final v = profile[f];
      if (v != null && v.toString().isNotEmpty && v != '-') {
        if (v is List && v.isEmpty) continue;
        filled++;
      }
    }
    return ((filled / fields.length) * 100).round().clamp(0, 100);
  }

  int _aiAccuracy() {
    // Heuristic: more complete profile → higher AI accuracy
    final base = 60;
    final bonus = (_completionPercent() * 0.35).round();
    return (base + bonus).clamp(0, 99);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final name = profile['name']?.toString() ?? 'Guest';
    final email = profile['email']?.toString() ?? '';
    final phone = profile['phone']?.toString() ?? '';
    final id = profile['id']?.toString() ?? 'anon';
    final healthId = 'MD-${id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}';
    final completion = _completionPercent();
    final aiAcc = _aiAccuracy();
    final hasEmergencyData = (profile['emergency_contacts'] as List?)?.isNotEmpty == true ||
        (profile['blood_group'] ?? profile['bloodGroup']) != null;

    return GlassCard(
      radius: 22,
      blur: 16,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'G',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Identity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.3)),
                    if (email.isNotEmpty)
                      Text(email,
                          style: TextStyle(fontSize: 11, color: textSub)),
                    if (phone.isNotEmpty)
                      Text(phone,
                          style: TextStyle(fontSize: 11, color: textSub)),
                    const SizedBox(height: 4),
                    Text(healthId,
                        style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            letterSpacing: 0.8)),
                  ],
                ),
              ),

              // Edit button
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.09)
                          : Colors.white.withValues(alpha: 0.72),
                      border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.06),
                          width: 0.7),
                    ),
                    child: Icon(Icons.edit_rounded,
                        size: 14,
                        color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              // Profile completion
              Expanded(
                child: _MiniStat(
                  label: 'Profile',
                  value: '$completion%',
                  color: completion >= 80
                      ? const Color(0xFF10B981)
                      : completion >= 50
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444),
                  progress: completion / 100,
                ),
              ),
              const SizedBox(width: 8),
              // AI accuracy
              Expanded(
                child: _MiniStat(
                  label: 'AI Accuracy',
                  value: '$aiAcc%',
                  color: const Color(0xFF6366F1),
                  progress: aiAcc / 100,
                ),
              ),
              const SizedBox(width: 8),
              // Emergency readiness
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (hasEmergencyData
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: (hasEmergencyData
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.22),
                      width: 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasEmergencyData
                          ? Icons.verified_rounded
                          : Icons.warning_amber_rounded,
                      size: 13,
                      color: hasEmergencyData
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasEmergencyData ? 'SOS Ready' : 'SOS Incomplete',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: hasEmergencyData
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double progress;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 2.5,
              backgroundColor: color.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
