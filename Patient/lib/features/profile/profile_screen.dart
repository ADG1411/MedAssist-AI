import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/section_header.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileProvider);

    return BaseScreen(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit), 
            onPressed: () => context.push('/onboarding-wizard')
          ),
        ],
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 16),
              Text('Failed to load profile: $e', textAlign: TextAlign.center),
              TextButton(onPressed: () => ref.invalidate(profileProvider), child: const Text('Retry'))
            ],
          ),
        ),
        data: (profile) {
          final name = profile['name']?.toString() ?? 'Guest';
          final email = profile['email']?.toString() ?? 'No Email';
          final bloodGroup = profile['blood_group']?.toString() ?? 'Unknown';
          final age = profile['age']?.toString() ?? '-';
          final gender = profile['gender']?.toString() ?? '-';
          final height = profile['height_cm']?.toString() ?? '-';
          final weight = profile['weight_kg']?.toString() ?? '-';
          
          final allergies = (profile['allergies'] as List?)?.cast<String>() ?? [];
          final conditions = (profile['chronic_conditions'] as List?)?.cast<String>() ?? [];
          final medications = (profile['current_medications'] as List?)?.cast<String>() ?? [];
          final surgeries = (profile['past_surgeries'] as List?)?.cast<String>() ?? [];
          
          final emergencyContacts = (profile['emergency_contacts'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 80),
            child: Column(
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.softBlue,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'G',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                        child: Text('Blood Group: $bloodGroup', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Medical Identity
                const SectionHeader(title: 'Medical Identity'),
                const SizedBox(height: 16),
                _buildInfoGrid(context, age, gender, height, weight),

                const SizedBox(height: 32),

                // Health Conditions
                if (conditions.isNotEmpty || allergies.isNotEmpty || medications.isNotEmpty || surgeries.isNotEmpty) ...[
                  const SectionHeader(title: 'Clinical History'),
                  const SizedBox(height: 16),
                  
                  if (conditions.isNotEmpty)
                    _buildTagRow(context, 'Conditions', conditions, AppColors.danger),
                  if (allergies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildTagRow(context, 'Allergies', allergies, AppColors.warning),
                    ),
                  if (medications.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildTagRow(context, 'Medications', medications, AppColors.primary),
                    ),
                  if (surgeries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildTagRow(context, 'Surgeries', surgeries, AppColors.textSecondary),
                    ),
                  const SizedBox(height: 32),
                ],

                // Emergency SOS Information
                if (emergencyContacts.isNotEmpty) ...[
                  const SectionHeader(title: 'Emergency Contacts'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: emergencyContacts.map((contact) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_in_talk, color: AppColors.danger, size: 20),
                            const SizedBox(width: 8),
                            Text('${contact['name'] ?? 'Friend'} (${contact['relation'] ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text(contact['phone'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // AI Preferences
                const SectionHeader(title: 'AI Diagnostics Setup'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Default Analysis Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                            child: const Text('Fast AI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Toggle your default chat behavior. Deep check incurs clinical simulation time.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: AppColors.danger),
                    label: const Text('Secure Logout', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Logout Session?'),
                          content: const Text('This will clear local medical caches securely.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(onPressed: () async {
                              Navigator.pop(ctx);
                              await ref.read(authProvider.notifier).logout();
                              if (context.mounted) context.go('/login');
                            }, child: const Text('Logout', style: TextStyle(color: AppColors.danger))),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                const Center(child: Text('MedAssist Engine v2.0.0', style: TextStyle(color: AppColors.border, fontWeight: FontWeight.bold))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, String age, String gender, String height, String weight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _infoTile('Age', age, Icons.calendar_month),
          Container(width: 1, height: 40, color: AppColors.border),
          _infoTile('Gender', gender, Icons.person),
          Container(width: 1, height: 40, color: AppColors.border),
          _infoTile('Height', '$height cm', Icons.height),
          Container(width: 1, height: 40, color: AppColors.border),
          _infoTile('Weight', '$weight kg', Icons.monitor_weight),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTagRow(BuildContext context, String label, List<String> tags, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13))
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(t, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
