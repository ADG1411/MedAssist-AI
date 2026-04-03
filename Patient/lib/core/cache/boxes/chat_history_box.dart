import 'package:hive_flutter/hive_flutter.dart';
import '../cache_service.dart';
import '../cache_keys.dart';

/// Caches AI chat history per session for offline review.
class ChatHistoryBox {
  ChatHistoryBox._();

  static Box get _box => Hive.box(CacheBoxNames.chatHistory);

  static Future<void> saveMessages(String sessionId, List<Map<String, dynamic>> messages) async {
    await _box.put(sessionId, messages);
    // Track recent session IDs
    final sessions = getRecentSessionIds();
    if (!sessions.contains(sessionId)) {
      sessions.insert(0, sessionId);
      if (sessions.length > 20) sessions.removeLast();
      await _box.put(CacheKeys.recentSessions, sessions);
    }
  }

  static List<Map<String, dynamic>> getMessages(String sessionId) {
    final data = _box.get(sessionId);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  static List<String> getRecentSessionIds({int limit = 10}) {
    final data = _box.get(CacheKeys.recentSessions);
    if (data == null) return [];
    final all = List<String>.from(data as List);
    return all.take(limit).toList();
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
