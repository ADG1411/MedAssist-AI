import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

final monitoringRepositoryProvider = Provider((ref) => MonitoringRepository());

class MonitoringRepository {
  bool get useMock => false; // dotenv.env['USE_MOCK'] == 'true';

  Future<bool> saveDailyLog({
    required int sleepHours,
    required int hydrationCups,
    required int painLevel,
    required String mood,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return false;

    await SupabaseService.client.from('monitoring_logs').upsert({
      'user_id': userId,
      'sleep_hours': sleepHours,
      'hydration_cups': hydrationCups,
      'symptom_severity': painLevel,
      'mood': mood,
      'logged_date': DateTime.now().toIso8601String().substring(0, 10),
    }, onConflict: 'user_id,logged_date');
    return true;
  }

  Future<List<Map<String, dynamic>>> getTrend({int days = 7}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return [
        {'logged_date': '2026-03-28', 'symptom_severity': 7, 'hydration_cups': 3, 'sleep_hours': 5},
        {'logged_date': '2026-03-29', 'symptom_severity': 5.5, 'hydration_cups': 5, 'sleep_hours': 6},
        {'logged_date': '2026-03-30', 'symptom_severity': 4, 'hydration_cups': 6, 'sleep_hours': 7},
        {'logged_date': '2026-03-31', 'symptom_severity': 2.5, 'hydration_cups': 7, 'sleep_hours': 7.5},
        {'logged_date': '2026-04-01', 'symptom_severity': 2, 'hydration_cups': 8, 'sleep_hours': 8},
      ];
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseService.client
        .from('monitoring_logs')
        .select()
        .eq('user_id', userId)
        .order('logged_date', ascending: false)
        .limit(days);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getTodayLog() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return null;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await SupabaseService.client
        .from('monitoring_logs')
        .select()
        .eq('user_id', userId)
        .eq('logged_date', today)
        .maybeSingle();
  }
}

