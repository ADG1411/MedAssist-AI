import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_bottom_sheet.dart';
import '../widgets/app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String currentSelection;
  final ValueChanged<String> onApply;

  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.currentSelection,
    required this.onApply,
  });

  static void show(BuildContext context, {
    required String title,
    required List<String> options,
    required String currentSelection,
    required ValueChanged<String> onApply,
  }) {
    AppBottomSheet.show(
      context: context,
      child: FilterBottomSheet(
        title: title,
        options: options,
        currentSelection: currentSelection,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = _selected == option;
                return InkWell(
                  onTap: () => setState(() => _selected = option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option, style: TextStyle(fontSize: 16)),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AppButton(
              text: 'Apply Filter',
              onPressed: () {
                widget.onApply(_selected);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

