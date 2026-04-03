import 'package:hive_flutter/hive_flutter.dart';
import '../cache_service.dart';
import '../cache_keys.dart';

/// Caches emergency medical data for offline SOS access.
/// This box MUST work without internet — it's life-critical.
class EmergencyCacheBox {
  EmergencyCacheBox._();

  static Box get _box => Hive.box(CacheBoxNames.emergency);

  /// Save complete emergency package: blood group, allergies, meds, contacts, hospital
  static Future<void> saveEmergencyPackage(Map<String, dynamic> data) async {
    await _box.put(CacheKeys.emergencyPackage, data);
    await _box.put(CacheKeys.lastSynced, DateTime.now().toIso8601String());
  }

  /// Get cached emergency package (works offline)
  static Map<String, dynamic>? getEmergencyPackage() {
    final data = _box.get(CacheKeys.emergencyPackage);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Whether we have emergency data available offline
  static bool get isAvailableOffline {
    return _box.containsKey(CacheKeys.emergencyPackage);
  }

  /// When was emergency data last synced
  static String? get lastSyncedAt {
    return _box.get(CacheKeys.lastSynced) as String?;
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
