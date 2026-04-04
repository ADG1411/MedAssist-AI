import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

class DashboardRepository {
  bool get useMock => false // dotenv.env['USE_MOCK'] == 'true';

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
    // A comprehensive formula blending Clinical Baseline, Symptoms, AI Risk, Recovery speed, and Daily habits.
    int healthScore = _computeHealthScore(
      nutritionSummary: nutritionSummary,
      monitoringLog: monitoringLogs.isNotEmpty ? monitoringLogs.first : null,
      latestAiResult: aiResults.isNotEmpty ? aiResults.first : null,
      latestRecovery: recoveryPreds.isNotEmpty ? recoveryPreds.first : null,
      profileData: profileData,
    );

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

  /// Comprehensive clinical health score calculation
  int _computeHealthScore({
    Map<String, dynamic>? nutritionSummary,
    Map<String, dynamic>? monitoringLog,
    Map<String, dynamic>? latestAiResult,
    Map<String, dynamic>? latestRecovery,
    Map<String, dynamic>? profileData,
  }) {
    double totalScore = 0.0;
    double maxPossibleScore = 0.0;

    // ── 1. Clinical Baseline (Profile & AI Risk) [Max: 30 pts]
    double clinicalScore = 30; // Start perfect
    if (profileData != null) {
      final chronicConditions = profileData['chronic_conditions'] as List<dynamic>? ?? [];
      // Deduct 2 points per chronic condition (up to max -10)
      clinicalScore -= (chronicConditions.length * 2).clamp(0, 10).toDouble();
      
      final dynamic bmiRaw = profileData['bmi'];
      if (bmiRaw != null) {
        final bmi = (bmiRaw as num).toDouble();
        if (bmi < 18.5 || bmi > 30.0) clinicalScore -= 5;
        else if (bmi > 25.0) clinicalScore -= 2;
      }
    }
    
    if (latestAiResult != null) {
      final risk = (latestAiResult['risk_level']?.toString().toLowerCase()) ?? 'low';
      if (risk == 'high') clinicalScore -= 12;
      else if (risk == 'medium') clinicalScore -= 6;
      // if safe, no deduction
    }
    totalScore += clinicalScore.clamp(0.0, 30.0);
    maxPossibleScore += 30;

    // ── 2. Recovery & Healing Momentum [Max: 20 pts]
    if (latestRecovery != null) {
      final recScore = (latestRecovery['current_score'] as num?)?.toDouble() ?? 70;
      totalScore += (recScore / 100.0) * 20;
    } else {
      // Default baseline if no recovery active
      totalScore += 16; // 80% of 20
    }
    maxPossibleScore += 20;

    // ── 3. Vitals & Monitoring (Sleep, Hydration, Symptoms) [Max: 25 pts]
    if (monitoringLog != null) {
      final severity = (monitoringLog['symptom_severity'] as num?)?.toDouble() ?? 0;
      final hydration = (monitoringLog['hydration_cups'] as num?)?.toDouble() ?? 4;
      final sleep = (monitoringLog['sleep_hours'] as num?)?.toDouble() ?? 6;

      double vitalScore = 0;
      
      // Pain/Severity inversely correlated (0 severity = 10 pts, 10 severity = 0 pts)
      vitalScore += ((10 - severity) / 10.0).clamp(0.0, 1.0) * 10;
      
      // Hydration (8 cups = 7.5 pts max)
      vitalScore += (hydration / 8.0).clamp(0.0, 1.0) * 7.5;
      
      // Sleep (7-9 hr = perfect, otherwise proportional)
      if (sleep >= 7 && sleep <= 9) {
        vitalScore += 7.5;
      } else if (sleep >= 5 && sleep < 7) {
        vitalScore += 4.0;
      } else {
        vitalScore += 1.0;
      }
      
      totalScore += vitalScore;
    } else {
      // If hasn't logged today, give mild grace buffer (assume average)
      totalScore += 15; 
    }
    maxPossibleScore += 25;

    // ── 4. Daily Nutrition & Activity (Dynamic Weighting) [Max: 25 pts]
    if (nutritionSummary != null && (nutritionSummary['calories_logged'] as num?)?.toDouble() != null && nutritionSummary['calories_logged'] > 0) {
      final calorieGoal = (nutritionSummary['calorie_goal'] as num?)?.toDouble() ?? 2000;
      final caloriesLogged = (nutritionSummary['calories_logged'] as num?)?.toDouble() ?? 0;
      final activityBurn = (nutritionSummary['activity_burn_logged'] as num?)?.toDouble() ?? 0;
      final netCalories = caloriesLogged - activityBurn;

      double nutritionScore = 0;
      
      // Calorie Adherence (15 pts) - ±20% deviation is perfect
      final deviationRatio = (netCalories - calorieGoal).abs() / calorieGoal;
      if (deviationRatio <= 0.20) {
        nutritionScore += 15;
      } else if (deviationRatio <= 0.40) {
        nutritionScore += 10;
      } else if (deviationRatio <= 0.80) {
        nutritionScore += 5;
      }

      // Activity Bonus (10 pts)
      if (activityBurn >= 300) {
        nutritionScore += 10;
      } else {
        nutritionScore += (activityBurn / 300.0) * 10;
      }

      totalScore += nutritionScore;
      maxPossibleScore += 25;
    } else {
      // Early in the day, user hasn't logged food. 
      // Do NOT penalize the denominator fully. We just scale the current total.
      // We skip maxPossibleScore += 25 entirely so it doesn't drag the score down to 75%.
    }

    // Scale final score to exactly 100 points
    if (maxPossibleScore == 0) return 75; // Safety fallback
    
    final normalizedScore = (totalScore / maxPossibleScore) * 100;
    return normalizedScore.round().clamp(0, 100);
  }
}

