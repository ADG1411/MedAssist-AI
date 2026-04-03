import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Avatar
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.softBlue,
              backgroundImage: NetworkImage(
                  doctor['photo_url'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(doctor['name'])}&background=EBF3FF&color=2E62F1'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(doctor['specialty'], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 16),
                      const SizedBox(width: 4),
                      Text('${doctor['rating']}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.work_history, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text('${doctor['experience']} yrs', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Next available slot pill
                  if ((doctor['available_slots'] as List?)?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text('Next: ${doctor['available_slots'].first}', style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Outward chevron
            const Icon(Icons.chevron_right, color: AppColors.textSecondary)
          ],
        ),
      ),
    );
  }
}
