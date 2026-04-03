import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../mock/records_mock.dart';

final recordsRepositoryProvider = Provider((ref) => RecordsRepository());

class RecordsRepository {
  bool get useMock => dotenv.env['USE_MOCK'] == 'true';

  Future<List<Map<String, dynamic>>> getRecords() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return RecordsMock.healthRecords;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseService.client
        .from('health_records')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createRecord({
    required String title,
    required String recordType,
    String? fileUrl,
    Map<String, dynamic>? metadata,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    await SupabaseService.client.from('health_records').insert({
      'user_id': userId,
      'title': title,
      'record_type': recordType,
      'file_url': fileUrl,
      'metadata': metadata ?? {},
    });
  }
}

