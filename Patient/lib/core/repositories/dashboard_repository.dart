import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

class DashboardRepository {
  bool get useMock => dotenv.env['USE_MOCK'] == 'true';

  /// Aggregates all dashboard data in parallel
  Future<Map<String, dynamic>> getDashboardData() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'health_score': 78,
        'latest_ai_result': {
          'condition': 'GERD Flare-up',
          'confidence': 78,
          'risk': 'Medium',
        },
        'latest_monitoring': {
          'hydration_cups': 6,
          'sleep_hours': 7,
          'symptom_severity': 3,
          'mood': 'Good',
        },

        'upcoming_appointments': [
          {'doctor': 'Dr. Sarah Jenkins', 'time': 'Tomorrow, 10:00 AM', 'type': 'Cardiology Follow-up'},
        ],
        'medication_reminders': [
          {'name': 'Lisinopril 10mg', 'time': '08:00 AM', 'taken': true},
          {'name': 'Atorvastatin 20mg', 'time': '08:00 PM', 'taken': false},
        ],
        'unsafe_meal': {
          'food_name': 'Spicy Chicken Wings',
          'conflict': 'High fat content triggers GERD',
        },
        'recovery_score': 85,
        'recovery_velocity': [75, 78, 80, 82, 85],
        'wearable_sync': {
          'status': true,
          'steps': 6430,
          'last_sync': '10 mins ago',
        },
        'profile_nudge': false,
        'recent_lab': 'Blood Panel (lipid) processed',
        'emergency_preparedness': true,
      };
    }

    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      return {'health_score': 0};
    }

    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Run all queries in parallel
    final results = await Future.wait([
      // 0: Latest AI result
      SupabaseService.client
          .from('ai_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1),
      // 1: Latest monitoring log
      SupabaseService.client
          .from('monitoring_logs')
          .select()
          .eq('user_id', userId)
          .order('logged_date', ascending: false)
          .limit(1),
      // 2: Today's nutrition summary
      SupabaseService.client
          .from('nutrition_daily_summary')
          .select()
          .eq('user_id', userId)
          .eq('summary_date', todayStr)
          .maybeSingle(),
      // 4: Latest recovery prediction
      SupabaseService.client
          .from('recovery_predictions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1),
      // 5: Profile Data
      SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle(),
    ]);

    final aiResults = List<Map<String, dynamic>>.from((results[0] as List?) ?? []);
    final monitoringLogs = List<Map<String, dynamic>>.from((results[1] as List?) ?? []);
    final nutritionSummary = results[2] as Map<String, dynamic>?;
    final recoveryPreds = List<Map<String, dynamic>>.from((results[3] as List?) ?? []);
    final profileData = results[4] as Map<String, dynamic>?;

    // ── Compute Health Score ──
    // Weighted: Calorie Adherence (40%) + Macro Balance (30%) + Activity (15%) + Vitals (15%)
    int healthScore = _computeHealthScore(nutritionSummary, monitoringLogs);

    final bool isProfileComplete = profileData?['onboarding_completed'] == true;
    final List<dynamic>? emergencyContacts = profileData?['emergency_contacts'] as List<dynamic>?;
    final bool isEmergencyActive = emergencyContacts != null && emergencyContacts.isNotEmpty;

    return {
      'health_score': healthScore,
      'nutrition_summary': nutritionSummary,
      'latest_ai_result': aiResults.isNotEmpty
          ? {
              'condition': (aiResults.first['conditions'] as List?)?.isNotEmpty == true
                  ? (aiResults.first['conditions'] as List).first['name']
                  : 'No conditions',
              'confidence': (aiResults.first['conditions'] as List?)?.isNotEmpty == true
                  ? (aiResults.first['conditions'] as List).first['confidence']
                  : 0,
              'risk': aiResults.first['risk_level'] ?? 'Low',
            }
          : null,
      'latest_monitoring': monitoringLogs.isNotEmpty ? monitoringLogs.first : null,

      'unsafe_meal': null,
      'recovery_score': recoveryPreds.isNotEmpty
          ? recoveryPreds.first['current_score']
          : 70,
      'upcoming_appointments': [], // Mock for now
      'medication_reminders': [], // Mock for now
      'recovery_velocity': [70, 72, 71, 75, 76], // Mock for now
      'wearable_sync': {'status': false, 'steps': 0, 'last_sync': 'Never synced'},
      'profile_nudge': !isProfileComplete,
      'recent_lab': 'No recent labs uploaded',
      'emergency_preparedness': isEmergencyActive,
    };
  }

  /// Smart health score based on real nutrition + monitoring data
  int _computeHealthScore(
    Map<String, dynamic>? nutrition,
    List<Map<String, dynamic>> monitoringLogs,
  ) {
    double score = 50; // baseline for no data

    if (nutrition != null) {
      final calorieGoal = (nutrition['calorie_goal'] as num?)?.toDouble() ?? 2000;
      final caloriesLogged = (nutrition['calories_logged'] as num?)?.toDouble() ?? 0;
      final carbsGoal = (nutrition['carbs_goal'] as num?)?.toDouble() ?? 250;
      final carbsLogged = (nutrition['carbs_logged'] as num?)?.toDouble() ?? 0;
      final fatGoal = (nutrition['fat_goal'] as num?)?.toDouble() ?? 65;
      final fatLogged = (nutrition['fat_logged'] as num?)?.toDouble() ?? 0;
      final proteinGoal = (nutrition['protein_goal'] as num?)?.toDouble() ?? 50;
      final proteinLogged = (nutrition['protein_logged'] as num?)?.toDouble() ?? 0;
      final activityBurn = (nutrition['activity_burn_logged'] as num?)?.toDouble() ?? 0;
      final netCalories = caloriesLogged - activityBurn;

      // 1. Calorie adherence (40 pts) - how close net calories are to goal
      //    Perfect = within 10% of goal, linearly drops to 0 at 50%+ deviation
      if (calorieGoal > 0 && caloriesLogged > 0) {
        final ratio = netCalories / calorieGoal;
        final deviation = (1.0 - ratio).abs();
        final calorieScore = (1.0 - (deviation / 0.5)).clamp(0.0, 1.0) * 40;
        score = calorieScore;
      } else {
        score = 0; // no food logged = 0 calorie points
      }

      // 2. Macro balance (30 pts) - average adherence across carbs, fat, protein
      if (caloriesLogged > 0) {
        double macroScore = 0;
        if (carbsGoal > 0) {
          macroScore += (1.0 - ((carbsLogged / carbsGoal) - 1.0).abs().clamp(0.0, 1.0)) * 10;
        }
        if (fatGoal > 0) {
          macroScore += (1.0 - ((fatLogged / fatGoal) - 1.0).abs().clamp(0.0, 1.0)) * 10;
        }
        if (proteinGoal > 0) {
          macroScore += (1.0 - ((proteinLogged / proteinGoal) - 1.0).abs().clamp(0.0, 1.0)) * 10;
        }
        score += macroScore;
      }

      // 3. Activity bonus (15 pts) - any logged activity is rewarded
      if (activityBurn > 0) {
        // 100 kcal burn = 5 pts, 300+ kcal = full 15 pts
        score += (activityBurn / 300.0).clamp(0.0, 1.0) * 15;
      }
    }

    // 4. Vitals/monitoring (15 pts) - from monitoring logs if available
    if (monitoringLogs.isNotEmpty) {
      final log = monitoringLogs.first;
      final severity = (log['symptom_severity'] as num?)?.toDouble() ?? 5;
      final hydration = (log['hydration_cups'] as num?)?.toDouble() ?? 4;
      final sleep = (log['sleep_hours'] as num?)?.toDouble() ?? 7;

      // Low severity = good (0-10 scale), good hydration (8 cups), good sleep (7-9h)
      double vitalScore = 0;
      vitalScore += ((10 - severity) / 10.0).clamp(0.0, 1.0) * 5; // pain: 5 pts
      vitalScore += (hydration / 8.0).clamp(0.0, 1.0) * 5; // hydration: 5 pts
      final sleepQuality = sleep >= 7 && sleep <= 9 ? 1.0 : (sleep >= 5 ? 0.5 : 0.2);
      vitalScore += sleepQuality * 5; // sleep: 5 pts
      score += vitalScore;
    }

    return score.round().clamp(0, 100);
  }
}

