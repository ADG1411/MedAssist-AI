// Body Map Screen — Premium AI Clinical Diagnostic Intake
// UI-only rewrite. All existing backend logic preserved:
// symptomCheckProvider, SymptomCheckNotifier, BodyPart enum,
// InteractiveBodyMap, context.push('/symptom-chat').
// Overflow permanently fixed via DraggableScrollableSheet.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/interactive_body_map.dart';
import '../../shared/widgets/app_background.dart';
import 'providers/symptom_check_provider.dart';
import 'widgets/body_map_hero.dart';
import 'widgets/clinical_intake_bottom_sheet.dart';

class BodyMapScreen extends ConsumerStatefulWidget {
  const BodyMapScreen({super.key});

  @override
  ConsumerState<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends ConsumerState<BodyMapScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Existing mapping helpers (preserved) ────────────────────────────────

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(symptomCheckProvider);
    final notifier = ref.read(symptomCheckProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          AppBackground(isDark: isDark),

          // Header bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.30)
                      : Colors.white.withValues(alpha: 0.60),
                  padding: EdgeInsets.fromLTRB(
                      8, MediaQuery.paddingOf(context).top + 4, 12, 8),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.09)
                                : Colors.white.withValues(alpha: 0.72),
                            border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.white,
                                width: 0.8),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              size: 16,
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Where does it hurt?',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    letterSpacing: -0.3)),
                            Text('Tap a body region to begin diagnosis',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : Colors.grey)),
                          ],
                        ),
                      ),
                      // AI badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 10, color: Colors.white),
                            SizedBox(width: 3),
                            Text('AI',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Body map hero — fills top area behind sheet
          Positioned(
            top: MediaQuery.paddingOf(context).top + 52,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: BodyMapHero(
              selectedPart: _getPartFromString(state.selectedRegion),
              selectedRegionLabel: state.selectedRegion,
              isFrontView: state.isFrontView,
              onPartSelected: (BodyPart part) {
                notifier.selectRegion(_getStringFromPart(part));
              },
              onToggleView: notifier.toggleView,
            ),
          ),

          // Clinical intake bottom sheet — DraggableScrollableSheet
          ClinicalIntakeBottomSheet(
            state: state,
            notifier: notifier,
            notesController: _notesController,
            onContinue: () => context.push('/symptom-chat'),
          ),
        ],
      ),
    );
  }
}
