import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical History',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Helps AI personalize advice and detect drug interactions',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Allergies
          _MedSection(
            isDark: isDark,
            icon: Icons.coronavirus_outlined,
            title: 'Allergies',
            hint: 'Add an allergy…',
            controller: _allergyCtrl,
            items: state.allergies,
            chipColor: const Color(0xFFEF4444),
            onAdd: notifier.addAllergy,
            onRemove: notifier.removeAllergy,
          ),
          const SizedBox(height: 14),

          // Chronic Conditions
          _MedSection(
            isDark: isDark,
            icon: Icons.sick_outlined,
            title: 'Chronic Conditions',
            hint: 'Add a condition…',
            controller: _conditionCtrl,
            items: state.chronicConditions,
            chipColor: const Color(0xFFF59E0B),
            onAdd: notifier.addCondition,
            onRemove: notifier.removeCondition,
          ),
          const SizedBox(height: 14),

          // Current Medications
          _MedSection(
            isDark: isDark,
            icon: Icons.medication_outlined,
            title: 'Current Medications',
            hint: 'Add a medication…',
            controller: _medicationCtrl,
            items: state.currentMedications,
            chipColor: const Color(0xFF3B82F6),
            onAdd: notifier.addMedication,
            onRemove: notifier.removeMedication,
          ),
          const SizedBox(height: 14),

          // Past Surgeries
          _MedSection(
            isDark: isDark,
            icon: Icons.content_cut_outlined,
            title: 'Past Surgeries',
            hint: 'Add a surgery…',
            controller: _surgeryCtrl,
            items: state.pastSurgeries,
            chipColor: const Color(0xFF8B5CF6),
            onAdd: notifier.addSurgery,
            onRemove: notifier.removeSurgery,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Medical Section Card ──────────────────────────────────────────────────

class _MedSection extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String hint;
  final TextEditingController controller;
  final List<String> items;
  final Color chipColor;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const _MedSection({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.hint,
    required this.controller,
    required this.items,
    required this.chipColor,
    required this.onAdd,
    required this.onRemove,
  });

  void _handleAdd() {
    if (controller.text.trim().isNotEmpty) {
      onAdd(controller.text.trim());
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              width: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(icon,
                      size: 16,
                      color: chipColor.withValues(alpha: 0.70)),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.70)
                          : const Color(0xFF334155),
                    ),
                  ),
                  const Spacer(),
                  if (items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: chipColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${items.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: chipColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Input row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFE2E8F0),
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.20)
                                : const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (_) => _handleAdd(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _handleAdd,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: chipColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: chipColor.withValues(alpha: 0.20),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(Icons.add_rounded,
                          size: 18, color: chipColor),
                    ),
                  ),
                ],
              ),

              // Tags
              if (items.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: items.map((item) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
                      decoration: BoxDecoration(
                        color: chipColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: chipColor.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? chipColor.withValues(alpha: 0.90)
                                  : chipColor.withValues(alpha: 0.80),
                            ),
                          ),
                          const SizedBox(width: 2),
                          GestureDetector(
                            onTap: () => onRemove(item),
                            child: Icon(Icons.close_rounded,
                                size: 14,
                                color: chipColor.withValues(alpha: 0.50)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
