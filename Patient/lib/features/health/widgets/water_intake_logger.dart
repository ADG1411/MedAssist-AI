import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../providers/health_data_provider.dart';

class WaterIntakeLogger extends ConsumerStatefulWidget {
  final int currentCups;

  const WaterIntakeLogger({super.key, required this.currentCups});

  @override
  ConsumerState<WaterIntakeLogger> createState() => _WaterIntakeLoggerState();
}

class _WaterIntakeLoggerState extends ConsumerState<WaterIntakeLogger>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fillAnim;
  bool _isLogging = false;

  static const int _goal = 8;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fillAnim = Tween<double>(
      begin: 0,
      end: (widget.currentCups / _goal).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant WaterIntakeLogger old) {
    super.didUpdateWidget(old);
    if (old.currentCups != widget.currentCups) {
      _fillAnim = Tween<double>(
        begin: _fillAnim.value,
        end: (widget.currentCups / _goal).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
      _animCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCup() async {
    if (_isLogging) return;
    setState(() => _isLogging = true);

    final success = await ref.read(healthDataProvider.notifier).logWaterIntake(0.25);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log water intake'), duration: Duration(seconds: 2)),
      );
    }

    if (mounted) setState(() => _isLogging = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const color = Color(0xFF3B82F6);

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.water_drop_rounded, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'Hydration',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.currentCups} / $_goal cups',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _fillAnim,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _fillAnim.value,
                minHeight: 8,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Water drop indicators
              ...List.generate(_goal, (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.water_drop_rounded,
                  size: 16,
                  color: i < widget.currentCups
                      ? color
                      : (isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0)),
                ),
              )),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLogging ? null : _addCup,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: _isLogging
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: color),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: color, size: 14),
                              SizedBox(width: 4),
                              Text('Add Cup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
