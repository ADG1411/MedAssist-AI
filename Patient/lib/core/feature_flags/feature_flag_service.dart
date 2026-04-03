import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/supabase_service.dart';
import '../cache/cache_service.dart';
import '../cache/cache_keys.dart';

/// Known feature flag keys.
abstract class FeatureFlags {
  static const doctorConsult = 'doctor_consult';
  static const razorpayPayments = 'razorpay_payments';
  static const ocrExtraction = 'ocr_extraction';
  static const healthConnect = 'health_connect';
  static const sosGps = 'sos_gps';
  static const medicineInteractions = 'medicine_interactions';
  static const pushNotifications = 'push_notifications';
  static const jitsiVideo = 'jitsi_video';
}

/// Fetches feature flags from Supabase with Hive offline fallback.
class FeatureFlagNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    // Load from cache immediately, then refresh from server
    final cached = _loadFromCache();
    _refreshFromServer();
    return cached;
  }

  /// Check if a specific flag is enabled
  bool isEnabled(String key) => state[key] ?? false;

  /// Force refresh from Supabase
  Future<void> refresh() async {
    await _refreshFromServer();
  }

  Map<String, bool> _loadFromCache() {
    try {
      final box = Hive.box(CacheBoxNames.featureFlags);
      final data = box.get(CacheKeys.flagsMap);
      if (data != null) {
        return Map<String, bool>.from(data as Map);
      }
    } catch (_) {}
    return {};
  }

  Future<void> _refreshFromServer() async {
    try {
      final response = await SupabaseService.client
          .from('feature_flags')
          .select('key, enabled');

      final flags = <String, bool>{};
      for (final row in response) {
        flags[row['key'] as String] = row['enabled'] as bool? ?? false;
      }

      // Cache in Hive
      final box = Hive.box(CacheBoxNames.featureFlags);
      await box.put(CacheKeys.flagsMap, flags);
      await box.put(CacheKeys.flagsLastFetched, DateTime.now().toIso8601String());

      state = flags;
    } catch (_) {
      // Server unreachable — keep using cached/default values
    }
  }
}

/// Riverpod provider for feature flags.
final featureFlagProvider =
    NotifierProvider<FeatureFlagNotifier, Map<String, bool>>(
        FeatureFlagNotifier.new);
