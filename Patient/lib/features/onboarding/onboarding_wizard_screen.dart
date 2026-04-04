import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_background.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/step_basic_info.dart';
import 'widgets/step_medical_history.dart';
import 'widgets/step_lifestyle.dart';
import 'widgets/step_emergency.dart';
import 'widgets/step_permissions.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState
    extends ConsumerState<OnboardingWizardScreen> {
  final PageController _pageCtrl = PageController();

  static const _stepMeta = [
    (icon: Icons.person_outline_rounded, label: 'Basic'),
    (icon: Icons.medical_information_outlined, label: 'Medical'),
    (icon: Icons.self_improvement_rounded, label: 'Lifestyle'),
    (icon: Icons.emergency_outlined, label: 'Emergency'),
    (icon: Icons.tune_rounded, label: 'Setup'),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _syncPage(int step) {
    if (_pageCtrl.hasClients && _pageCtrl.page?.round() != step) {
      _pageCtrl.animateToPage(
        step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(onboardingProvider.select((s) => s.currentStep), (_, next) {
      _syncPage(next);
    });

    final steps = [
      const StepBasicInfo(),
      const StepMedicalHistory(),
      const StepLifestyle(),
      const StepEmergency(),
      const StepPermissions(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppBackground(isDark: isDark),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar with back + title ──────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
                  child: Row(
                    children: [
                      if (state.currentStep > 0)
                        GestureDetector(
                          onTap: notifier.previousStep,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.70),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : Colors.white,
                                width: 0.6,
                              ),
                            ),
                            child: Icon(Icons.arrow_back_rounded,
                                size: 16,
                                color:
                                    isDark ? Colors.white : Colors.black87),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                      const Spacer(),
                      Text(
                        'Profile Setup',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      // Step counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6)
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${state.currentStep + 1}/5',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Step indicators ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: List.generate(5, (i) {
                      final isActive = i == state.currentStep;
                      final isDone = i < state.currentStep;
                      return Expanded(
                        child: GestureDetector(
                          onTap: isDone ? () => notifier.goToStep(i) : null,
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? const Color(0xFF3B82F6)
                                      : isDone
                                          ? const Color(0xFF10B981)
                                          : isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.06)
                                              : const Color(0xFFF1F5F9),
                                  border: Border.all(
                                    color: isActive
                                        ? const Color(0xFF3B82F6)
                                            .withValues(alpha: 0.30)
                                        : isDone
                                            ? const Color(0xFF10B981)
                                                .withValues(alpha: 0.30)
                                            : isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.08)
                                                : const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF3B82F6)
                                                .withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  isDone
                                      ? Icons.check_rounded
                                      : _stepMeta[i].icon,
                                  size: 16,
                                  color: isActive || isDone
                                      ? Colors.white
                                      : isDark
                                          ? Colors.white
                                              .withValues(alpha: 0.25)
                                          : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _stepMeta[i].label,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isActive
                                      ? const Color(0xFF3B82F6)
                                      : isDone
                                          ? const Color(0xFF10B981)
                                          : isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.30)
                                              : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Animated progress bar ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 3,
                      child: LinearProgressIndicator(
                        value: (state.currentStep + 1) / 5,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF3B82F6)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // ── Steps content ─────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: steps,
                  ),
                ),

                // ── Bottom action bar ─────────────────────────────
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF050E1A)
                                .withValues(alpha: 0.70)
                            : Colors.white.withValues(alpha: 0.80),
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFE2E8F0)
                                    .withValues(alpha: 0.60),
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: state.isSubmitting
                            ? null
                            : () async {
                                HapticFeedback.mediumImpact();
                                if (state.currentStep == 4) {
                                  final success =
                                      await notifier.submitProfile();
                                  if (!context.mounted) return;
                                  if (success) {
                                    context.go('/home');
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Failed to save. Please ensure you are logged in.')),
                                    );
                                  }
                                } else {
                                  notifier.nextStep();
                                }
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: state.currentStep == 4
                                  ? [
                                      const Color(0xFF10B981),
                                      const Color(0xFF059669),
                                    ]
                                  : [
                                      const Color(0xFF3B82F6),
                                      const Color(0xFF2563EB),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: (state.currentStep == 4
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF3B82F6))
                                    .withValues(alpha: 0.30),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: state.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        state.currentStep == 4
                                            ? Icons.check_circle_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        state.currentStep == 4
                                            ? 'Complete Profile'
                                            : 'Continue',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
