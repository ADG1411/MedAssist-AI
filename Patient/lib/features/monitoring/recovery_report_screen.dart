import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/recovery_gauge.dart';
import '../../shared/widgets/trend_chart.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/app_section_card.dart';

class RecoveryReportScreen extends StatelessWidget {
  const RecoveryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        title: const Text('Recovery Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Text('Day 5 Evaluation', style: TextStyle(color: AppColors.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            const RecoveryGauge(score: 89), // 89% score for the story
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('AI Precision Prediction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                        SizedBox(height: 4),
                        Text('Based on 5 days of data, you are projected to fully recover from this GERD flare-up in exactly 2 days with 89% confidence.', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const SectionHeader(title: 'Symptom Trend'),
            const SizedBox(height: 16),
            const AppSectionCard(
              child: TrendChart(
                dataPoints: [7.0, 5.5, 4.0, 2.5, 2.0], // Exactly mapped Pain Day 1 (7) -> Pain Day 5 (2)
              ),
            ),

            const SizedBox(height: 32),

            const SectionHeader(title: 'Correlation Analysis'),
            const SizedBox(height: 16),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     children: const [
                       Icon(Icons.water_drop, color: AppColors.softBlue, size: 20),
                       SizedBox(width: 8),
                       Text('Hydration is key', style: TextStyle(fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 8),
                   const Text('You raised your water intake from 3 cups on Day 1 to 8 cups today, correlating directly with diminished stomach friction and acid dilution.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                   const SizedBox(height: 16),
                   Row(
                     children: const [
                       Icon(Icons.monitor_heart, color: AppColors.danger, size: 20),
                       SizedBox(width: 8),
                       Text('Nutrition triggers identified', style: TextStyle(fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 8),
                   const Text("Consumption of 'Spicy Noodle' properties earlier in the week spiked your GERD baseline pain grading (7.0) compared to your current recovery state (2.0).", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

