import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/hydration_tracker.dart';
import '../../shared/widgets/severity_slider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/dialogs/success_sheet.dart';
import 'providers/monitoring_provider.dart';

class MonitoringScreen extends ConsumerWidget {
  const MonitoringScreen({super.key});

  final List<String> moods = const ['Terrible', 'Bad', 'Neutral', 'Good', 'Excellent'];
  final List<IconData> moodIcons = const [Icons.sentiment_very_dissatisfied, Icons.sentiment_dissatisfied, Icons.sentiment_neutral, Icons.sentiment_satisfied, Icons.sentiment_very_satisfied];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitoringProvider);
    final notifier = ref.read(monitoringProvider.notifier);

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        actions: [
          TextButton(
             onPressed: () => context.push('/recovery-report'),
             child: const Text('View Report', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            // Day Stepper mock
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (index) {
                  bool isToday = index == 4;
                  bool isPast = index < 4;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : (isPast ? AppColors.success.withValues(alpha: 0.2) : Theme.of(context).cardColor),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isToday ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      'Day ${index + 1}',
                      style: TextStyle(
                        color: isToday ? Colors.white : (isPast ? AppColors.success : AppColors.textSecondary),
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            
            // Symptoms
            const SectionHeader(title: 'Symptom Severity'),
            const SizedBox(height: 16),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
               child: SeveritySlider(
                 value: state.symptomSeverity,
                 onChanged: notifier.updateSeverity,
               ),
             ),

            const SizedBox(height: 32),
            // Hydration
            Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
               child: HydrationTracker(
                 currentCups: state.hydrationCups,
                 onTap: notifier.incrementHydration,
               ),
            ),

            const SizedBox(height: 32),
            // Sleep Tracking
            const SectionHeader(title: 'Sleep Duration'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Hours', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${state.sleepHours.toStringAsFixed(1)} h', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  Slider(
                    value: state.sleepHours,
                    min: 4,
                    max: 12,
                    divisions: 16,
                    activeColor: AppColors.primary,
                    onChanged: notifier.updateSleep,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Mood Tracking
            const SectionHeader(title: 'How do you feel?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(moods.length, (index) {
                final m = moods[index];
                final isSelected = state.mood == m;
                return GestureDetector(
                   onTap: () => notifier.updateMood(m),
                   child: Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                     ),
                     child: Icon(
                       moodIcons[index],
                       size: 32,
                       color: isSelected ? AppColors.primary : AppColors.textSecondary,
                     ),
                   ),
                );
              }),
            ),

            const SizedBox(height: 48),
            AppButton(
              text: state.isSaving ? 'Vaulting...' : 'Save Check-in',
              onPressed: state.isSaving ? () {} : () async {
                final success = await notifier.saveDailyCheckin();
                if (context.mounted && success) {
                   SuccessSheet.show(
                     context: context, 
                     title: 'Check-in Saved', 
                     message: 'Your daily diagnostic data has been vaulted successfully.'
                   );
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

