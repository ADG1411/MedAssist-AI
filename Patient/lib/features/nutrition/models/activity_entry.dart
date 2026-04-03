import 'package:equatable/equatable.dart';

class ActivityEntry extends Equatable {
  final String id;
  final DateTime date;
  final String code;
  final String name;
  final double durationMin;
  final double caloriesBurned;

  const ActivityEntry({
    required this.id,
    required this.date,
    required this.code,
    required this.name,
    required this.durationMin,
    required this.caloriesBurned,
  });

  factory ActivityEntry.fromSupabase(Map<String, dynamic> row) {
    return ActivityEntry(
      id: row['id'] as String,
      date: DateTime.parse(row['log_date'] as String),
      code: row['activity_code'] as String,
      name: row['activity_name'] as String,
      durationMin: (row['duration_min'] as num).toDouble(),
      caloriesBurned: (row['calories_burned'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, date, code, name, durationMin, caloriesBurned];
}

