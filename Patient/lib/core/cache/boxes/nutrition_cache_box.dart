import 'package:hive_flutter/hive_flutter.dart';
import '../cache_service.dart';
import '../cache_keys.dart';

/// Caches today's nutrition meals for fast dashboard loading.
class NutritionCacheBox {
  NutritionCacheBox._();

  static Box get _box => Hive.box(CacheBoxNames.nutrition);

  static Future<void> saveTodayMeals(List<Map<String, dynamic>> meals) async {
    await _box.put(CacheKeys.todayMeals, meals);
    await _box.put(CacheKeys.todayDate, DateTime.now().toIso8601String().split('T')[0]);
  }

  static List<Map<String, dynamic>> getTodayMeals() {
    final cachedDate = _box.get(CacheKeys.todayDate) as String?;
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (cachedDate != today) return []; // stale cache
    final data = _box.get(CacheKeys.todayMeals);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
