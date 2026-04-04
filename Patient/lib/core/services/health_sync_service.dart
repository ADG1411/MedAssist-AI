import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/edge_function_service.dart';
import '../../features/health/providers/health_data_provider.dart';

class HealthSyncService {
  HealthSyncService._();

  /// Upsert today's health snapshot to Supabase
  static Future<void> syncToCloud(HealthMetrics metrics) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return;

      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final payload = {
        'user_id': userId,
        'snapshot_date': dateStr,
        ...metrics.toJson(),
      };

      await SupabaseService.client
          .from('health_snapshots')
          .upsert(payload, onConflict: 'user_id,snapshot_date');

      debugPrint('[HealthSync] Synced snapshot for $dateStr');
    } catch (e) {
      debugPrint('[HealthSync] Sync failed: $e');
    }
  }

  /// Trigger AI analysis of recent health data
  static Future<Map<String, dynamic>?> analyzeHealthTrends() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return null;

      final result = await EdgeFunctionService.invoke(
        'analyze-health-trends',
        body: {'user_id': userId},
      );

      if (result['success'] == true) {
        debugPrint('[HealthSync] AI analysis complete');
        return result;
      }
      return null;
    } catch (e) {
      debugPrint('[HealthSync] AI analysis failed: $e');
      return null;
    }
  }

  /// Sync health data and then trigger AI analysis
  static Future<Map<String, dynamic>?> syncAndAnalyze(HealthMetrics metrics) async {
    await syncToCloud(metrics);
    return await analyzeHealthTrends();
  }

  /// Get the latest AI insight from the DB
  static Future<Map<String, dynamic>?> getLatestInsight() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return null;

      final response = await SupabaseService.client
          .from('health_snapshots')
          .select('ai_insight, ai_risk_flags, health_score, snapshot_date')
          .eq('user_id', userId)
          .not('ai_insight', 'is', null)
          .order('snapshot_date', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('[HealthSync] getLatestInsight failed: $e');
      return null;
    }
  }
}
