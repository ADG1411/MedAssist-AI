import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/interactive_body_map.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_button.dart';
import 'providers/symptom_check_provider.dart';

class BodyMapScreen extends ConsumerStatefulWidget {
  const BodyMapScreen({super.key});

  @override
  ConsumerState<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends ConsumerState<BodyMapScreen> {
  final _notesController = TextEditingController();

  final List<String> _symptomTypes = const [
    'Mild', 'Moderate', 'Severe', 'Burning', 'Sharp', 'Dull', 'Throbbing', 'Aching'
  ];

  final List<String> _durations = const [
    'Just now', 'Few hours', '1-2 days', '3-7 days', '1-2 weeks', 'More than 2 weeks', 'Chronic'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getStringFromPart(BodyPart part) {
    switch (part) {
      case BodyPart.head: return 'Head';
      case BodyPart.neck: return 'Neck';
      case BodyPart.leftShoulder: return 'Left Shoulder';
      case BodyPart.rightShoulder: return 'Right Shoulder';
      case BodyPart.chest: return 'Chest';
      case BodyPart.leftUpperArm: return 'Left Upper Arm';
      case BodyPart.rightUpperArm: return 'Right Upper Arm';
      case BodyPart.abdomen: return 'Abdomen';
      case BodyPart.leftElbow: return 'Left Elbow';
      case BodyPart.rightElbow: return 'Right Elbow';
      case BodyPart.hipPelvis: return 'Hip / Pelvis';
      case BodyPart.leftForearm: return 'Left Forearm';
      case BodyPart.rightForearm: return 'Right Forearm';
      case BodyPart.leftHand: return 'Left Hand';
      case BodyPart.rightHand: return 'Right Hand';
      case BodyPart.leftThigh: return 'Left Thigh';
      case BodyPart.rightThigh: return 'Right Thigh';
      case BodyPart.leftKnee: return 'Left Knee';
      case BodyPart.rightKnee: return 'Right Knee';
      case BodyPart.leftShin: return 'Left Shin';
      case BodyPart.rightShin: return 'Right Shin';
      case BodyPart.leftFoot: return 'Left Foot';
      case BodyPart.rightFoot: return 'Right Foot';
    }
  }

  BodyPart? _getPartFromString(String? region) {
    if (region == null) return null;
    for (final part in BodyPart.values) {
      if (_getStringFromPart(part) == region) return part;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(symptomCheckProvider);
    final notifier = ref.read(symptomCheckProvider.notifier);

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Where does it hurt?'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Interactive Body Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: InteractiveBodyMap(
                  selectedPart: _getPartFromString(state.selectedRegion),
                  onPartSelected: (BodyPart part) {
                    notifier.selectRegion(_getStringFromPart(part));
                  },
                ),
              ),
            ),
          ),

          // Bottom panel — scrollable for detailed input
          _BottomPanel(
            state: state,
            notifier: notifier,
            symptomTypes: _symptomTypes,
            durations: _durations,
            notesController: _notesController,
          ),
        ],
      ),
    );
  }
}

// ── Bottom panel with symptom details ──
class _BottomPanel extends StatelessWidget {
  final SymptomCheckState state;
  final SymptomCheckNotifier notifier;
  final List<String> symptomTypes;
  final List<String> durations;
  final TextEditingController notesController;

  const _BottomPanel({
    required this.state,
    required this.notifier,
    required this.symptomTypes,
    required this.durations,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Selected region badge
            if (state.selectedRegion != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      state.selectedRegion!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Pain type chips ──
            const Text(
              'How does it feel?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptomTypes.map((symptom) {
                final isSelected = state.selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (_) => notifier.toggleSymptom(symptom),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Duration selection ──
            const Text(
              'How long have you had this?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: durations.map((dur) {
                final isSelected = state.duration == dur;
                return ChoiceChip(
                  label: Text(dur),
                  selected: isSelected,
                  onSelected: (_) => notifier.setDuration(dur),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Additional notes ──
            const Text(
              'Tell us more (optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Any specific details that can help with the diagnosis',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 3,
              minLines: 2,
              onChanged: notifier.setAdditionalNotes,
              decoration: InputDecoration(
                hintText: 'e.g. Pain gets worse at night, started after exercise, numbness in fingers...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Continue button
            AppButton(
              text: 'Continue to AI Analysis',
              onPressed: state.canContinue ? () => context.push('/symptom-chat') : null,
            ),
          ],
        ),
      ),
    );
  }
}
