import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_section_card.dart';

class AppChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart; // E.g. LineChart or BarChart from fl_chart
  final double height;
  final Widget? trailing;

  const AppChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.height = 200.0,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: height,
            child: chart,
          ),
        ],
      ),
    );
  }
}

