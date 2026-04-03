import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

class HealthMetrics {
  final int steps;
  final int stepGoal;
  final double heartRate;
  final double sleepHours;
  final double sleepGoal;
  final double caloriesBurned;
  final double calorieGoal;
  final double bloodOxygen;
  final bool permissionGranted;
  final String? error;

  const HealthMetrics({
    this.steps = 0,
    this.stepGoal = 10000,
    this.heartRate = 0,
    this.sleepHours = 0,
    this.sleepGoal = 8.0,
    this.caloriesBurned = 0,
    this.calorieGoal = 500,
    this.bloodOxygen = 0,
    this.permissionGranted = false,
    this.error,
  });

  double get stepProgress => (steps / stepGoal).clamp(0.0, 1.0);
  double get sleepProgress => (sleepHours / sleepGoal).clamp(0.0, 1.0);
  double get calorieProgress => (caloriesBurned / calorieGoal).clamp(0.0, 1.0);

  int get computedScore {
    if (!permissionGranted) return 0;
    double score = 0;
    score += stepProgress * 30;
    score += sleepProgress * 30;
    score += calorieProgress * 20;
    if (heartRate > 0 && heartRate >= 50 && heartRate <= 100) score += 10;
    if (bloodOxygen >= 95) score += 10;
    return score.toInt().clamp(0, 100);
  }
}

class HealthDataNotifier extends AsyncNotifier<HealthMetrics> {
  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BLOOD_OXYGEN,
  ];

  @override
  Future<HealthMetrics> build() => _fetch();

  Future<HealthMetrics> _fetch() async {
    if (kIsWeb) {
      return const HealthMetrics(
        error: 'Health data not available on web. Run on Android or iOS.',
      );
    }

    try {
      final health = Health();
      await health.configure();

      final permissions = _types.map((_) => HealthDataAccess.READ).toList();
      final granted = await health.requestAuthorization(
        _types,
        permissions: permissions,
      );

      if (!granted) {
        return const HealthMetrics(
          error: 'Health permission denied. Tap to grant access.',
        );
      }

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final sleepWindowStart = midnight.subtract(const Duration(hours: 10));

      // Steps
      int steps = 0;
      try {
        steps = await health.getTotalStepsInInterval(midnight, now) ?? 0;
      } catch (_) {}

      // Heart Rate — latest reading today
      double heartRate = 0;
      try {
        final hrList = await health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [HealthDataType.HEART_RATE],
        );
        if (hrList.isNotEmpty) {
          final sorted = hrList..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          heartRate = (sorted.first.value as NumericHealthValue)
              .numericValue
              .toDouble();
        }
      } catch (_) {}

      // Sleep — sum all SLEEP_ASLEEP intervals from last night
      double sleepHours = 0;
      try {
        final sleepList = await health.getHealthDataFromTypes(
          startTime: sleepWindowStart,
          endTime: midnight,
          types: [HealthDataType.SLEEP_ASLEEP],
        );
        double totalMins = 0;
        for (final dp in sleepList) {
          totalMins += (dp.value as NumericHealthValue).numericValue;
        }
        sleepHours = totalMins / 60.0;
      } catch (_) {}

      // Calories burned
      double calories = 0;
      try {
        final calList = await health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        );
        for (final dp in calList) {
          calories += (dp.value as NumericHealthValue).numericValue;
        }
      } catch (_) {}

      // Blood Oxygen — latest today
      double spO2 = 0;
      try {
        final spO2List = await health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [HealthDataType.BLOOD_OXYGEN],
        );
        if (spO2List.isNotEmpty) {
          final sorted = spO2List..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          spO2 = (sorted.first.value as NumericHealthValue)
              .numericValue
              .toDouble();
        }
      } catch (_) {}

      return HealthMetrics(
        steps: steps,
        heartRate: heartRate,
        sleepHours: sleepHours,
        caloriesBurned: calories,
        bloodOxygen: spO2,
        permissionGranted: true,
      );
    } catch (e) {
      return HealthMetrics(error: 'Failed to load health data: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final healthDataProvider =
    AsyncNotifierProvider<HealthDataNotifier, HealthMetrics>(
  HealthDataNotifier.new,
);
