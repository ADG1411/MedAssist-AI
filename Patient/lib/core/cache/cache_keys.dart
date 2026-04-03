/// Typed key constants for cache entries within boxes.
abstract class CacheKeys {
  // Profile box keys
  static const profileData = 'profile_data';
  static const onboardingCompleted = 'onboarding_completed';

  // Chat history box keys
  static const recentSessions = 'recent_sessions';

  // AI results box keys
  static const recentResults = 'recent_results';

  // Nutrition box keys
  static const todayMeals = 'today_meals';
  static const todayDate = 'today_date';

  // Emergency box keys
  static const emergencyPackage = 'emergency_package';
  static const lastSynced = 'emergency_last_synced';

  // Records box keys
  static const recordsList = 'records_list';

  // Sync queue keys
  static const pendingOps = 'pending_operations';

  // Feature flags
  static const flagsMap = 'flags_map';
  static const flagsLastFetched = 'flags_last_fetched';
}
