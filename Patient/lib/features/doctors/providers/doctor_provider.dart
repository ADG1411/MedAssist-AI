import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/doctor_repository.dart';

// Provides the recommended specialty
final aiMatchProvider = FutureProvider<String?>((ref) async {
  final repo = ref.read(doctorRepositoryProvider);
  return repo.getAiRecommendedSpecialty();
});

// Provides the active category filter (e.g. 'All', 'Cardiology')
class DoctorFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setFilter(String filter) => state = filter;
}

final doctorFilterProvider = NotifierProvider<DoctorFilterNotifier, String>(DoctorFilterNotifier.new);

// Provides the asynchronously fetched list of doctors based on filter
final doctorsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(doctorRepositoryProvider);
  final filter = ref.watch(doctorFilterProvider);
  return repo.getDoctors(filter: filter);
});
