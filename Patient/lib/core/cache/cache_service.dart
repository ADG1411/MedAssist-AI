import 'package:hive_flutter/hive_flutter.dart';

/// Central cache service — initializes Hive and manages all cache boxes.
class CacheService {
  CacheService._();

  static bool _initialized = false;

  /// Call once in main.dart before runApp()
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    // Open all boxes
    await Future.wait([
      Hive.openBox(CacheBoxNames.profile),
      Hive.openBox(CacheBoxNames.chatHistory),
      Hive.openBox(CacheBoxNames.aiResults),
      Hive.openBox(CacheBoxNames.nutrition),
      Hive.openBox(CacheBoxNames.emergency),
      Hive.openBox(CacheBoxNames.recordsMetadata),
      Hive.openBox(CacheBoxNames.syncQueue),
      Hive.openBox(CacheBoxNames.featureFlags),
    ]);

    _initialized = true;
  }

  /// Clear all cached data (call on logout)
  static Future<void> clearAll() async {
    final boxNames = [
      CacheBoxNames.profile,
      CacheBoxNames.chatHistory,
      CacheBoxNames.aiResults,
      CacheBoxNames.nutrition,
      CacheBoxNames.emergency,
      CacheBoxNames.recordsMetadata,
      CacheBoxNames.syncQueue,
      CacheBoxNames.featureFlags,
    ];
    for (final name in boxNames) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).clear();
      }
    }
  }

  /// Check if cache has been initialized
  static bool get isInitialized => _initialized;
}

/// All box name constants in one place
abstract class CacheBoxNames {
  static const profile = 'profile';
  static const chatHistory = 'chat_history';
  static const aiResults = 'ai_results';
  static const nutrition = 'nutrition';
  static const emergency = 'emergency';
  static const recordsMetadata = 'records_metadata';
  static const syncQueue = 'sync_queue';
  static const featureFlags = 'feature_flags';
}
