import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class StepMedicalHistory extends ConsumerStatefulWidget {
  const StepMedicalHistory({super.key});

  @override
  ConsumerState<StepMedicalHistory> createState() => _StepMedicalHistoryState();
}

class _StepMedicalHistoryState extends ConsumerState<StepMedicalHistory> {
  final _allergyCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _medicationCtrl = TextEditingController();
  final _surgeryCtrl = TextEditingController();

  @override
  void dispose() {
    _allergyCtrl.dispose();
    _conditionCtrl.dispose();
    _medicationCtrl.dispose();
    _surgeryCtrl.dispose();
    super.dispose();
  }

  Widget _buildList(String title, List<String> items, Function(String) onRemove) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Chip(
            label: Text(item),
            onDeleted: () => onRemove(item),
            backgroundColor: AppColors.softBlue,
            deleteIconColor: AppColors.primary,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInputRow(String label, IconData icon, TextEditingController controller, Function(String) onAdd) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onFieldSubmitted: (v) {
              onAdd(v);
              controller.clear();
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onAdd(controller.text);
              controller.clear();
            }
          },
          icon: const Icon(Icons.add_circle),
          color: AppColors.primary,
          iconSize: 32,
        ),
      ],
    );
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
          Text('Medical History', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Provide relevant medical details to help AI personalize advice.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),

          // Allergies
          const Text('Allergies', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          _buildInputRow('Add an allergy...', Icons.coronavirus_outlined, _allergyCtrl, notifier.addAllergy),
          _buildList('Allergies', state.allergies, notifier.removeAllergy),
          const SizedBox(height: 24),

          // Chronic Conditions
          const Text('Chronic Conditions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          _buildInputRow('Add a condition...', Icons.sick_outlined, _conditionCtrl, notifier.addCondition),
          _buildList('Conditions', state.chronicConditions, notifier.removeCondition),
          const SizedBox(height: 24),

          // Current Medications
          const Text('Current Medications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          _buildInputRow('Add a medication...', Icons.medication_outlined, _medicationCtrl, notifier.addMedication),
          _buildList('Medications', state.currentMedications, notifier.removeMedication),
          const SizedBox(height: 24),

          // Past Surgeries
          const Text('Past Surgeries', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          _buildInputRow('Add a surgery...', Icons.content_cut_outlined, _surgeryCtrl, notifier.addSurgery),
          _buildList('Surgeries', state.pastSurgeries, notifier.removeSurgery),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
