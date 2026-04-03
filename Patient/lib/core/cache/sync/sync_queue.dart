import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../cache_service.dart';

/// Queues operations for offline-first writes.
/// When the user is offline, mutations are stored here and flushed when connectivity returns.
class SyncQueue {
  SyncQueue._();

  static Box get _box => Hive.box(CacheBoxNames.syncQueue);
  static const _uuid = Uuid();

  /// Add a pending operation to the queue
  static Future<String> enqueue({
    required String table,
    required String operation, // 'insert', 'update', 'delete'
    required Map<String, dynamic> data,
  }) async {
    final id = _uuid.v4();
    final entry = {
      'id': id,
      'table': table,
      'operation': operation,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    };
    await _box.put(id, entry);
    return id;
  }

  /// Get all pending operations (oldest first)
  static List<Map<String, dynamic>> dequeueAll() {
    final entries = <Map<String, dynamic>>[];
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        entries.add(Map<String, dynamic>.from(data as Map));
      }
    }
    entries.sort((a, b) =>
        (a['created_at'] as String).compareTo(b['created_at'] as String));
    return entries;
  }

  /// Remove a completed operation
  static Future<void> remove(String id) async {
    await _box.delete(id);
  }

  /// Increment retry count for a failed operation
  static Future<void> incrementRetry(String id) async {
    final data = _box.get(id);
    if (data != null) {
      final entry = Map<String, dynamic>.from(data as Map);
      entry['retry_count'] = (entry['retry_count'] as int? ?? 0) + 1;
      await _box.put(id, entry);
    }
  }

  /// Number of pending operations
  static int get pendingCount => _box.length;

  /// Whether there are any pending operations
  static bool get hasPending => _box.isNotEmpty;

  /// Clear all pending operations (use carefully)
  static Future<void> clear() async {
    await _box.clear();
  }
}
