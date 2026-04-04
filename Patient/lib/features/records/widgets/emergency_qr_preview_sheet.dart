import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Emergency QR preview bottom sheet — shows scannable emergency-safe
/// mini profile: blood group, allergies, conditions, emergency contact,
/// recent medicines. No login needed for scanner. Pure UI widget.
class EmergencyQrPreviewSheet extends StatelessWidget {
  final Map<String, dynamic> userData;
  final List<dynamic> allergies;
  final List<dynamic> conditions;
  final String? emergencyContact;
  final List<String> recentMedicines;

  const EmergencyQrPreviewSheet({
    super.key,
    required this.userData,
    this.allergies = const [],
    this.conditions = const [],
    this.emergencyContact,
    this.recentMedicines = const [],
  });

  static Future<void> show(BuildContext context, {
    required Map<String, dynamic> userData,
    List<dynamic> allergies = const [],
    List<dynamic> conditions = const [],
    String? emergencyContact,
    List<String> recentMedicines = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmergencyQrPreviewSheet(
        userData: userData,
        allergies: allergies,
        conditions: conditions,
        emergencyContact: emergencyContact,
        recentMedicines: recentMedicines,
      ),
    );
  }

  /// Build emergency QR data in MEDCARD format for doctor portal compatibility.
  String _buildEmergencyQrData(String healthId) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      // 30-minute expiry for emergency QR
      final expiry = DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch;
      return 'MEDCARD::$userId::$expiry';
    }
    // Fallback to legacy format
    return 'medassist://emergency/$healthId';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;
    final healthId = userData['healthId']?.toString() ?? 'MD-XXXXXXXX';
    final name = userData['name']?.toString() ?? 'MedAssist User';
    final bloodGroup = userData['bloodGroup']?.toString() ?? 'N/A';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.92),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.20)
                      : Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Emergency header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.30),
                      width: 0.7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emergency_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    SizedBox(width: 6),
                    Text('Emergency Quick Access',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // QR code
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _buildEmergencyQrData(healthId),
                  version: QrVersions.auto,
                  size: 160,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F172A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Scan for emergency info',
                  style: TextStyle(fontSize: 11, color: textSub)),
              const SizedBox(height: 16),

              // Emergency info grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      width: 0.6),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.person_rounded,
                        label: 'Name',
                        value: name,
                        color: const Color(0xFF3B82F6)),
                    _InfoRow(
                        icon: Icons.water_drop_rounded,
                        label: 'Blood Group',
                        value: bloodGroup,
                        color: const Color(0xFFEF4444)),
                    if (allergies.isNotEmpty)
                      _InfoRow(
                          icon: Icons.warning_amber_rounded,
                          label: 'Allergies',
                          value: allergies.join(', '),
                          color: const Color(0xFFF97316)),
                    if (conditions.isNotEmpty)
                      _InfoRow(
                          icon: Icons.medical_information_rounded,
                          label: 'Conditions',
                          value: conditions.join(', '),
                          color: const Color(0xFF8B5CF6)),
                    if (emergencyContact != null &&
                        emergencyContact!.isNotEmpty)
                      _InfoRow(
                          icon: Icons.phone_rounded,
                          label: 'Emergency Contact',
                          value: emergencyContact!,
                          color: const Color(0xFF10B981)),
                    if (recentMedicines.isNotEmpty)
                      _InfoRow(
                          icon: Icons.medication_rounded,
                          label: 'Medications',
                          value: recentMedicines.join(', '),
                          color: const Color(0xFF0EA5E9)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? Colors.white : AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
