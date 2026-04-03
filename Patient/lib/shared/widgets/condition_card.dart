import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_section_card.dart';
import 'risk_badge.dart';

class ConditionCard extends StatelessWidget {
  final String conditionName;
  final int confidence;
  final String riskLevel;

  const ConditionCard({
    super.key,
    required this.conditionName,
    required this.confidence,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conditionName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: $confidence%',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          RiskBadge(risk: riskLevel),
        ],
      ),
    );
  }
}

