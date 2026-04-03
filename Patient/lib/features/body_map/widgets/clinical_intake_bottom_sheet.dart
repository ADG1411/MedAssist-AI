import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/symptom_check_provider.dart';
import 'pain_severity_selector.dart';
import 'sensation_chip_grid.dart';
import 'trigger_context_selector.dart';
import 'movement_impact_selector.dart';
import 'ai_triage_preview_card.dart';
import 'dynamic_clinical_notes_field.dart';

/// Clinical Intake Bottom Sheet — the primary diagnostic experience.
/// Progressive doctor-style questioning inside a DraggableScrollableSheet.
/// Manages local UI state for trigger + movement (not in provider).
/// All existing provider calls preserved: toggleSymptom, setDuration,
/// setAdditionalNotes, canContinue, symptom-chat navigation.
class ClinicalIntakeBottomSheet extends StatefulWidget {
  final SymptomCheckState state;
  final SymptomCheckNotifier notifier;
  final TextEditingController notesController;
  final VoidCallback onContinue;

  const ClinicalIntakeBottomSheet({
    super.key,
    required this.state,
    required this.notifier,
    required this.notesController,
    required this.onContinue,
  });

  @override
  State<ClinicalIntakeBottomSheet> createState() =>
      _ClinicalIntakeBottomSheetState();
}

class _ClinicalIntakeBottomSheetState
    extends State<ClinicalIntakeBottomSheet> {
  // Local UI state for new fields (not in existing provider)
  String? _selectedTrigger;
  String? _selectedMovementImpact;

  static const _durations = [
    'Just now',
    'Few hours',
    '1-2 days',
    '3-7 days',
    '1-2 weeks',
    '2+ weeks',
    'Chronic',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = widget.state;
    final notifier = widget.notifier;
    final hasRegion = state.selectedRegion != null;

    return DraggableScrollableSheet(
      initialChildSize: hasRegion ? 0.48 : 0.20,
      minChildSize: 0.15,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const [0.20, 0.48, 0.88],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
                20, 10, 20, MediaQuery.viewInsetsOf(context).bottom + 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Selected region badge
                if (hasRegion) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6)
                          .withValues(alpha: isDark ? 0.12 : 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF3B82F6)
                              .withValues(alpha: 0.22),
                          width: 0.6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location_rounded,
                            size: 14, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 8),
                        Text(
                          state.selectedRegion!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF3B82F6)),
                        ),
                        const Spacer(),
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: Color(0xFF3B82F6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 1: Severity
                  PainSeveritySelector(
                    selectedSymptoms: state.selectedSymptoms,
                    onToggle: notifier.toggleSymptom,
                  ),
                  const SizedBox(height: 18),

                  // Step 2: Sensation
                  SensationChipGrid(
                    selectedSymptoms: state.selectedSymptoms,
                    onToggle: notifier.toggleSymptom,
                  ),
                  const SizedBox(height: 18),

                  // Step 3: Duration
                  _DurationSelector(
                    selectedDuration: state.duration,
                    durations: _durations,
                    onSelect: notifier.setDuration,
                  ),
                  const SizedBox(height: 18),

                  // Step 4: Trigger
                  TriggerContextSelector(
                    selectedTrigger: _selectedTrigger,
                    onSelect: (t) => setState(() => _selectedTrigger = t),
                  ),
                  const SizedBox(height: 18),

                  // Step 5: Movement impact
                  MovementImpactSelector(
                    selectedImpact: _selectedMovementImpact,
                    onSelect: (m) =>
                        setState(() => _selectedMovementImpact = m),
                  ),
                  const SizedBox(height: 18),

                  // Step 6: Notes
                  DynamicClinicalNotesField(
                    region: state.selectedRegion,
                    controller: widget.notesController,
                    onChanged: notifier.setAdditionalNotes,
                  ),
                  const SizedBox(height: 18),

                  // AI Triage Preview
                  AiTriagePreviewCard(
                    region: state.selectedRegion,
                    symptoms: state.selectedSymptoms,
                    movementImpact: _selectedMovementImpact,
                  ),
                  const SizedBox(height: 20),

                  // Continue CTA
                  _AnalyzeCta(
                    canContinue: state.canContinue,
                    onPressed: widget.onContinue,
                  ),

                  const SizedBox(height: 16),
                ] else ...[
                  // No region selected — prompt
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 32,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.20)
                                : Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'Tap a body region to begin',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select where you feel discomfort',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.20)
                                  : Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Duration Selector ─────────────────────────────────────────────────────

class _DurationSelector extends StatelessWidget {
  final String selectedDuration;
  final List<String> durations;
  final ValueChanged<String> onSelect;

  const _DurationSelector({
    required this.selectedDuration,
    required this.durations,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('3',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981))),
              ),
            ),
            const SizedBox(width: 8),
            Text('How long have you had this?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: durations.map((dur) {
            final isSelected = selectedDuration == dur;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(dur);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981)
                          .withValues(alpha: isDark ? 0.18 : 0.10)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFF10B981).withValues(alpha: 0.45)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06)),
                      width: isSelected ? 1.0 : 0.6),
                ),
                child: Text(dur,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.50)
                                : Colors.grey.shade600))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── AI Analyze CTA ────────────────────────────────────────────────────────

class _AnalyzeCta extends StatelessWidget {
  final bool canContinue;
  final VoidCallback onPressed;

  const _AnalyzeCta({
    required this.canContinue,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canContinue
          ? () {
              HapticFeedback.mediumImpact();
              onPressed();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: canContinue
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)])
              : null,
          color: canContinue ? null : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          boxShadow: canContinue
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome,
                size: 18,
                color: canContinue
                    ? Colors.white
                    : Colors.grey.withValues(alpha: 0.40)),
            const SizedBox(width: 8),
            Text(
              'Analyze with AI Doctor',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: canContinue
                      ? Colors.white
                      : Colors.grey.withValues(alpha: 0.40)),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded,
                size: 16,
                color: canContinue
                    ? Colors.white.withValues(alpha: 0.70)
                    : Colors.grey.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}
