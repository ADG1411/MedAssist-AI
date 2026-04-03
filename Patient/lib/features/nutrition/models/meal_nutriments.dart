// Ported from OpenNutriTracker MealNutrimentsEntity
// Adapted for MedAssist  no Hive, no equatable deps beyond equatable package
import 'package:equatable/equatable.dart';

class MealNutriments extends Equatable {
  final double? energyKcal100;
  final double? carbohydrates100;
  final double? fat100;
  final double? proteins100;
  final double? sugars100;
  final double? saturatedFat100;
  final double? fiber100;
  final double? sodium100;
  final double? calcium100;
  final double? iron100;
  final double? vitaminC100;

  double? get energyPerUnit => _per100ToPerUnit(energyKcal100);
  double? get carbohydratesPerUnit => _per100ToPerUnit(carbohydrates100);
  double? get fatPerUnit => _per100ToPerUnit(fat100);
  double? get proteinsPerUnit => _per100ToPerUnit(proteins100);

  const MealNutriments({
    this.energyKcal100,
    this.carbohydrates100,
    this.fat100,
    this.proteins100,
    this.sugars100,
    this.saturatedFat100,
    this.fiber100,
    this.sodium100,
    this.calcium100,
    this.iron100,
    this.vitaminC100,
  });

  factory MealNutriments.empty() => const MealNutriments(
        energyKcal100: null,
        carbohydrates100: null,
        fat100: null,
        proteins100: null,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      );

  factory MealNutriments.fromOFFJson(Map<String, dynamic> nutriments) {
    double? parseVal(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return MealNutriments(
      energyKcal100: parseVal(nutriments['energy-kcal_100g'] ?? nutriments['energy_100g']),
      carbohydrates100: parseVal(nutriments['carbohydrates_100g']),
      fat100: parseVal(nutriments['fat_100g']),
      proteins100: parseVal(nutriments['proteins_100g']),
      sugars100: parseVal(nutriments['sugars_100g']),
      saturatedFat100: parseVal(nutriments['saturated-fat_100g']),
      fiber100: parseVal(nutriments['fiber_100g']),
      sodium100: parseVal(nutriments['sodium_100g']),
    );
  }

  factory MealNutriments.fromFDCNutrients(List<dynamic> nutrients) {
    double? getById(int id) {
      try {
        final match = nutrients.firstWhere(
          (n) => (n['nutrientId'] ?? n['number']) == id || (n['nutrient']?['id']) == id,
        );
        return (match['amount'] as num?)?.toDouble();
      } catch (_) {
        return null;
      }
    }

    return MealNutriments(
      energyKcal100: getById(1008) ?? getById(2047) ?? getById(2048),
      carbohydrates100: getById(1005),
      fat100: getById(1004),
      proteins100: getById(1003),
      sugars100: getById(2000),
      saturatedFat100: getById(1258),
      fiber100: getById(1079),
      sodium100: getById(1093),
      calcium100: getById(1087),
      iron100: getById(1089),
      vitaminC100: getById(1162),
    );
  }

  factory MealNutriments.fromSupabase(Map<String, dynamic> data) {
    return MealNutriments(
      energyKcal100: (data['calories_100g'] as num?)?.toDouble(),
      carbohydrates100: (data['carbs_100g'] as num?)?.toDouble(),
      fat100: (data['fat_100g'] as num?)?.toDouble(),
      proteins100: (data['protein_100g'] as num?)?.toDouble(),
      sugars100: (data['sugar_100g'] as num?)?.toDouble(),
      fiber100: (data['fiber_100g'] as num?)?.toDouble(),
      sodium100: (data['sodium_mg'] != null ? (data['sodium_mg'] as num).toDouble() / 1000 : null),
      calcium100: (data['calcium_mg'] as num?)?.toDouble(),
      iron100: (data['iron_mg'] as num?)?.toDouble(),
      vitaminC100: (data['vitamin_c_mg'] as num?)?.toDouble(),
    );
  }

  static double? _per100ToPerUnit(double? per100) {
    return per100 != null ? per100 / 100 : null;
  }

  @override
  List<Object?> get props => [
        energyKcal100,
        carbohydrates100,
        fat100,
        proteins100,
      ];
}

