import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_button.dart';
import 'providers/booking_provider.dart';

class DoctorDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);
    final slots = List<String>.from(doctor['available_slots'] ?? []);

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Doctor Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.softBlue.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.softBlue,
                    backgroundImage: NetworkImage(
                      doctor['photo_url'] ??
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(doctor['name'])}&background=EBF3FF&color=2E62F1',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(doctor['name'], style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(doctor['specialty'], style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatBox('Rating', '${doctor['rating']} ★'),
                      const SizedBox(width: 16),
                      _buildStatBox('Experience', '${doctor['experience']} yrs'),
                      const SizedBox(width: 16),
                      _buildStatBox('Fee', '₹${doctor['consultation_fee']}'),
                    ],
                  ),
                ],
              ),
            ),

            // Bio Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About Doctor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(doctor['bio'] ?? 'No bio provided.', style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 32),

                  const Text('Available Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  if (slots.isEmpty)
                    const Text('No slots available at this time.', style: TextStyle(color: AppColors.danger))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: slots.map((slot) {
                        final isSelected = bookingState.selectedSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: bookingState.isPaymentSuccess ? null : (selected) {
                            if (selected) notifier.selectSlot(slot);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                        );
                      }).toList(),
                    ),

                  // Error message
                  if (bookingState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(bookingState.errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],

                  // Payment success confirmation
                  if (bookingState.isPaymentSuccess) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, size: 48, color: AppColors.success),
                          const SizedBox(height: 12),
                          const Text('Payment Successful!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success)),
                          const SizedBox(height: 8),
                          Text(
                            'Your consultation with ${doctor['name']} is confirmed.\nRoom: ${bookingState.jitsiRoomId ?? "generating..."}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: bookingState.isPaymentSuccess
              ? AppButton(
                  text: bookingState.isGeneratingHandoff
                      ? 'Preparing Consultation...'
                      : '🎥  Join Video Consultation',
                  onPressed: bookingState.isGeneratingHandoff
                      ? null
                      : () => context.push('/consultation', extra: {
                            'bookingId': bookingState.bookingId ?? 'unknown',
                            'doctorName': doctor['name'] ?? 'Doctor',
                            'jitsiRoom': bookingState.jitsiRoomId ?? 'medassist_fallback',
                          }),
                )
              : AppButton(
                  text: bookingState.isProcessingPayment
                      ? 'Processing Payment...'
                      : 'Pay ₹${doctor['consultation_fee']} & Book',
                  icon: bookingState.isProcessingPayment
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.lock_outline, color: Colors.white),
                  onPressed: bookingState.selectedSlot == null || bookingState.isProcessingPayment
                      ? null
                      : () => notifier.initiatePayment(
                            doctor['id'],
                            doctor['consultation_fee'] is int
                                ? doctor['consultation_fee']
                                : (doctor['consultation_fee'] as num).toInt(),
                            doctorName: doctor['name'],
                            doctorSpecialty: doctor['specialty'],
                          ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
