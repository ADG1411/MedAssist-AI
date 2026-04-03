import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class StepEmergency extends ConsumerStatefulWidget {
  const StepEmergency({super.key});

  @override
  ConsumerState<StepEmergency> createState() => _StepEmergencyState();
}

class _StepEmergencyState extends ConsumerState<StepEmergency> {
  final _insProviderCtrl = TextEditingController();
  final _insIdCtrl = TextEditingController();

  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactRelCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    _insProviderCtrl.text = s.insuranceProvider;
    _insIdCtrl.text = s.insuranceId;
  }

  @override
  void dispose() {
    _insProviderCtrl.dispose();
    _insIdCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactRelCtrl.dispose();
    super.dispose();
  }

  void _addContact() {
    if (_contactNameCtrl.text.isNotEmpty && _contactPhoneCtrl.text.isNotEmpty) {
      ref.read(onboardingProvider.notifier).addEmergencyContact({
        'name': _contactNameCtrl.text,
        'phone': _contactPhoneCtrl.text,
        'relation': _contactRelCtrl.text.isNotEmpty ? _contactRelCtrl.text : 'Contact',
      });
      _contactNameCtrl.clear();
      _contactPhoneCtrl.clear();
      _contactRelCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Emergency & SOS', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Crucial data used during SOS and hospital handoffs.', style: TextStyle(color: AppColors.danger)),
          const SizedBox(height: 32),

          // Emergency Contacts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('${state.emergencyContacts.length}/3', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          
          if (state.emergencyContacts.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.emergencyContacts.length,
              itemBuilder: (context, i) {
                final c = state.emergencyContacts[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: AppColors.softBlue, child: Icon(Icons.person, color: AppColors.primary)),
                  title: Text(c['name'] ?? ''),
                  subtitle: Text('${c['relation']} • ${c['phone']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                    onPressed: () => notifier.removeEmergencyContact(i),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          if (state.emergencyContacts.length < 3) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                TextFormField(
                  controller: _contactNameCtrl,
                  decoration: const InputDecoration(labelText: 'Name', isDense: true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _contactPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _contactRelCtrl,
                        decoration: const InputDecoration(labelText: 'Relation', isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _addContact,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Contact'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Insurance
          const Text('Health Insurance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _insProviderCtrl,
            decoration: const InputDecoration(
              labelText: 'Provider Name',
              prefixIcon: Icon(Icons.health_and_safety_outlined),
            ),
            onChanged: (v) => notifier.updateInsurance(provider: v),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _insIdCtrl,
            decoration: const InputDecoration(
              labelText: 'Policy/ID Number',
              prefixIcon: Icon(Icons.numbers_outlined),
            ),
            onChanged: (v) => notifier.updateInsurance(id: v),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
