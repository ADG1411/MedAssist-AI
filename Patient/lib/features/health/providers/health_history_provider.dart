import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

class DailyHealthData {
  final DateTime date;
  final int steps;
  final double heartRate;
  final double sleepHours;
  final double calories;
  final double bloodOxygen;

  const DailyHealthData({
    required this.date,
    this.steps = 0,
    this.heartRate = 0,
    this.sleepHours = 0,
    this.calories = 0,
    this.bloodOxygen = 0,
  });
}

class HealthHistory {
  final List<DailyHealthData> dailyData;
  const HealthHistory({this.dailyData = const []});
}

class HealthHistoryNotifier extends AsyncNotifier<HealthHistory> {
  @override
  Future<HealthHistory> build() => _fetch();

  Future<HealthHistory> _fetch() async {
    if (kIsWeb) return const HealthHistory();

    try {
      final health = Health();
      await health.configure();

      final now = DateTime.now();
      final List<DailyHealthData> days = [];

      for (int i = 6; i >= 0; i--) {
        final dayStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final dayEnd = i == 0 ? now : dayStart.add(const Duration(days: 1));

        int steps = 0;
        try {
          steps = await health.getTotalStepsInInterval(dayStart, dayEnd) ?? 0;
        } catch (_) {}

        double hr = 0;
        try {
          final hrList = await health.getHealthDataFromTypes(
            startTime: dayStart, endTime: dayEnd,
            types: [HealthDataType.HEART_RATE],
          );
          if (hrList.isNotEmpty) {
            double sum = 0;
            for (final dp in hrList) {
              sum += (dp.value as NumericHealthValue).numericValue.toDouble();
            }
            hr = sum / hrList.length;
          }
        } catch (_) {}

        double sleep = 0;
        try {
          final sleepStart = dayStart.subtract(const Duration(hours: 10));
          final sleepList = await health.getHealthDataFromTypes(
            startTime: sleepStart, endTime: dayStart,
            types: [HealthDataType.SLEEP_ASLEEP],
          );
          double totalMins = 0;
          for (final dp in sleepList) {
            totalMins += (dp.value as NumericHealthValue).numericValue;
          }
          sleep = totalMins / 60.0;
        } catch (_) {}

        double cals = 0;
        try {
          final calList = await health.getHealthDataFromTypes(
            startTime: dayStart, endTime: dayEnd,
            types: [HealthDataType.ACTIVE_ENERGY_BURNED],
          );
          for (final dp in calList) {
            cals += (dp.value as NumericHealthValue).numericValue;
          }
        } catch (_) {}

        double spo2 = 0;
        try {
          final list = await health.getHealthDataFromTypes(
            startTime: dayStart, endTime: dayEnd,
            types: [HealthDataType.BLOOD_OXYGEN],
          );
          if (list.isNotEmpty) {
            list.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
            spo2 = (list.first.value as NumericHealthValue).numericValue.toDouble();
          }
        } catch (_) {}

        days.add(DailyHealthData(
          date: dayStart,
          steps: steps,
          heartRate: hr,
          sleepHours: sleep,
          calories: cals,
          bloodOxygen: spo2,
        ));
      }

      return HealthHistory(dailyData: days);
    } catch (_) {
      return const HealthHistory();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final healthHistoryProvider =
    AsyncNotifierProvider<HealthHistoryNotifier, HealthHistory>(
  HealthHistoryNotifier.new,
);
