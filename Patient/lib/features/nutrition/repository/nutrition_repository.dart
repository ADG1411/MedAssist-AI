// Nutrition Repository  Supabase backend + API cascade
// Replaces Hive from OpenNutriTracker with Supabase
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/models/activity_entry.dart';
import 'package:medassist_ai/features/nutrition/services/nutrition_api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionRepository {
  final _api = NutritionApiService();
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  // 
  // Food Search
  // 

  Future<List<MealEntity>> searchFoods(String query) => _api.searchAll(query);
  Future<List<MealEntity>> searchIndianOnly(String query) => _api.searchIndianFoods(query);
  Future<MealEntity?> scanBarcode(String barcode) => _api.fetchOFFByBarcode(barcode);

  // 
  // Log Food Entry
  // 

  Future<void> logFood({
    required MealEntity meal,
    required MealType mealType,
    required double amountG,
    required String unit,
    DateTime? date,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    final entry = IntakeEntry(
      userId: userId,
      date: date ?? DateTime.now(),
      mealType: mealType,
      meal: meal,
      amountG: amountG,
      unit: unit,
    );

    final payload = entry.toSupabaseInsert();

    // Insert log
    await _supabase.from('nutrition_logs').insert(payload);

    // Update or increment daily summary
    await _updateDailySummary(
      date: entry.date,
      userId: userId,
      caloriesDelta: entry.totalKcal,
      carbsDelta: entry.totalCarbsG,
      fatDelta: entry.totalFatG,
      proteinDelta: entry.totalProteinG,
    );
  }

  Future<void> _updateDailySummary({
    required DateTime date,
    required String userId,
    required double caloriesDelta,
    required double carbsDelta,
    required double fatDelta,
    required double proteinDelta,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    try {
      await _supabase.rpc('upsert_nutrition_summary', params: {
        'p_user_id': userId,
        'p_date': dateStr,
        'p_calories': caloriesDelta,
        'p_carbs': carbsDelta,
        'p_fat': fatDelta,
        'p_protein': proteinDelta,
      });
    } catch (_) {
      // fallback: manual upsert
      final existing = await _supabase
          .from('nutrition_daily_summary')
          .select()
          .eq('user_id', userId)
          .eq('summary_date', dateStr)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('nutrition_daily_summary').insert({
          'user_id': userId,
          'summary_date': dateStr,
          'calories_logged': caloriesDelta,
          'carbs_logged': carbsDelta,
          'fat_logged': fatDelta,
          'protein_logged': proteinDelta,
          'calorie_goal': 2000,
          'carbs_goal': 250,
          'fat_goal': 65,
          'protein_goal': 50,
        });
      } else {
        await _supabase
            .from('nutrition_daily_summary')
            .update({
              'calories_logged': ((existing['calories_logged'] as num?)?.toDouble() ?? 0) + caloriesDelta,
              'carbs_logged': ((existing['carbs_logged'] as num?)?.toDouble() ?? 0) + carbsDelta,
              'fat_logged': ((existing['fat_logged'] as num?)?.toDouble() ?? 0) + fatDelta,
              'protein_logged': ((existing['protein_logged'] as num?)?.toDouble() ?? 0) + proteinDelta,
            })
            .eq('user_id', userId)
            .eq('summary_date', dateStr);
      }
    }
  }

  // 
  // Get Daily Logs (grouped by meal type)
  // 

  Future<Map<MealType, List<IntakeEntry>>> getDailyLogs(DateTime date) async {
    final userId = _userId;
    if (userId == null) return {};

    final dateStr = date.toIso8601String().split('T')[0];
    final rows = await _supabase
        .from('nutrition_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', dateStr)
        .order('created_at');

    final Map<MealType, List<IntakeEntry>> grouped = {
      MealType.breakfast: [],
      MealType.lunch: [],
      MealType.dinner: [],
      MealType.snack: [],
    };

    for (final row in (rows as List)) {
      final entry = IntakeEntry.fromSupabase(row);
      grouped[entry.mealType]?.add(entry);
    }
    return grouped;
  }

  // 
  // Daily Summary
  // 

  Future<DailySummary> getDailySummary(DateTime date) async {
    final userId = _userId;
    if (userId == null) return DailySummary.empty(date);

    final dateStr = date.toIso8601String().split('T')[0];
    final row = await _supabase
        .from('nutrition_daily_summary')
        .select()
        .eq('user_id', userId)
        .eq('summary_date', dateStr)
        .maybeSingle();

    if (row == null) return DailySummary.empty(date);
    return DailySummary(
      date: date,
      calorieGoal: (row['calorie_goal'] as num?)?.toDouble() ?? 2000,
      caloriesLogged: (row['calories_logged'] as num?)?.toDouble() ?? 0,
      carbsGoal: (row['carbs_goal'] as num?)?.toDouble() ?? 250,
      carbsLogged: (row['carbs_logged'] as num?)?.toDouble() ?? 0,
      fatGoal: (row['fat_goal'] as num?)?.toDouble() ?? 65,
      fatLogged: (row['fat_logged'] as num?)?.toDouble() ?? 0,
      proteinGoal: (row['protein_goal'] as num?)?.toDouble() ?? 50,
      proteinLogged: (row['protein_logged'] as num?)?.toDouble() ?? 0,
      activityBurnLogged: (row['activity_burn_logged'] as num?)?.toDouble() ?? 0,
    );
  }

  // 
  // Delete Entry
  // 

  Future<void> deleteEntry(String entryId) async {
    final userId = _userId;
    if (userId == null) return;
    await _supabase
        .from('nutrition_logs')
        .delete()
        .eq('id', entryId)
        .eq('user_id', userId);
  }

  // 
  // Recent foods
  // 

  Future<List<IntakeEntry>> getRecentFoods({int limit = 15}) async {
    final userId = _userId;
    if (userId == null) return [];

    final rows = await _supabase
        .from('nutrition_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List).map((r) => IntakeEntry.fromSupabase(r)).toList();
  }

  // 
  // History Month Summaries
  // 

  Future<List<DailySummary>> getMonthlySummaries(int year, int month) async {
    final userId = _userId;
    if (userId == null) return [];

    // Construct simple string matches for the month 
    final startDate = DateTime(year, month, 1).toIso8601String().split('T')[0];
    final endDate = DateTime(year, month + 1, 0).toIso8601String().split('T')[0];

    final rows = await _supabase
        .from('nutrition_daily_summary')
        .select()
        .eq('user_id', userId)
        .gte('summary_date', startDate)
        .lte('summary_date', endDate);

    return (rows as List).map((row) => DailySummary(
      date: DateTime.parse(row['summary_date']),
      calorieGoal: (row['calorie_goal'] as num?)?.toDouble() ?? 2000,
      caloriesLogged: (row['calories_logged'] as num?)?.toDouble() ?? 0,
      carbsGoal: (row['carbs_goal'] as num?)?.toDouble() ?? 250,
      carbsLogged: (row['carbs_logged'] as num?)?.toDouble() ?? 0,
      fatGoal: (row['fat_goal'] as num?)?.toDouble() ?? 65,
      fatLogged: (row['fat_logged'] as num?)?.toDouble() ?? 0,
      proteinGoal: (row['protein_goal'] as num?)?.toDouble() ?? 50,
      proteinLogged: (row['protein_logged'] as num?)?.toDouble() ?? 0,
      activityBurnLogged: (row['activity_burn_logged'] as num?)?.toDouble() ?? 0,
    )).toList();
  }

  // 
  // Activity Logging
  // 

  Future<void> logActivity(ActivityEntry entry) async {
    final userId = _userId;
    if (userId == null) return;

    final dateStr = entry.date.toIso8601String().split('T')[0];

    // 1. Insert activity log
    await _supabase.from('physical_activity_logs').insert({
      'user_id': userId,
      'log_date': dateStr,
      'activity_code': entry.code,
      'activity_name': entry.name,
      'duration_min': entry.durationMin,
      'calories_burned': entry.caloriesBurned,
    });

    // 2. Update daily summary directly via RPC (activity_burn_logged = 0 for nutrition columns)
    await _supabase.rpc('upsert_nutrition_summary', params: {
      'p_user_id': userId,
      'p_date': dateStr,
      'p_calories': 0.0,
      'p_carbs': 0.0,
      'p_fat': 0.0,
      'p_protein': 0.0,
      'p_activity_burn': entry.caloriesBurned,
    });
  }

  Future<List<ActivityEntry>> getActivitiesForDay(DateTime date) async {
    final userId = _userId;
    if (userId == null) return [];

    final dateStr = date.toIso8601String().split('T')[0];
    final rows = await _supabase
        .from('physical_activity_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', dateStr);

    return (rows as List).map((r) => ActivityEntry.fromSupabase(r)).toList();
  }
}

final nutritionRepository = NutritionRepository();

