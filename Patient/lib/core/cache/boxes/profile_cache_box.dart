import 'package:hive_flutter/hive_flutter.dart';
import '../cache_service.dart';
import '../cache_keys.dart';

/// Caches the full patient profile for offline access.
class ProfileCacheBox {
  ProfileCacheBox._();

  static Box get _box => Hive.box(CacheBoxNames.profile);

  static Future<void> save(Map<String, dynamic> profile) async {
    await _box.put(CacheKeys.profileData, profile);
  }

  static Map<String, dynamic>? get() {
    final data = _box.get(CacheKeys.profileData);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  static bool get isOnboardingCompleted {
    return _box.get(CacheKeys.onboardingCompleted, defaultValue: false) as bool;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    await _box.put(CacheKeys.onboardingCompleted, value);
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
