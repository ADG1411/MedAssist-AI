import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_button.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/step_basic_info.dart';
import 'widgets/step_medical_history.dart';
import 'widgets/step_lifestyle.dart';
import 'widgets/step_emergency.dart';
import 'widgets/step_permissions.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _syncPage(int step) {
    if (_pageCtrl.hasClients && _pageCtrl.page?.round() != step) {
      _pageCtrl.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Sync PageController when Riverpod state changes
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

    return BaseScreen(
      appBar: AppBar(
        title: Text('Profile Setup (${state.currentStep + 1}/5)', style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        leading: state.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: notifier.previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (state.currentStep + 1) / 5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            
            // Steps
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(), // Managed by buttons
                children: steps,
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: state.currentStep == 4
                  ? AppButton(
                      text: 'Complete Profile',
                      isLoading: state.isSubmitting,
                      onPressed: () async {
                        final success = await notifier.submitProfile();
                        if (!context.mounted) return;
                        if (success) {
                          context.go('/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to save profile. Please ensure you are logged in.')),
                          );
                        }
                      },
                    )
                  : AppButton(
                      text: 'Next',
                      onPressed: notifier.nextStep,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
