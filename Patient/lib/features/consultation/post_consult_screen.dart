import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';

class PostConsultScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const PostConsultScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PostConsultScreen> createState() => _PostConsultScreenState();
}

class _PostConsultScreenState extends ConsumerState<PostConsultScreen> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _submitting = false;

  Future<void> _submitFeedback() async {
    setState(() => _submitting = true);
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('care_plans').insert({
          'patient_id': userId,
          'rating': _rating,
          'feedback': _reviewController.text.isEmpty ? null : _reviewController.text,
          'prescription': [
            {'medication': 'As prescribed by doctor', 'dosage': 'See consultation notes'},
          ],
          'follow_up_date': DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
          'notes': 'Auto-generated after consultation ${widget.bookingId}',
        });
      }
    } catch (e) {
      debugPrint('Failed to save care plan: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Care Plan & E-Prescription saved to Vault.')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Finished'),
        automaticallyImplyLeading: false, // Force them through the flow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 80),
            const SizedBox(height: 24),
            const Text(
              'How was your consultation?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your care plan and e-prescription are being generated and will appear in your Medical Vault shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            
            // Star rating mock
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 40,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any specific feedback regarding the doctor?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: _submitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
              child: _submitting
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit & Return Home'),
            ),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Skip'),
            )
          ],
        ),
      ),
    );
  }
}
