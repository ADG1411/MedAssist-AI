import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/profile_repository.dart';

final profileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return await repo.getProfile();
});
