// Nutrition Riverpod Providers  replaces Bloc from OpenNutriTracker
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/models/activity_entry.dart';
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/repository/nutrition_repository.dart';

// 
// Search state
// 

class NutritionSearchState {
  final String query;
  final List<MealEntity> results;
  final List<IntakeEntry> recentFoods;
  final bool isLoading;
  final String? error;

  const NutritionSearchState({
    this.query = '',
    this.results = const [],
    this.recentFoods = const [],
    this.isLoading = false,
    this.error,
  });

  NutritionSearchState copyWith({
    String? query,
    List<MealEntity>? results,
    List<IntakeEntry>? recentFoods,
    bool? isLoading,
    String? error,
  }) =>
      NutritionSearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        recentFoods: recentFoods ?? this.recentFoods,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class NutritionSearchNotifier extends Notifier<NutritionSearchState> {
  @override
  NutritionSearchState build() {
    // Load recent foods on init
    _loadRecents();
    return const NutritionSearchState();
  }

  Future<void> _loadRecents() async {
    final recent = await nutritionRepository.getRecentFoods();
    state = state.copyWith(recentFoods: recent);
  }

  Future<void> search(String query, {bool indianOnly = false}) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', results: [], isLoading: false);
      return;
    }
    state = state.copyWith(query: query, isLoading: true, error: null);
    try {
      final results = indianOnly
          ? await nutritionRepository.searchIndianOnly(query)
          : await nutritionRepository.searchFoods(query);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<MealEntity?> scanBarcode(String barcode) async {
    return nutritionRepository.scanBarcode(barcode);
  }

  void clear() => state = const NutritionSearchState();
}

final nutritionSearchProvider =
    NotifierProvider<NutritionSearchNotifier, NutritionSearchState>(
        NutritionSearchNotifier.new);

// 
// Daily diary state
// 

class NutritionDiaryState {
  final DateTime selectedDate;
  final DailySummary summary;
  final Map<MealType, List<IntakeEntry>> entries;
  final List<ActivityEntry> activities;
  final bool isLoading;
  final bool isLogging;

  const NutritionDiaryState({
    required this.selectedDate,
    required this.summary,
    this.entries = const {},
    this.activities = const [],
    this.isLoading = false,
    this.isLogging = false,
  });

  NutritionDiaryState copyWith({
    DateTime? selectedDate,
    DailySummary? summary,
    Map<MealType, List<IntakeEntry>>? entries,
    List<ActivityEntry>? activities,
    bool? isLoading,
    bool? isLogging,
  }) =>
      NutritionDiaryState(
        selectedDate: selectedDate ?? this.selectedDate,
        summary: summary ?? this.summary,
        entries: entries ?? this.entries,
        activities: activities ?? this.activities,
        isLoading: isLoading ?? this.isLoading,
        isLogging: isLogging ?? this.isLogging,
      );

  List<IntakeEntry> forMeal(MealType type) => entries[type] ?? [];
}

class NutritionDiaryNotifier extends Notifier<NutritionDiaryState> {
  @override
  NutritionDiaryState build() {
    final today = DateTime.now();
    // Schedule data load immediately via microtask so state update is not lost
    Future.microtask(() => _loadDay(today));
    return NutritionDiaryState(
      selectedDate: today,
      summary: DailySummary.empty(today),
      isLoading: true,
    );
  }

  Future<void> _loadDay(DateTime date) async {
    state = state.copyWith(isLoading: true);
    final summary = await nutritionRepository.getDailySummary(date);
    final entries = await nutritionRepository.getDailyLogs(date);
    final activities = await nutritionRepository.getActivitiesForDay(date);
    state = state.copyWith(isLoading: false, summary: summary, entries: entries, activities: activities);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date, summary: DailySummary.empty(date), entries: {});
    _loadDay(date);
  }

  Future<void> logFood({
    required MealEntity meal,
    required MealType mealType,
    required double amountG,
    String unit = 'g',
  }) async {
    state = state.copyWith(isLogging: true);
    await nutritionRepository.logFood(
      meal: meal,
      mealType: mealType,
      amountG: amountG,
      unit: unit,
      date: state.selectedDate,
    );
    await _loadDay(state.selectedDate);
    state = state.copyWith(isLogging: false);
  }

  Future<void> deleteEntry(String entryId) async {
    await nutritionRepository.deleteEntry(entryId);
    await _loadDay(state.selectedDate);
  }

  Future<void> logActivity(ActivityEntry activity) async {
    state = state.copyWith(isLogging: true);
    await nutritionRepository.logActivity(activity);
    await _loadDay(state.selectedDate);
    state = state.copyWith(isLogging: false);
  }

  void refresh() => _loadDay(state.selectedDate);
}

final nutritionDiaryProvider =
    NotifierProvider<NutritionDiaryNotifier, NutritionDiaryState>(
        NutritionDiaryNotifier.new);

