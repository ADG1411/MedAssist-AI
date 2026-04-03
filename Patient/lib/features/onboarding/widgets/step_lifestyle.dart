import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class StepLifestyle extends ConsumerWidget {
  const StepLifestyle({super.key});

  static const _smoking = ['Never', 'Occasional', 'Frequent'];
  static const _alcohol = ['None', 'Occasional', 'Frequent'];
  static const _stress = ['Low', 'Moderate', 'High'];
  static const _activity = ['Sedentary', 'Moderate', 'Active'];
  static const _diet = ['Regular', 'Vegetarian', 'Vegan', 'Keto', 'Other'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lifestyle', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Lifestyle context improves AI medical accuracy.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),

          _buildChoiceSection('Smoking Status', _smoking, state.smokingStatus, (v) => notifier.updateLifestyle(smokingStatus: v)),
          const SizedBox(height: 24),
          
          _buildChoiceSection('Alcohol Consumption', _alcohol, state.alcoholFrequency, (v) => notifier.updateLifestyle(alcoholFrequency: v)),
          const SizedBox(height: 24),

          const Text('Average Sleep (Hours)', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: state.sleepHoursAvg,
            min: 2,
            max: 12,
            divisions: 20,
            label: '${state.sleepHoursAvg} hrs',
            onChanged: (v) => notifier.updateLifestyle(sleepHoursAvg: v),
          ),
          const SizedBox(height: 24),

          _buildChoiceSection('Stress Level', _stress, state.stressLevel, (v) => notifier.updateLifestyle(stressLevel: v)),
          const SizedBox(height: 24),

          _buildChoiceSection('Activity Level', _activity, state.activityLevel, (v) => notifier.updateLifestyle(activityLevel: v)),
          const SizedBox(height: 24),

          _buildChoiceSection('Diet Type', _diet, state.dietType, (v) => notifier.updateLifestyle(dietType: v)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildChoiceSection(String title, List<String> options, String current, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) => ChoiceChip(
            label: Text(opt),
            selected: current == opt,
            onSelected: (_) => onSelect(opt),
            selectedColor: AppColors.softBlue,
          )).toList(),
        ),
      ],
    );
  }
}
