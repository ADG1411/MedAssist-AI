import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/digital_health_card.dart';
import '../../shared/widgets/app_button.dart';

class MedAssistCardScreen extends ConsumerWidget {
  const MedAssistCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Build user data from real auth state, with sensible fallbacks
    final userData = {
      'name': authState?['name'] ?? 'MedAssist User',
      'healthId': 'MD-${(authState?['id'] ?? 'anon').toString().substring(0, 8).toUpperCase()}',
      'bloodGroup': authState?['bloodGroup'] ?? 'N/A',
      'dob': authState?['dob'] ?? 'Not Set',
      'gender': authState?['gender'] ?? 'Not Set',
    };

    // Extract allergies and conditions from auth metadata
    final allergies = (authState?['allergies'] as List<dynamic>?) ?? [];
    final conditions = (authState?['chronicConditions'] as List<dynamic>?) ?? [];

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Digital Health ID'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DigitalHealthCard(userData: userData),
            const SizedBox(height: 32),
            
            // Medical Tags
            const Text('Critical Meta Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...allergies.map((a) => _buildTag('Allergic: $a', Colors.red)),
                ...conditions.map((c) => _buildTag(c.toString(), Colors.orange)),
                if (allergies.isEmpty && conditions.isEmpty)
                  _buildTag('No conditions recorded', Colors.grey),
              ],
            ),
            
            const SizedBox(height: 48),
            AppButton(
              text: 'Add to Apple Wallet',
              icon: const Icon(Icons.account_balance_wallet),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Wallet')));
              },
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Download Print PDF',
              icon: const Icon(Icons.picture_as_pdf),
              variant: AppButtonVariant.secondary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading PDF...')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
