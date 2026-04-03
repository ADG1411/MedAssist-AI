// Ported from OpenNutriTracker MealEntity
// Adapted for MedAssist  supports OFF, FDC, IFCT (Indian) and custom sources
import 'package:equatable/equatable.dart';
import 'package:medassist_ai/features/nutrition/models/meal_nutriments.dart';

enum MealSource { off, fdc, indian, custom, unknown }

class MealEntity extends Equatable {
  static const liquidUnits = {'ml', 'l', 'dl', 'cl', 'fl oz'};
  static const solidUnits = {'kg', 'g', 'mg', 'oz'};

  final String? code;
  final String? name;
  final String? brands;
  final String? category;
  final String? thumbnailImageUrl;
  final String? mainImageUrl;
  final String? url;
  final String? mealQuantity;
  final String? mealUnit;
  final double? servingQuantity;
  final String? servingUnit;
  final String? servingSize;
  final MealSource source;
  final MealNutriments nutriments;

  bool get hasServingValues => servingQuantity != null && servingUnit != null;
  bool get isLiquid => liquidUnits.contains(mealUnit);
  bool get isSolid => solidUnits.contains(mealUnit);

  const MealEntity({
    required this.code,
    required this.name,
    this.brands,
    this.category,
    this.thumbnailImageUrl,
    this.mainImageUrl,
    this.url,
    required this.mealQuantity,
    required this.mealUnit,
    required this.servingQuantity,
    required this.servingUnit,
    required this.servingSize,
    required this.nutriments,
    required this.source,
  });

  factory MealEntity.empty() => MealEntity(
        code: null,
        name: null,
        mealQuantity: null,
        mealUnit: 'g',
        servingQuantity: null,
        servingUnit: 'g',
        servingSize: null,
        nutriments: MealNutriments.empty(),
        source: MealSource.custom,
      );

  /// From OpenFoodFacts product JSON
  factory MealEntity.fromOFFJson(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    return MealEntity(
      code: product['code'] ?? product['_id'],
      name: product['product_name_en'] ?? product['product_name'] ?? product['generic_name'],
      brands: product['brands'],
      category: product['categories_tags']?.first?.toString().replaceAll('en:', ''),
      thumbnailImageUrl: product['image_front_thumb_url'] ?? product['image_thumb_url'],
      mainImageUrl: product['image_front_url'] ?? product['image_url'],
      url: product['url'],
      mealQuantity: product['product_quantity']?.toString(),
      mealUnit: _extractUnit(product['quantity']?.toString()),
      servingQuantity: _parseDouble(product['serving_quantity']),
      servingUnit: _extractUnit(product['quantity']?.toString()),
      servingSize: product['serving_size'],
      nutriments: MealNutriments.fromOFFJson(nutriments),
      source: MealSource.off,
    );
  }

  /// From USDA FoodData Central food JSON
  factory MealEntity.fromFDCJson(Map<String, dynamic> food) {
    final fdcId = food['fdcId']?.toString();
    return MealEntity(
      code: fdcId,
      name: food['description'],
      brands: food['brandName'] ?? food['brandOwner'],
      category: food['foodCategory'],
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: fdcId != null ? 'https://fdc.nal.usda.gov/fdc-app.html#/food-details/$fdcId/nutrients' : null,
      mealQuantity: food['packageWeight'],
      mealUnit: food['servingSizeUnit'] ?? 'g',
      servingQuantity: (food['servingSize'] as num?)?.toDouble(),
      servingUnit: food['servingSizeUnit'] ?? 'g',
      servingSize: food['servingSizeUnit'],
      nutriments: MealNutriments.fromFDCNutrients(
        (food['foodNutrients'] as List<dynamic>?) ?? [],
      ),
      source: MealSource.fdc,
    );
  }

  /// From Supabase Indian food (IFCT) table
  factory MealEntity.fromIndianDB(Map<String, dynamic> data) {
    return MealEntity(
      code: data['food_code']?.toString(),
      name: data['food_name'],
      brands: null,
      category: data['food_category'],
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: 100,
      servingUnit: 'g',
      servingSize: '100g',
      nutriments: MealNutriments.fromSupabase(data),
      source: MealSource.indian,
    );
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  static String? _extractUnit(String? quantityStr) {
    if (quantityStr == null) return 'g';
    if (quantityStr.toUpperCase().contains('L') && !quantityStr.toUpperCase().contains('KG')) {
      return 'ml';
    }
    return 'g';
  }

  @override
  List<Object?> get props => [code, name, source];
}

