import 'package:hive_flutter/hive_flutter.dart';
import '../cache_service.dart';
import '../cache_keys.dart';

/// Caches recent AI diagnosis results for quick review.
class AiResultsBox {
  AiResultsBox._();

  static Box get _box => Hive.box(CacheBoxNames.aiResults);

  static Future<void> save(String resultId, Map<String, dynamic> result) async {
    await _box.put(resultId, result);
    // Maintain recent list
    final recent = getRecentIds();
    recent.insert(0, resultId);
    if (recent.length > 10) recent.removeLast();
    await _box.put(CacheKeys.recentResults, recent);
  }

  static Map<String, dynamic>? getById(String resultId) {
    final data = _box.get(resultId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  static List<String> getRecentIds({int limit = 10}) {
    final data = _box.get(CacheKeys.recentResults);
    if (data == null) return [];
    return List<String>.from(data as List).take(limit).toList();
  }

  static List<Map<String, dynamic>> getRecent({int limit = 10}) {
    final ids = getRecentIds(limit: limit);
    return ids
        .map((id) => getById(id))
        .where((r) => r != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
