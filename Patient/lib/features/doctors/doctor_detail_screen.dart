import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
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
              color: AppColors.softBlue.withValues(alpha: 0.3),
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
                          onSelected: (selected) {
                            if (selected) notifier.selectSlot(slot);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                        );
                      }).toList(),
                    ),
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
              ? ElevatedButton.icon(
                  onPressed: bookingState.isGeneratingHandoff 
                     ? null 
                     : () => context.go('/dashboard'), // Assuming navigation back to main flow
                  icon: const Icon(Icons.check_circle),
                  label: Text(bookingState.isGeneratingHandoff ? 'Generating AI Brief...' : 'Booking Confirmed!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: bookingState.selectedSlot == null || bookingState.isProcessingPayment
                      ? null
                      : () => notifier.initiatePayment(doctor['id'], doctor['consultation_fee']),
                  icon: bookingState.isProcessingPayment ? const SizedBox.shrink() : const Icon(Icons.lock_outline),
                  label: bookingState.isProcessingPayment
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Pay ₹${doctor['consultation_fee']} & Book'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
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
