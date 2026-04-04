import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        'relation': _contactRelCtrl.text.isNotEmpty
            ? _contactRelCtrl.text
            : 'Contact',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency & SOS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crucial data used during SOS and hospital handoffs',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFFEF4444).withValues(alpha: 0.70),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // ── Emergency Contacts Card ─────────────────────────────
          ClipRRect(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.emergency_outlined,
                            size: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.40)
                                : const Color(0xFF475569),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${state.emergencyContacts.length}/3',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.80),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Existing contacts
                    if (state.emergencyContacts.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ...List.generate(state.emergencyContacts.length, (i) {
                        final c = state.emergencyContacts[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : const Color(0xFFE2E8F0),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.10),
                                  ),
                                  child: Icon(Icons.person_rounded,
                                      size: 16,
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.70)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c['name'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        '${c['relation']} • ${c['phone']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.40)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      notifier.removeEmergencyContact(i),
                                  child: Icon(Icons.close_rounded,
                                      size: 16,
                                      color: const Color(0xFFEF4444)
                                          .withValues(alpha: 0.50)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],

                    // Add contact form
                    if (state.emergencyContacts.length < 3) ...[
                      const SizedBox(height: 12),
                      _GlassField(
                        controller: _contactNameCtrl,
                        hint: 'Contact Name',
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _GlassField(
                              controller: _contactPhoneCtrl,
                              hint: 'Phone',
                              icon: Icons.phone_outlined,
                              isDark: isDark,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _GlassField(
                              controller: _contactRelCtrl,
                              hint: 'Relation',
                              icon: Icons.group_outlined,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _addContact,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 16,
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.70)),
                              const SizedBox(width: 6),
                              Text(
                                'Add Contact',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.80),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Insurance Card ──────────────────────────────────────
          ClipRRect(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.health_and_safety_outlined,
                            size: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Health Insurance',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.40)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _GlassField(
                      controller: _insProviderCtrl,
                      hint: 'Provider Name',
                      icon: Icons.business_outlined,
                      isDark: isDark,
                      onChanged: (v) =>
                          notifier.updateInsurance(provider: v),
                    ),
                    const SizedBox(height: 10),
                    _GlassField(
                      controller: _insIdCtrl,
                      hint: 'Policy / ID Number',
                      icon: Icons.tag_rounded,
                      isDark: isDark,
                      onChanged: (v) => notifier.updateInsurance(id: v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Glass Field ───────────────────────────────────────────────────────────

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _GlassField({
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
          fontSize: 13,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(icon,
              size: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.30)
                  : const Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
