import '../services/supabase_service.dart';

/// Fire-and-forget audit logging service.
/// Logs user actions to the Supabase `audit_logs` table for compliance.
/// NEVER throws — logging failures must not crash the app.
class AuditService {
  AuditService._();

  /// Log an action. Fire-and-forget: errors are silently caught.
  static Future<void> log({
    required String action,
    required String module,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return;

      await SupabaseService.client.from('audit_logs').insert({
        'user_id': userId,
        'action_type': action,
        'module': module,
        if (entityId != null) 'entity_id': entityId,
        'metadata': metadata ?? {},
      });
    } catch (_) {
      // Silently ignore — audit logging must never crash the app
    }
  }

  /// Fetch recent audit logs for the current user (for future admin panel).
  static Future<List<Map<String, dynamic>>> getRecent({int limit = 20}) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return [];

      final data = await SupabaseService.client
          .from('audit_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }
}
