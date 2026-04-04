import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

class HealthMetrics {
  final int steps;
  final int stepGoal;
  final double heartRate;
  final double heartRateMin;
  final double heartRateMax;
  final double sleepHours;
  final double sleepGoal;
  final double caloriesBurned;
  final double calorieGoal;
  final double bloodOxygen;
  final double weight;
  final double bpSystolic;
  final double bpDiastolic;
  final double bloodGlucose;
  final double bodyTemperature;
  final double distanceMeters;
  final int waterCups;
  final double respiratoryRate;
  final double bodyFatPct;
  final int activeMinutes;
  final List<WorkoutSession> workouts;
  final bool permissionGranted;
  final String? error;

  const HealthMetrics({
    this.steps = 0,
    this.stepGoal = 10000,
    this.heartRate = 0,
    this.heartRateMin = 0,
    this.heartRateMax = 0,
    this.sleepHours = 0,
    this.sleepGoal = 8.0,
    this.caloriesBurned = 0,
    this.calorieGoal = 500,
    this.bloodOxygen = 0,
    this.weight = 0,
    this.bpSystolic = 0,
    this.bpDiastolic = 0,
    this.bloodGlucose = 0,
    this.bodyTemperature = 0,
    this.distanceMeters = 0,
    this.waterCups = 0,
    this.respiratoryRate = 0,
    this.bodyFatPct = 0,
    this.activeMinutes = 0,
    this.workouts = const [],
    this.permissionGranted = false,
    this.error,
  });

  double get stepProgress => (steps / stepGoal).clamp(0.0, 1.0);
  double get sleepProgress => (sleepHours / sleepGoal).clamp(0.0, 1.0);
  double get calorieProgress => (caloriesBurned / calorieGoal).clamp(0.0, 1.0);
  double get distanceKm => distanceMeters / 1000.0;

  int get computedScore {
    if (!permissionGranted) return 0;
    double score = 0;
    score += stepProgress * 20;
    score += sleepProgress * 20;
    score += calorieProgress * 10;
    if (heartRate > 0 && heartRate >= 50 && heartRate <= 100) score += 10;
    if (bloodOxygen >= 95) score += 10;
    if (bpSystolic > 0 && bpSystolic <= 130 && bpDiastolic <= 85) score += 10;
    if (bloodGlucose > 0 && bloodGlucose >= 70 && bloodGlucose <= 140) score += 5;
    if (waterCups >= 6) score += 5;
    if (activeMinutes >= 30) score += 5;
    if (bodyTemperature > 0 && bodyTemperature >= 36.0 && bodyTemperature <= 37.5) score += 5;
    return score.toInt().clamp(0, 100);
  }

  Map<String, dynamic> toJson() => {
    'steps': steps,
    'heart_rate_avg': heartRate,
    'heart_rate_min': heartRateMin > 0 ? heartRateMin : null,
    'heart_rate_max': heartRateMax > 0 ? heartRateMax : null,
    'sleep_hours': sleepHours,
    'calories_burned': caloriesBurned,
    'blood_oxygen': bloodOxygen,
    'weight_kg': weight > 0 ? weight : null,
    'bp_systolic': bpSystolic > 0 ? bpSystolic : null,
    'bp_diastolic': bpDiastolic > 0 ? bpDiastolic : null,
    'blood_glucose': bloodGlucose > 0 ? bloodGlucose : null,
    'body_temperature': bodyTemperature > 0 ? bodyTemperature : null,
    'distance_meters': distanceMeters,
    'water_cups': waterCups,
    'respiratory_rate': respiratoryRate > 0 ? respiratoryRate : null,
    'body_fat_pct': bodyFatPct > 0 ? bodyFatPct : null,
    'active_minutes': activeMinutes,
    'workout_count': workouts.length,
    'health_score': computedScore,
  };
}

class WorkoutSession {
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final double caloriesBurned;

  const WorkoutSession({
    required this.type,
    required this.startTime,
    required this.endTime,
    this.caloriesBurned = 0,
  });

  Duration get duration => endTime.difference(startTime);
}

class HealthDataNotifier extends AsyncNotifier<HealthMetrics> {
  static const _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.WEIGHT,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.WATER,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.WORKOUT,
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

      final permissions = _readTypes.map((_) => HealthDataAccess.READ).toList();
      final granted = await health.requestAuthorization(
        _readTypes,
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

      // Heart Rate
      double heartRate = 0, hrMin = 0, hrMax = 0;
      try {
        final hrList = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.HEART_RATE],
        );
        if (hrList.isNotEmpty) {
          final sorted = hrList..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          heartRate = (sorted.first.value as NumericHealthValue).numericValue.toDouble();
          final values = sorted.map((e) => (e.value as NumericHealthValue).numericValue.toDouble()).toList();
          hrMin = values.reduce((a, b) => a < b ? a : b);
          hrMax = values.reduce((a, b) => a > b ? a : b);
        }
      } catch (_) {}

      // Sleep
      double sleepHours = 0;
      try {
        final sleepList = await health.getHealthDataFromTypes(
          startTime: sleepWindowStart, endTime: midnight,
          types: [HealthDataType.SLEEP_ASLEEP],
        );
        double totalMins = 0;
        for (final dp in sleepList) {
          totalMins += (dp.value as NumericHealthValue).numericValue;
        }
        sleepHours = totalMins / 60.0;
      } catch (_) {}

      // Calories
      double calories = 0;
      try {
        final calList = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        );
        for (final dp in calList) {
          calories += (dp.value as NumericHealthValue).numericValue;
        }
      } catch (_) {}

      // Blood Oxygen
      double spO2 = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.BLOOD_OXYGEN],
        );
        if (list.isNotEmpty) {
          list.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          spO2 = (list.first.value as NumericHealthValue).numericValue.toDouble();
        }
      } catch (_) {}

      // Weight
      double weight = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight.subtract(const Duration(days: 1)), endTime: now,
          types: [HealthDataType.WEIGHT],
        );
        if (list.isNotEmpty) {
          list.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          weight = (list.first.value as NumericHealthValue).numericValue.toDouble();
        }
      } catch (_) {}

      // Blood Pressure
      double bpSys = 0, bpDia = 0;
      try {
        final sysList = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        );
        if (sysList.isNotEmpty) {
          sysList.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          bpSys = (sysList.first.value as NumericHealthValue).numericValue.toDouble();
        }
        final diaList = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        );
        if (diaList.isNotEmpty) {
          diaList.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          bpDia = (diaList.first.value as NumericHealthValue).numericValue.toDouble();
        }
      } catch (_) {}

      // Blood Glucose
      double glucose = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.BLOOD_GLUCOSE],
        );
        if (list.isNotEmpty) {
          list.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          glucose = (list.first.value as NumericHealthValue).numericValue.toDouble();
        }
      } catch (_) {}

      // Body Temperature
      double temp = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.BODY_TEMPERATURE],
        );
        if (list.isNotEmpty) {
          list.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          temp = (list.first.value as NumericHealthValue).numericValue.toDouble();
        }
      } catch (_) {}

      // Distance
      double distance = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.DISTANCE_DELTA],
        );
        for (final dp in list) {
          distance += (dp.value as NumericHealthValue).numericValue;
        }
      } catch (_) {}

      // Water / Hydration
      int waterCups = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.WATER],
        );
        double totalLiters = 0;
        for (final dp in list) {
          totalLiters += (dp.value as NumericHealthValue).numericValue;
        }
        waterCups = (totalLiters / 0.25).round(); // ~250ml per cup
      } catch (_) {}

      // Respiratory Rate
      double respRate = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.RESPIRATORY_RATE],
        );
        if (list.isNotEmpty) {
          list.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          respRate = (list.first.value as NumericHealthValue).numericValue.toDouble();
        }
      } catch (_) {}

      // Body Fat %
      double bodyFat = 0;
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight.subtract(const Duration(days: 1)), endTime: now,
          types: [HealthDataType.BODY_FAT_PERCENTAGE],
        );
        if (list.isNotEmpty) {
          list.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          bodyFat = (list.first.value as NumericHealthValue).numericValue.toDouble();
        }
      } catch (_) {}

      // Workouts
      List<WorkoutSession> workouts = [];
      try {
        final list = await health.getHealthDataFromTypes(
          startTime: midnight, endTime: now,
          types: [HealthDataType.WORKOUT],
        );
        for (final dp in list) {
          workouts.add(WorkoutSession(
            type: dp.value.toString(),
            startTime: dp.dateFrom,
            endTime: dp.dateTo,
          ));
        }
      } catch (_) {}

      // Active minutes (approximate from steps cadence & workouts)
      int activeMins = 0;
      if (steps > 0) activeMins += (steps / 100).round().clamp(0, 180);
      for (final w in workouts) {
        activeMins += w.duration.inMinutes;
      }

      return HealthMetrics(
        steps: steps,
        heartRate: heartRate,
        heartRateMin: hrMin,
        heartRateMax: hrMax,
        sleepHours: sleepHours,
        caloriesBurned: calories,
        bloodOxygen: spO2,
        weight: weight,
        bpSystolic: bpSys,
        bpDiastolic: bpDia,
        bloodGlucose: glucose,
        bodyTemperature: temp,
        distanceMeters: distance,
        waterCups: waterCups,
        respiratoryRate: respRate,
        bodyFatPct: bodyFat,
        activeMinutes: activeMins,
        workouts: workouts,
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

  /// Write water intake (in liters) to Health Connect
  Future<bool> logWaterIntake(double liters) async {
    if (kIsWeb) return false;
    try {
      final health = Health();
      final now = DateTime.now();
      final success = await health.writeHealthData(
        value: liters,
        type: HealthDataType.WATER,
        startTime: now.subtract(const Duration(minutes: 1)),
        endTime: now,
      );
      if (success) await refresh();
      return success;
    } catch (_) {
      return false;
    }
  }

  /// Write weight (in kg) to Health Connect
  Future<bool> logWeight(double kg) async {
    if (kIsWeb) return false;
    try {
      final health = Health();
      final now = DateTime.now();
      final success = await health.writeHealthData(
        value: kg,
        type: HealthDataType.WEIGHT,
        startTime: now.subtract(const Duration(minutes: 1)),
        endTime: now,
      );
      if (success) await refresh();
      return success;
    } catch (_) {
      return false;
    }
  }
}

final healthDataProvider =
    AsyncNotifierProvider<HealthDataNotifier, HealthMetrics>(
  HealthDataNotifier.new,
);
