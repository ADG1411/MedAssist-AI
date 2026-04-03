import 'package:flutter/material.dart';

/// Live Rescue Location Card — shows current coordinates, resolved address,
/// nearest hospital ETA, GPS accuracy, network status. Pure UI widget.
class RescueLocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? nearestHospital;
  final String? hospitalEta;
  final double? gpsAccuracy;
  final bool isOnline;

  const RescueLocationCard({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    this.nearestHospital,
    this.hospitalEta,
    this.gpsAccuracy,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 11, color: Color(0xFF60A5FA)),
                    SizedBox(width: 3),
                    Text('Live Location',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF60A5FA),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              // Network badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      size: 9,
                      color: isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                          fontSize: 8,
                          color: isOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              // GPS accuracy
              if (gpsAccuracy != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '±${gpsAccuracy!.toStringAsFixed(0)}m',
                    style: TextStyle(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.60),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Address
          if (address != null && address!.isNotEmpty) ...[
            Text(address!,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
          ],

          // Coordinates
          if (latitude != null && longitude != null)
            Text(
              '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.45),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500),
            ),

          // Nearest hospital
          if (nearestHospital != null && nearestHospital!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08), width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital_rounded,
                      size: 16, color: Color(0xFF60A5FA)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nearestHospital!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        if (hospitalEta != null)
                          Text('ETA: $hospitalEta',
                              style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Colors.white.withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Nearest',
                        style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700)),
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
