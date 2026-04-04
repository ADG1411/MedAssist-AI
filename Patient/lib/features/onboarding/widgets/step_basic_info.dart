import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Glass card
          _GlassCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                _OnboardField(
                  controller: _nameCtrl,
                  hint: 'Full Name *',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  onChanged: (v) => notifier.updateBasicInfo(fullName: v),
                ),
                const SizedBox(height: 14),

                // Date of Birth
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.dateOfBirth ?? DateTime(2000),
                      firstDate: DateTime(1930),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) notifier.updateBasicInfo(dateOfBirth: date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cake_outlined,
                            size: 18,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.30)
                                : const Color(0xFF94A3B8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.dateOfBirth != null
                                ? '${state.dateOfBirth!.day}/${state.dateOfBirth!.month}/${state.dateOfBirth!.year}'
                                : 'Date of Birth',
                            style: TextStyle(
                              fontSize: 14,
                              color: state.dateOfBirth != null
                                  ? (isDark ? Colors.white : const Color(0xFF1E293B))
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                        Icon(Icons.calendar_month_rounded,
                            size: 18,
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.60)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Gender
                _SectionLabel('Gender', Icons.wc_rounded, isDark),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _genders.map((g) {
                    final sel = state.gender == g;
                    return _PillChip(
                      label: g,
                      selected: sel,
                      isDark: isDark,
                      onTap: () => notifier.updateBasicInfo(gender: g),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Height & Weight
                Row(
                  children: [
                    Expanded(
                      child: _OnboardField(
                        controller: _heightCtrl,
                        hint: 'Height (cm)',
                        icon: Icons.height_rounded,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => notifier.updateBasicInfo(heightCm: v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OnboardField(
                        controller: _weightCtrl,
                        hint: 'Weight (kg)',
                        icon: Icons.monitor_weight_outlined,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => notifier.updateBasicInfo(weightKg: v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Blood Group
                _SectionLabel('Blood Group', Icons.bloodtype_outlined, isDark),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _bloodGroups.map((bg) {
                    final sel = state.bloodGroup == bg;
                    return _PillChip(
                      label: bg,
                      selected: sel,
                      isDark: isDark,
                      onTap: () => notifier.updateBasicInfo(bloodGroup: bg),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Shared Onboarding Widgets ─────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _GlassCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.90),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDark;
  const _SectionLabel(this.text, this.icon, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white.withValues(alpha: 0.40)
                : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _PillChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF3B82F6)
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF3B82F6).withValues(alpha: 0.40)
                : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
            width: 0.6,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.20),
                    blurRadius: 6,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? Colors.white
                : isDark
                    ? Colors.white.withValues(alpha: 0.50)
                    : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _OnboardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _OnboardField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.6,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(icon,
              size: 18,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.30)
                  : const Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
