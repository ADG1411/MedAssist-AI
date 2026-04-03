import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/monitoring_repository.dart';

final monitoringProvider = NotifierProvider<MonitoringNotifier, MonitoringState>(MonitoringNotifier.new);

class MonitoringState {
  final int hydrationCups;
  final double sleepHours;
  final double symptomSeverity;
  final String mood;
  final String quickStatus;
  final bool isSaving;

  const MonitoringState({
    this.hydrationCups = 0,
    this.sleepHours = 7.0,
    this.symptomSeverity = 5.0,
    this.mood = 'Neutral',
    this.quickStatus = 'Same',
    this.isSaving = false,
  });

  MonitoringState copyWith({
    int? hydrationCups,
    double? sleepHours,
    double? symptomSeverity,
    String? mood,
    String? quickStatus,
    bool? isSaving,
  }) {
    return MonitoringState(
      hydrationCups: hydrationCups ?? this.hydrationCups,
      sleepHours: sleepHours ?? this.sleepHours,
      symptomSeverity: symptomSeverity ?? this.symptomSeverity,
      mood: mood ?? this.mood,
      quickStatus: quickStatus ?? this.quickStatus,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class MonitoringNotifier extends Notifier<MonitoringState> {
  late final MonitoringRepository _repo;

  @override
  MonitoringState build() {
    _repo = ref.read(monitoringRepositoryProvider);
    return const MonitoringState();
  }

  void updateHydration(int cups) => state = state.copyWith(hydrationCups: cups.clamp(0, 8));
  
  void incrementHydration() {
    if (state.hydrationCups < 8) {
      state = state.copyWith(hydrationCups: state.hydrationCups + 1);
    }
  }

  void updateSleep(double hours) => state = state.copyWith(sleepHours: hours);
  void updateSeverity(double severity) => state = state.copyWith(symptomSeverity: severity);
  void updateMood(String mood) => state = state.copyWith(mood: mood);
  void updateQuickStatus(String status) => state = state.copyWith(quickStatus: status);

  Future<bool> saveDailyCheckin() async {
    state = state.copyWith(isSaving: true);
    try {
      final success = await _repo.saveDailyLog(
        sleepHours: state.sleepHours.toInt(),
        hydrationCups: state.hydrationCups,
        painLevel: state.symptomSeverity.toInt(),
        mood: state.mood,
      );
      state = state.copyWith(isSaving: false);
      return success;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}

