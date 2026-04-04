import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Apple Wallet-grade premium medical identity card with QR, profile,
/// blood group, allergies, conditions, emergency contact.
/// Reads from existing auth state. Pure UI widget.
class PremiumHealthIdCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final List<dynamic> allergies;
  final List<dynamic> conditions;

  const PremiumHealthIdCard({
    super.key,
    required this.userData,
    this.allergies = const [],
    this.conditions = const [],
  });

  /// Build QR data: MEDCARD::<full_uuid>::<expiry_timestamp>
  /// This format is compatible with the Doctor Portal's QR scanner.
  String _buildQrData() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final expiry = DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch;
      return 'MEDCARD::$userId::$expiry';
    }
    // Fallback to health ID if not authenticated
    return userData['healthId']?.toString() ?? 'MD-XXXXXXXX';
  }

  @override
  Widget build(BuildContext context) {
    final name = userData['name']?.toString() ?? 'MedAssist User';
    final healthId = userData['healthId']?.toString() ?? 'MD-XXXXXXXX';
    final bloodGroup = userData['bloodGroup']?.toString() ?? 'N/A';
    final dob = userData['dob']?.toString() ?? 'Not Set';
    final gender = userData['gender']?.toString() ?? 'Not Set';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF0F172A)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Subtle pattern overlay
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: brand + QR
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFF0EA5E9),
                                      Color(0xFF6366F1)
                                    ]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.local_hospital_rounded,
                                      size: 14, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('MEDASSIST',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF0EA5E9),
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5)),
                                    Text('Digital Health ID',
                                        style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white54,
                                            letterSpacing: 0.5)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Name
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 4),
                            Text('ID: $healthId',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                    fontFamily: 'monospace',
                                    letterSpacing: 0.8)),
                          ],
                        ),
                      ),

                      // QR
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9)
                                  .withValues(alpha: 0.25),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _buildQrData(),
                          version: QrVersions.auto,
                          size: 72,
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 0.5,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  const SizedBox(height: 16),

                  // Data points row
                  Row(
                    children: [
                      _DataPoint(label: 'BLOOD', value: bloodGroup,
                          color: const Color(0xFFEF4444)),
                      const SizedBox(width: 20),
                      _DataPoint(label: 'DOB', value: dob,
                          color: const Color(0xFF0EA5E9)),
                      const SizedBox(width: 20),
                      _DataPoint(label: 'GENDER', value: gender,
                          color: const Color(0xFF8B5CF6)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Allergies
                  if (allergies.isNotEmpty) ...[
                    const Text('ALLERGIES',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: allergies.map((a) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.30),
                                  width: 0.6),
                            ),
                            child: Text(a.toString(),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600)),
                          )).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Chronic conditions
                  if (conditions.isNotEmpty) ...[
                    const Text('CONDITIONS',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: conditions.map((c) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFF97316)
                                      .withValues(alpha: 0.30),
                                  width: 0.6),
                            ),
                            child: Text(c.toString(),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFF97316),
                                    fontWeight: FontWeight.w600)),
                          )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataPoint extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DataPoint({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                color: Colors.white38,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color)),
      ],
    );
  }
}
