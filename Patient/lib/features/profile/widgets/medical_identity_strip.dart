import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Health passport summary strip — scrollable stat chips for age, gender,
/// height, weight, BMI, blood group, allergies, conditions, insurance,
/// emergency contact. Critical values visually pop. Pure UI widget.
class MedicalIdentityStrip extends StatelessWidget {
  final Map<String, dynamic> profile;

  const MedicalIdentityStrip({super.key, required this.profile});

  double? _bmi() {
    final h = double.tryParse(profile['height_cm']?.toString() ?? '');
    final w = double.tryParse(profile['weight_kg']?.toString() ?? '');
    if (h == null || w == null || h <= 0) return null;
    return w / ((h / 100) * (h / 100));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;

    final age = profile['age']?.toString() ?? '-';
    final gender = profile['gender']?.toString() ?? '-';
    final height = profile['height_cm']?.toString() ?? '-';
    final weight = profile['weight_kg']?.toString() ?? '-';
    final bloodGroup =
        profile['blood_group']?.toString() ?? profile['bloodGroup']?.toString() ?? '-';
    final bmi = _bmi();
    final allergies = (profile['allergies'] as List?)?.cast<String>() ?? [];
    final conditions = (profile['chronic_conditions'] as List?)?.cast<String>() ??
        (profile['chronicConditions'] as List?)?.cast<String>() ?? [];
    final insurance = profile['insurance']?.toString() ?? '';
    final emergencyContacts =
        (profile['emergency_contacts'] as List?) ?? [];

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Medical Identity',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textPrimary)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.22),
                      width: 0.6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 10, color: Color(0xFF0EA5E9)),
                    SizedBox(width: 3),
                    Text('Health Passport',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stat chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatChip(label: 'Age', value: age, icon: Icons.cake_rounded,
                    color: const Color(0xFF3B82F6)),
                _StatChip(label: 'Gender', value: gender, icon: Icons.person_rounded,
                    color: const Color(0xFF8B5CF6)),
                _StatChip(label: 'Height', value: '$height cm', icon: Icons.height_rounded,
                    color: const Color(0xFF0EA5E9)),
                _StatChip(label: 'Weight', value: '$weight kg', icon: Icons.monitor_weight_rounded,
                    color: const Color(0xFF10B981)),
                if (bmi != null)
                  _StatChip(label: 'BMI', value: bmi.toStringAsFixed(1),
                      icon: Icons.speed_rounded,
                      color: bmi < 18.5 || bmi > 30
                          ? const Color(0xFFEF4444)
                          : bmi > 25
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981)),
                // Critical: blood group
                _StatChip(label: 'Blood', value: bloodGroup,
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFFEF4444), isCritical: true),
              ],
            ),
          ),

          // Allergies
          if (allergies.isNotEmpty) ...[
            const SizedBox(height: 10),
            _CriticalTagRow(
              label: 'Allergies',
              tags: allergies,
              color: const Color(0xFFF97316),
              icon: Icons.warning_amber_rounded,
            ),
          ],

          // Chronic conditions
          if (conditions.isNotEmpty) ...[
            const SizedBox(height: 6),
            _CriticalTagRow(
              label: 'Conditions',
              tags: conditions,
              color: const Color(0xFFEF4444),
              icon: Icons.medical_information_rounded,
            ),
          ],

          // Insurance
          if (insurance.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.shield_rounded,
                    size: 12, color: const Color(0xFF14B8A6)),
                const SizedBox(width: 5),
                Text('Insurance: $insurance',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF14B8A6),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],

          // Emergency contacts count
          if (emergencyContacts.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone_rounded,
                    size: 12, color: Color(0xFF10B981)),
                const SizedBox(width: 5),
                Text('${emergencyContacts.length} emergency contact(s)',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCritical;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: color.withValues(alpha: isCritical ? 0.40 : 0.20),
            width: isCritical ? 1.0 : 0.6),
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
                      fontSize: 12,
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

class _CriticalTagRow extends StatelessWidget {
  final String label;
  final List<String> tags;
  final Color color;
  final IconData icon;

  const _CriticalTagRow({
    required this.label,
    required this.tags,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 3,
            children: tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: color.withValues(alpha: 0.30), width: 0.6),
                  ),
                  child: Text(t,
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600)),
                )).toList(),
          ),
        ),
      ],
    );
  }
}
