import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/repository/nutrition_repository.dart';

class NutritionHistoryState {
  final Map<DateTime, DailySummary> summaries;
  final bool isLoading;
  final DateTime focusedMonth;

  const NutritionHistoryState({
    this.summaries = const {},
    this.isLoading = false,
    required this.focusedMonth,
  });

  NutritionHistoryState copyWith({
    Map<DateTime, DailySummary>? summaries,
    bool? isLoading,
    DateTime? focusedMonth,
  }) => NutritionHistoryState(
    summaries: summaries ?? this.summaries,
    isLoading: isLoading ?? this.isLoading,
    focusedMonth: focusedMonth ?? this.focusedMonth,
  );
}

class NutritionHistoryNotifier extends Notifier<NutritionHistoryState> {
  @override
  NutritionHistoryState build() {
    final now = DateTime.now();
    final initial = NutritionHistoryState(focusedMonth: DateTime(now.year, now.month, 1));
    // Load current month on build
    Future.microtask(() => _loadMonth(initial.focusedMonth));
    return initial;
  }

  Future<void> _loadMonth(DateTime month) async {
    state = state.copyWith(isLoading: true, focusedMonth: month);
    final results = await nutritionRepository.getMonthlySummaries(month.year, month.month);
    
    final Map<DateTime, DailySummary> newSummaries = Map.of(state.summaries);
    for (var s in results) {
      // Normalize date to midnight for table calendar comparison
      final normalizedInfo = DateTime(s.date.year, s.date.month, s.date.day);
      newSummaries[normalizedInfo] = s;
    }
    
    state = state.copyWith(isLoading: false, summaries: newSummaries);
  }

  void changeMonth(DateTime newMonth) {
    if (newMonth.month != state.focusedMonth.month || newMonth.year != state.focusedMonth.year) {
      _loadMonth(newMonth);
    }
  }
}

final nutritionHistoryProvider = NotifierProvider<NutritionHistoryNotifier, NutritionHistoryState>(
  NutritionHistoryNotifier.new,
);

