import 'package:hive_flutter/hive_flutter.dart';
import '../cache_service.dart';
import '../cache_keys.dart';

/// Caches medical record metadata (titles, categories, dates) for offline browsing.
/// Does NOT cache file content — only metadata for listing.
class RecordsMetadataBox {
  RecordsMetadataBox._();

  static Box get _box => Hive.box(CacheBoxNames.recordsMetadata);

  static Future<void> saveRecords(List<Map<String, dynamic>> records) async {
    await _box.put(CacheKeys.recordsList, records);
  }

  static List<Map<String, dynamic>> getRecords() {
    final data = _box.get(CacheKeys.recordsList);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
