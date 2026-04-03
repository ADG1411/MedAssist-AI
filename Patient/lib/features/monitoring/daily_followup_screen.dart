import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';

class DailyFollowupScreen extends StatefulWidget {
  const DailyFollowupScreen({super.key});

  @override
  State<DailyFollowupScreen> createState() => _DailyFollowupScreenState();
}

class _DailyFollowupScreenState extends State<DailyFollowupScreen> {
  String _symptoms = 'Same';
  bool _ateOnTime = true;
  bool _drankWater = true;
  String _sleep = 'Good';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Pulse Check', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How are your symptoms today?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildToggleRow(['Better', 'Same', 'Worse'], _symptoms, (v) => setState(() => _symptoms = v)),
                  
                  const SizedBox(height: 32),
                  const Text('Did you eat your meals on time?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildBoolBtn('Yes', _ateOnTime, AppColors.success, () => setState(() => _ateOnTime = true))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildBoolBtn('No', !_ateOnTime, AppColors.danger, () => setState(() => _ateOnTime = false))),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text('Hit your 8-cup water goal?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildBoolBtn('Yes', _drankWater, AppColors.success, () => setState(() => _drankWater = true))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildBoolBtn('No', !_drankWater, AppColors.danger, () => setState(() => _drankWater = false))),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text('Sleep quality last night?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildToggleRow(['Poor', 'Fair', 'Good'], _sleep, (v) => setState(() => _sleep = v)),

                  const SizedBox(height: 48),
                  AppButton(
                    text: 'Submit Check-in',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(List<String> options, String current, ValueChanged<String> onSelected) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(opt),
            child: Container(
              margin: EdgeInsets.only(right: opt != options.last ? 8.0 : 0.0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                opt,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBoolBtn(String label, bool isSelected, Color activeColor, VoidCallback onTap) {
     return GestureDetector(
       onTap: onTap,
       child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? activeColor : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
             label,
             style: TextStyle(
                color: isSelected ? activeColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
             ),
          ),
       ),
     );
  }
}

