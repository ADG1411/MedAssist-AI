import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class StepBasicInfo extends ConsumerStatefulWidget {
  const StepBasicInfo({super.key});

  @override
  ConsumerState<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends ConsumerState<StepBasicInfo> {
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    _nameCtrl = TextEditingController(text: s.fullName);
    _heightCtrl = TextEditingController(text: s.heightCm);
    _weightCtrl = TextEditingController(text: s.weightKg);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'];
  static const _genders = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tell us about yourself', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          // Full Name
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (v) => notifier.updateBasicInfo(fullName: v),
          ),
          const SizedBox(height: 16),

          // Date of Birth
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined, color: AppColors.primary),
            title: Text(
              state.dateOfBirth != null
                  ? '${state.dateOfBirth!.day}/${state.dateOfBirth!.month}/${state.dateOfBirth!.year}'
                  : 'Date of Birth',
              style: TextStyle(color: state.dateOfBirth != null ? null : AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.dateOfBirth ?? DateTime(2000),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (date != null) notifier.updateBasicInfo(dateOfBirth: date);
            },
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Gender
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _genders.map((g) => ChoiceChip(
              label: Text(g),
              selected: state.gender == g,
              onSelected: (_) => notifier.updateBasicInfo(gender: g),
              selectedColor: AppColors.softBlue,
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Height & Weight
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(Icons.height),
                  ),
                  onChanged: (v) => notifier.updateBasicInfo(heightCm: v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                  onChanged: (v) => notifier.updateBasicInfo(weightKg: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Blood Group
          const Text('Blood Group', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bloodGroups.map((bg) => ChoiceChip(
              label: Text(bg),
              selected: state.bloodGroup == bg,
              onSelected: (_) => notifier.updateBasicInfo(bloodGroup: bg),
              selectedColor: AppColors.softBlue,
            )).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
