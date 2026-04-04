// Recovery Provider — loads 7-day monitoring trend and computes
// a real recovery score from symptom severity, sleep, and hydration.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/monitoring_repository.dart';
import '../../../core/repositories/dashboard_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class RecoveryData {
  /// 0–100 computed recovery score
  final int score;

  /// Raw 7-day monitoring logs (newest first from DB, reversed for display)
  final List<Map<String, dynamic>> logs;

  /// Derived 7-point score velocity for chart — index 0 = oldest
  final List<double> velocity;

  /// Whether there's an upward trend
  final bool isTrending;

  /// Score delta vs yesterday
  final int scoreDelta;

  /// Day number in the current recovery episode
  final int episodeDays;

  /// Best-guess condition name from the latest AI result
  final String? conditionName;

  /// Recovery ETA string
  final String etaLabel;

  const RecoveryData({
    required this.score,
    required this.logs,
    required this.velocity,
    required this.isTrending,
    required this.scoreDelta,
    required this.episodeDays,
    this.conditionName,
    required this.etaLabel,
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

final recoveryProvider = AsyncNotifierProvider<RecoveryNotifier, RecoveryData>(
  RecoveryNotifier.new,
);

class RecoveryNotifier extends AsyncNotifier<RecoveryData> {
  @override
  Future<RecoveryData> build() async {
    return _load();
  }

  Future<RecoveryData> _load() async {
    final monRepo = ref.read(monitoringRepositoryProvider);
    final dashRepo = ref.read(dashboardRepositoryProvider);

    final results = await Future.wait([
      monRepo.getTrend(days: 7),
      dashRepo.getDashboardData(),
    ]);

    final logs = results[0] as List<Map<String, dynamic>>;
    final dashData = results[1] as Map<String, dynamic>;

    // Logs come newest-first → reverse so index 0 = oldest day
    final orderedLogs = logs.reversed.toList();

    // Compute per-day scores (0–100) from monitoring logs
    final velocity = orderedLogs.map(_scoreFromLog).toList();

    // Use dashboard recovery_score as authoritative final score
    final score = (dashData['recovery_score'] as num?)?.toInt() ??
        (velocity.isNotEmpty ? velocity.last.toInt() : 70);

    // Trend: last score vs second-to-last
    final isTrending =
        velocity.length >= 2 && velocity.last > velocity[velocity.length - 2];

    final scoreDelta = velocity.length >= 2
        ? (velocity.last - velocity[velocity.length - 2]).round()
        : 0;

    // Episode: number of consecutive logged days
    final episodeDays = orderedLogs.length.clamp(1, 30);

    // ETA to milestone
    final nextMilestone = score < 80 ? 80 : score < 90 ? 90 : 100;
    final gap = nextMilestone - score;
    final avgDailyGain =
        (scoreDelta.abs() > 0 ? scoreDelta.abs() : 3).clamp(1, 10);
    final etaDays = gap > 0 ? (gap / avgDailyGain).ceil().clamp(1, 30) : 0;
    final etaLabel = etaDays == 0
        ? 'You\'ve reached your milestone! 🎉'
        : '~$etaDays day${etaDays > 1 ? 's' : ''} to score $nextMilestone';

    final aiResult = dashData['latest_ai_result'] as Map<String, dynamic>?;
    final conditionName = aiResult?['condition'] as String?;

    return RecoveryData(
      score: score,
      logs: orderedLogs,
      velocity: velocity,
      isTrending: isTrending,
      scoreDelta: scoreDelta,
      episodeDays: episodeDays,
      conditionName: conditionName,
      etaLabel: etaLabel,
    );
  }

  /// Compute a 0–100 recovery score from a single monitoring log.
  /// Higher sleep + hydration + lower severity = higher score.
  double _scoreFromLog(Map<String, dynamic> log) {
    final severity =
        (log['symptom_severity'] as num?)?.toDouble() ?? 5.0; // 0–10
    final hydration =
        (log['hydration_cups'] as num?)?.toDouble() ?? 4.0; // 0–8
    final sleep = (log['sleep_hours'] as num?)?.toDouble() ?? 6.0; // 0–12

    // Pain: 0 severity = 40 pts, 10 severity = 0 pts
    final painScore = ((10 - severity) / 10.0).clamp(0.0, 1.0) * 40;
    // Hydration: 8 cups = 30 pts
    final hydrationScore = (hydration / 8.0).clamp(0.0, 1.0) * 30;
    // Sleep: 7–9 hrs = 30 pts
    double sleepScore;
    if (sleep >= 7 && sleep <= 9) {
      sleepScore = 30;
    } else if (sleep >= 5 && sleep < 7) {
      sleepScore = (sleep - 5) / 2.0 * 20;
    } else if (sleep > 9) {
      sleepScore = 25; // slight penalty for oversleeping
    } else {
      sleepScore = 5;
    }

    return (painScore + hydrationScore + sleepScore).clamp(0, 100);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load());
  }
}
