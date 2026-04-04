import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../mock/records_mock.dart';

final recordsRepositoryProvider = Provider((ref) => RecordsRepository());

class RecordsRepository {
  bool get useMock => false // dotenv.env['USE_MOCK'] == 'true';

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

  Future<bool> deleteRecord(String recordId, {String? fileUrl}) async {
    if (useMock) return true;

    try {
      // Try to remove the storage file if URL is available
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final uri = Uri.tryParse(fileUrl);
          if (uri != null) {
            final pathSegments = uri.pathSegments;
            final bucketIndex = pathSegments.indexOf('medical-records');
            if (bucketIndex >= 0 && bucketIndex < pathSegments.length - 1) {
              final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
              await SupabaseService.client.storage
                  .from('medical-records')
                  .remove([storagePath]);
            }
          }
        } catch (e) {
          print('Storage delete skipped: $e');
        }
      }

      // Delete the DB row from health_records
      await SupabaseService.client
          .from('health_records')
          .delete()
          .eq('id', recordId);

      return true;
    } catch (e) {
      print('Delete record error: $e');
      return false;
    }
  }
}

