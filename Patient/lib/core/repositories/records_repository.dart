import 'dart:typed_data';
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

    // Map the database columns to the UI's expected fields in the frontend
    return List<Map<String, dynamic>>.from(data).map((r) {
      return {
        ...r,
        'type': r['record_type'] ?? 'Document',
        'doctorName': 'Uploaded Record',
      };
    }).toList();
  }

  Future<String?> createArchivedRecord({
    required String fileType,
    required String category,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return null;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;

    try {
      final ext = fileName.split('.').last;
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = '$userId/$category/$uniqueName';

      // 1. Upload file bytes to the storage bucket
      await SupabaseService.client.storage
          .from('medical-records')
          .uploadBinary(storagePath, fileBytes);

      // Get public URL
      final fileUrl = SupabaseService.client.storage
          .from('medical-records')
          .getPublicUrl(storagePath);

      // 2. Create the DB record in the correct table 'health_records'
      final res = await SupabaseService.client.from('health_records').insert({
        'user_id': userId,
        'title': fileName,
        'record_type': category == 'Other' ? 'Imaging' : category, // Maps to valid enum ('AI Result', 'Prescription', 'Lab Report', 'Imaging')
        'file_url': fileUrl,
        'metadata': {'file_type': fileType},
      }).select('id').single();

      return res['id'] as String;
    } catch (e) {
      print('Vault Create Record Error: $e');
      return null;
    }
  }
}

