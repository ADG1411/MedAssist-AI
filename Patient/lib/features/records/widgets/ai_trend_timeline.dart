import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/edge_function_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Shows chronological markers and a Kimi K2.5 longitudinal trend summary
class AiTrendTimeline extends ConsumerStatefulWidget {
  final String category;

  const AiTrendTimeline({super.key, required this.category});

  @override
  ConsumerState<AiTrendTimeline> createState() => _AiTrendTimelineState();
}

class _AiTrendTimelineState extends ConsumerState<AiTrendTimeline> {
  String? _trendInsight;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrendData();
  }

  Future<void> _loadTrendData() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return;

      final res = await EdgeFunctionService.invoke(
        'compare-medical-reports',
        body: {
          'category': widget.category,
          'user_id': userId,
        },
      );

      if (mounted) {
        setState(() {
          _trendInsight = res['insight'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _trendInsight = "Not enough data or AI analysis failed to process trend.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_trendInsight == null || _trendInsight!.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Trend Intelligence: ${widget.category}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Text(
              _trendInsight!,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.textSecondary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
