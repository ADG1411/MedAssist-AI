import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/repositories/records_repository.dart';
import '../../../core/services/edge_function_service.dart';

final recordsProvider = AsyncNotifierProvider<RecordsNotifier, RecordsState>(RecordsNotifier.new);

class RecordsState {
  final List<Map<String, dynamic>> allRecords;
  final String activeFilter;

  const RecordsState({
    this.allRecords = const [],
    this.activeFilter = 'All',
  });

  List<Map<String, dynamic>> get filteredRecords {
    if (activeFilter == 'All') return allRecords;
    return allRecords.where((r) => r['record_type'] == activeFilter).toList();
  }

  RecordsState copyWith({
    List<Map<String, dynamic>>? allRecords,
    String? activeFilter,
  }) {
    return RecordsState(
      allRecords: allRecords ?? this.allRecords,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class RecordsNotifier extends AsyncNotifier<RecordsState> {
  @override
  Future<RecordsState> build() async {
    final repo = ref.read(recordsRepositoryProvider);
    final records = await repo.getRecords();
    return RecordsState(allRecords: records);
  }

  void setFilter(String filter) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(value.copyWith(activeFilter: filter));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(recordsRepositoryProvider);
      final records = await repo.getRecords();
      return RecordsState(allRecords: records);
    });
  }

  Future<bool> uploadAndProcessRecord() async {
    state = const AsyncLoading();
    
    try {
      // 1. Real file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) {
        await refresh();
        return false;
      }

      final file = result.files.first;
      final fileName = file.name;
      final fileBytes = file.bytes;

      if (fileBytes == null) {
        throw Exception("File data is corrupt or unreadable.");
      }
      
      final category = _inferRecordType(fileName);

      // 2. Upload to Supabase Storage & Create Medical Record row (Pending AI)
      final repo = ref.read(recordsRepositoryProvider);
      final recordId = await repo.createArchivedRecord(
        fileType: fileName.contains('.pdf') ? 'application/pdf' : 'image/jpeg',
        category: category,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      if (recordId == null) throw Exception("Failed to upload to Security Vault");

      // 3. Trigger Kimi Moonshot AI Processing in background
      try {
        final base64File = base64Encode(fileBytes);
        
        await EdgeFunctionService.invoke(
          'analyze-medical-record',
          body: {
            'record_id': recordId,
            'image_base64': base64File,
            'file_type': fileName.contains('.pdf') ? 'application/pdf' : 'image/jpeg',
          },
        );
      } catch (e) {
        debugPrint('Kimi NIM Edge Function failed: $e');
        // It's still safely stored, it just lacks AI summary for now.
      }

      await refresh();
      return true;
    } catch (e) {
      debugPrint('Upload failed: $e');
      if (state case AsyncData(:final value)) {
        state = AsyncData(value);
      }
      return false;
    }
  }

  String _inferRecordType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('lab') || lower.contains('blood') || lower.contains('lipid')) return 'Lab Report';
    if (lower.contains('xray') || lower.contains('mri') || lower.contains('scan')) return 'Imaging';
    if (lower.contains('prescription') || lower.contains('rx')) return 'Prescription';
    return 'Document';
  }
}
