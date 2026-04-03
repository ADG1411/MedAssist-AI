// Food Detail Screen  ported from OpenNutriTracker MealDetailScreen
// Adapted for MedAssist: Riverpod, MedAssist theme, Supabase backend
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  final MealEntity meal;
  final MealType? initialMealType;

  const FoodDetailScreen({
    super.key,
    required this.meal,
    this.initialMealType,
  });

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  late double _amountG;
  late MealType _selectedMealType;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _amountG = widget.meal.servingQuantity ?? 100.0;
    _selectedMealType = widget.initialMealType ?? MealType.lunch;
  }

  double get _kcal => _amountG * (widget.meal.nutriments.energyPerUnit ?? 0);
  double get _carbs => _amountG * (widget.meal.nutriments.carbohydratesPerUnit ?? 0);
  double get _fat => _amountG * (widget.meal.nutriments.fatPerUnit ?? 0);
  double get _protein => _amountG * (widget.meal.nutriments.proteinsPerUnit ?? 0);

  Future<void> _addToDiary() async {
    setState(() => _isAdding = true);
    await ref.read(nutritionDiaryProvider.notifier).logFood(
      meal: widget.meal,
      mealType: _selectedMealType,
      amountG: _amountG,
      unit: 'g',
    );
    setState(() => _isAdding = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${widget.meal.name} to ${_selectedMealType.label}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          //  Collapsing App Bar with food image 
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  meal.name ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
                  background: meal.mainImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: meal.mainImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const _FoodPlaceholder(),
                          errorWidget: (context, url, error) => const _FoodPlaceholder(),
                        )
                      : const _FoodPlaceholder(),
                ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Food name + brand 
                    Text(meal.name ?? 'Unknown food',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    if (meal.brands != null) ...[
                      const SizedBox(height: 4),
                      Text(meal.brands!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                    if (meal.category != null) ...[
                      const SizedBox(height: 4),
                      Text(meal.category!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],

                    const SizedBox(height: 20),

                    //  Calorie ring + macros 
                    _CalorieCard(
                      kcal: _kcal,
                      carbs: _carbs,
                      fat: _fat,
                      protein: _protein,
                      amount: _amountG,
                    ),

                    const SizedBox(height: 24),

                    //  Amount Slider 
                    _AmountSlider(
                      amount: _amountG,
                      onChanged: (v) => setState(() => _amountG = v),
                    ),

                    const SizedBox(height: 24),

                    //  Meal type selector 
                    const Text('Add to',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 15)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: MealType.values.map((t) {
                        final selected = t == _selectedMealType;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMealType = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(t.icon, size: 16,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  t.label,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    //  Full nutrition table 
                    _NutritionTable(meal: meal, amountG: _amountG),

                    const SizedBox(height: 100), // space for bottom button
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),

      //  Add to diary button 
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isAdding ? null : _addToDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isAdding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Add ${_amountG.toInt()}g to ${_selectedMealType.label}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

//  Kcal Display Card 
class _CalorieCard extends StatelessWidget {
  final double kcal, carbs, fat, protein, amount;

  const _CalorieCard({
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7FFF), Color(0xFF5A9FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('${kcal.toInt()} kcal',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          Text('per ${amount.toInt()}g',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroStat(label: 'Carbs', value: carbs, unit: 'g'),
              _MacroStat(label: 'Fat', value: fat, unit: 'g'),
              _MacroStat(label: 'Protein', value: protein, unit: 'g'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label, unit;
  final double value;

  const _MacroStat({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(1)}$unit',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

//  Amount Slider 
class _AmountSlider extends StatelessWidget {
  final double amount;
  final ValueChanged<double> onChanged;

  const _AmountSlider({required this.amount, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Amount',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('${amount.toInt()} g',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
            inactiveTrackColor: AppColors.border,
          ),
          child: Slider(
            value: amount.clamp(5, 1000),
            min: 5,
            max: 1000,
            divisions: 199,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('5g', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('500g', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('1000g', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

//  Nutrition Table 
class _NutritionTable extends StatelessWidget {
  final MealEntity meal;
  final double amountG;

  const _NutritionTable({required this.meal, required this.amountG});

  @override
  Widget build(BuildContext context) {
    final n = meal.nutriments;
    factor(double? per100) => per100 != null ? amountG * per100 / 100 : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('Nutrition Facts',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary)),
          ),
          const Divider(height: 1, color: AppColors.border),
          _NutrientRow('Calories', factor(n.energyKcal100), 'kcal', bold: true),
          _NutrientRow('Carbohydrates', factor(n.carbohydrates100), 'g'),
          _NutrientRow('  of which Sugars', factor(n.sugars100), 'g', indent: true),
          _NutrientRow('Fat', factor(n.fat100), 'g'),
          _NutrientRow('  of which Saturated', factor(n.saturatedFat100), 'g', indent: true),
          _NutrientRow('Protein', factor(n.proteins100), 'g'),
          _NutrientRow('Fiber', factor(n.fiber100), 'g'),
          if (n.sodium100 != null) _NutrientRow('Sodium', factor(n.sodium100), 'g'),
          if (n.calcium100 != null) _NutrientRow('Calcium', factor(n.calcium100), 'mg'),
          if (n.iron100 != null) _NutrientRow('Iron', factor(n.iron100), 'mg'),
          if (n.vitaminC100 != null) _NutrientRow('Vitamin C', factor(n.vitaminC100), 'mg'),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final bool bold;
  final bool indent;

  const _NutrientRow(this.label, this.value, this.unit,
      {this.bold = false, this.indent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: indent ? 24 : 16, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: indent ? AppColors.textSecondary : AppColors.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              )),
          Text(
            value != null ? '${value!.toStringAsFixed(1)} $unit' : ' $unit',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

//  Food placeholder image 
class _FoodPlaceholder extends StatelessWidget {
  const _FoodPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softBlue,
      child: const Center(
        child: Icon(Icons.restaurant, size: 80, color: AppColors.primary),
      ),
    );
  }
}

