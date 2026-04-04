import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/edge_function_service.dart';

final nutritionRepositoryProvider = Provider((ref) => NutritionRepository());

class NutritionRepository {
  bool get useMock => false // dotenv.env['USE_MOCK'] == 'true';

  /// Calls the nutrition-vision Edge Function with a base64 image
  Future<Map<String, dynamic>> scanFoodImage(String base64Image) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return {
        'detected_items': [
          {
            'name': 'Roti',
            'per_unit_label': '1 piece',
            'calories': 71,
            'carbs_g': 15,
            'protein_g': 2.5,
            'fat_g': 1,
            'sodium_mg': 120,
            'fiber_g': 1.8,
          },
          {
            'name': 'Dal Tadka',
            'per_unit_label': '1 bowl',
            'calories': 180,
            'carbs_g': 20,
            'protein_g': 9,
            'fat_g': 7,
            'sodium_mg': 450,
            'fiber_g': 4,
          },
        ],
        'meal_description': 'Roti with Dal Tadka',
      };
    }
    return await EdgeFunctionService.invoke(
      'nutrition-vision',
      body: {'image': base64Image},
    );
  }

  /// Log a confirmed meal after portion selection
  Future<void> logMeal({
    required String foodName,
    required int calories,
    required int sodiumMg,
    required int portionCount,
    required String mealType,
    required bool isSafe,
    String? reason,
    String? imageUrl,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    await SupabaseService.client.from('nutrition_logs').insert({
      'user_id': userId,
      'food_name': foodName,
      'calories': calories * portionCount,
      'sodium_mg': sodiumMg * portionCount,
      'portion_count': portionCount,
      'total_calories': calories * portionCount,
      'total_sodium_mg': sodiumMg * portionCount,
      'meal_type': mealType,
      'is_safe': isSafe,
      'reason': reason,
      'image_url': imageUrl,
    });
  }

  /// Get today's meal history
  Future<List<Map<String, dynamic>>> getMealHistory({int days = 1}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return [];
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseService.client
        .from('nutrition_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get unsafe meals (for Deep Check correlation)
  Future<List<Map<String, dynamic>>> getUnsafeMeals({int limit = 10}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        {'food_name': 'Spicy Noodles', 'reason': 'High sodium triggers GERD', 'created_at': '2026-03-30'},
      ];
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseService.client
        .from('nutrition_logs')
        .select('food_name, reason, created_at')
        .eq('user_id', userId)
        .eq('is_safe', false)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }
}

