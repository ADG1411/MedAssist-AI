import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/dashboard_repository.dart';

final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, Map<String, dynamic>>(DashboardNotifier.new);

class DashboardNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final repo = ref.read(dashboardRepositoryProvider);
    return await repo.getDashboardData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(dashboardRepositoryProvider);
      return await repo.getDashboardData();
    });
  }
}

