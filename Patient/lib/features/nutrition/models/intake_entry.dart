import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/models/meal_nutriments.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExt on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast: return Icons.wb_sunny_outlined;
      case MealType.lunch: return Icons.light_mode;
      case MealType.dinner: return Icons.nights_stay_outlined;
      case MealType.snack: return Icons.apple;
    }
  }

  String get dbValue => name; // 'breakfast', 'lunch', 'dinner', 'snack'

  static MealType fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'breakfast': return MealType.breakfast;
      case 'lunch': return MealType.lunch;
      case 'dinner': return MealType.dinner;
      default: return MealType.snack;
    }
  }
}

class IntakeEntry extends Equatable {
  final String? id;
  final String? userId;
  final DateTime date;
  final MealType mealType;
  final MealEntity meal;
  final double amountG; // grams logged
  final String unit;

  // Pre-calculated values (used when loaded from DB)
  final double? _storedKcal;
  final double? _storedCarbs;
  final double? _storedFat;
  final double? _storedProtein;

  const IntakeEntry({
    this.id,
    this.userId,
    required this.date,
    required this.mealType,
    required this.meal,
    required this.amountG,
    required this.unit,
    double? storedKcal,
    double? storedCarbs,
    double? storedFat,
    double? storedProtein,
  })  : _storedKcal = storedKcal,
        _storedCarbs = storedCarbs,
        _storedFat = storedFat,
        _storedProtein = storedProtein;

  double get totalKcal => _storedKcal ?? amountG * (meal.nutriments.energyPerUnit ?? 0);
  double get totalCarbsG => _storedCarbs ?? amountG * (meal.nutriments.carbohydratesPerUnit ?? 0);
  double get totalFatG => _storedFat ?? amountG * (meal.nutriments.fatPerUnit ?? 0);
  double get totalProteinG => _storedProtein ?? amountG * (meal.nutriments.proteinsPerUnit ?? 0);

  /// Convert to Supabase insert payload
  Map<String, dynamic> toSupabaseInsert() => {
    'user_id': userId,
    'log_date': date.toIso8601String().split('T')[0],
    'meal_type': mealType.dbValue,
    'food_name': meal.name,
    'food_source': meal.source.name,
    'food_id': meal.code,
    'amount_g': amountG,
    'unit': unit,
    'calories': totalKcal,
    'carbs_g': totalCarbsG,
    'fat_g': totalFatG,
    'protein_g': totalProteinG,
    'fiber_g': amountG * (meal.nutriments.fiber100 != null ? meal.nutriments.fiber100! / 100 : 0),
    'sugar_g': amountG * (meal.nutriments.sugars100 != null ? meal.nutriments.sugars100! / 100 : 0),
  };

  /// From Supabase row (for diary display  meal lookup simplified)
  factory IntakeEntry.fromSupabase(Map<String, dynamic> row) {
    // Reconstruct minimal MealEntity from saved macros (no re-fetch needed)
    final meal = MealEntity(
      code: row['food_id'],
      name: row['food_name'] ?? 'Unknown food',
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: 100,
      servingUnit: 'g',
      servingSize: '100g',
      source: MealSource.values.firstWhere(
        (s) => s.name == row['food_source'], orElse: () => MealSource.unknown
      ),
      nutriments: MealNutriments.empty(),
    );

    return IntakeEntry(
      id: row['id'],
      userId: row['user_id'],
      date: DateTime.parse(row['log_date']),
      mealType: MealTypeExt.fromString(row['meal_type']),
      meal: meal,
      amountG: (row['amount_g'] as num?)?.toDouble() ?? 100,
      unit: row['unit'] ?? 'g',
      storedKcal: (row['calories'] as num?)?.toDouble(),
      storedCarbs: (row['carbs_g'] as num?)?.toDouble(),
      storedFat: (row['fat_g'] as num?)?.toDouble(),
      storedProtein: (row['protein_g'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, date, mealType, meal.code, amountG];
}

/// Daily nutrition summary  ported from TrackedDayEntity
class DailySummary {
  final DateTime date;
  final double calorieGoal;
  final double caloriesLogged;
  final double carbsGoal;
  final double carbsLogged;
  final double fatGoal;
  final double fatLogged;
  final double proteinGoal;
  final double proteinLogged;
  final double activityBurnLogged;

  const DailySummary({
    required this.date,
    this.calorieGoal = 2000,
    this.caloriesLogged = 0,
    this.carbsGoal = 250,
    this.carbsLogged = 0,
    this.fatGoal = 65,
    this.fatLogged = 0,
    this.proteinGoal = 50,
    this.proteinLogged = 0,
    this.activityBurnLogged = 0,
  });

  double get netCalories => caloriesLogged - activityBurnLogged;
  double get caloriesRemaining => calorieGoal - netCalories;
  double get calorieProgress => calorieGoal > 0 ? (netCalories / calorieGoal).clamp(0, 1) : 0;
  double get carbsProgress => carbsGoal > 0 ? (carbsLogged / carbsGoal).clamp(0, 1) : 0;
  double get fatProgress => fatGoal > 0 ? (fatLogged / fatGoal).clamp(0, 1) : 0;
  double get proteinProgress => proteinGoal > 0 ? (proteinLogged / proteinGoal).clamp(0, 1) : 0;

  DailySummary copyWith({
    double? caloriesLogged,
    double? carbsLogged,
    double? fatLogged,
    double? proteinLogged,
    double? activityBurnLogged,
  }) => DailySummary(
    date: date,
    calorieGoal: calorieGoal,
    caloriesLogged: caloriesLogged ?? this.caloriesLogged,
    carbsGoal: carbsGoal,
    carbsLogged: carbsLogged ?? this.carbsLogged,
    fatGoal: fatGoal,
    fatLogged: fatLogged ?? this.fatLogged,
    proteinGoal: proteinGoal,
    proteinLogged: proteinLogged ?? this.proteinLogged,
    activityBurnLogged: activityBurnLogged ?? this.activityBurnLogged,
  );

  factory DailySummary.empty(DateTime date) => DailySummary(date: date);
}

