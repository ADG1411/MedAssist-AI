import 'package:flutter/material.dart';

/// Emergency Medical Data Packet — shows what medical data was shared
/// during SOS: blood group, allergies, conditions, medications, notes,
/// vitals, insurance, QR link. Pure UI widget.
class EmergencyMedicalPacket extends StatelessWidget {
  final Map<String, dynamic> profile;
  final bool isExpanded;

  const EmergencyMedicalPacket({
    super.key,
    required this.profile,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final bloodGroup = profile['blood_group']?.toString() ??
        profile['bloodGroup']?.toString() ??
        'N/A';
    final allergies =
        (profile['allergies'] as List?)?.cast<String>() ?? [];
    final conditions =
        (profile['chronic_conditions'] as List?)?.cast<String>() ??
            (profile['chronicConditions'] as List?)?.cast<String>() ?? [];
    final medications =
        (profile['current_medications'] as List?)?.cast<String>() ?? [];
    final insurance = profile['insurance']?.toString() ?? '';
    final age = profile['age']?.toString() ?? '';
    final gender = profile['gender']?.toString() ?? '';
    final weight = profile['weight_kg']?.toString() ?? '';

    final dataItems = <_PacketItem>[
      _PacketItem(
          icon: Icons.water_drop_rounded,
          label: 'Blood Group',
          value: bloodGroup,
          color: const Color(0xFFEF4444),
          shared: bloodGroup != 'N/A'),
      _PacketItem(
          icon: Icons.warning_amber_rounded,
          label: 'Allergies',
          value: allergies.isNotEmpty ? allergies.join(', ') : 'None recorded',
          color: const Color(0xFFF97316),
          shared: allergies.isNotEmpty),
      _PacketItem(
          icon: Icons.medical_information_rounded,
          label: 'Conditions',
          value: conditions.isNotEmpty ? conditions.join(', ') : 'None',
          color: const Color(0xFF8B5CF6),
          shared: conditions.isNotEmpty),
      _PacketItem(
          icon: Icons.medication_rounded,
          label: 'Medications',
          value: medications.isNotEmpty ? medications.join(', ') : 'None',
          color: const Color(0xFF3B82F6),
          shared: medications.isNotEmpty),
      if (age.isNotEmpty)
        _PacketItem(
            icon: Icons.cake_rounded,
            label: 'Age',
            value: age,
            color: const Color(0xFF0EA5E9),
            shared: true),
      if (gender.isNotEmpty && gender != '-')
        _PacketItem(
            icon: Icons.person_rounded,
            label: 'Gender',
            value: gender,
            color: const Color(0xFF6366F1),
            shared: true),
      if (weight.isNotEmpty && weight != '-')
        _PacketItem(
            icon: Icons.monitor_weight_rounded,
            label: 'Weight',
            value: '$weight kg',
            color: const Color(0xFF10B981),
            shared: true),
      if (insurance.isNotEmpty)
        _PacketItem(
            icon: Icons.shield_rounded,
            label: 'Insurance',
            value: insurance,
            color: const Color(0xFF14B8A6),
            shared: true),
    ];

    final sharedCount = dataItems.where((i) => i.shared).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.12), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 11, color: Color(0xFF34D399)),
                    SizedBox(width: 3),
                    Text('Medical Data Shared',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF34D399),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Text('$sharedCount items sent',
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.40),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),

          // Data items
          ...dataItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(item.icon, size: 12, color: item.color),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: Text(item.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Text(item.value,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                    Icon(
                      item.shared
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_outline_rounded,
                      size: 12,
                      color: item.shared
                          ? const Color(0xFF10B981)
                          : Colors.white.withValues(alpha: 0.20),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PacketItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool shared;

  const _PacketItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.shared,
  });
}
