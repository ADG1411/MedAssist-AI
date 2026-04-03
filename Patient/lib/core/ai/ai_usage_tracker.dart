import '../services/supabase_service.dart';

/// Tracks AI API usage (tokens, latency, cost) to the `ai_usage_logs` table.
/// Fire-and-forget: never throws, never blocks the UI.
class AiUsageTracker {
  AiUsageTracker._();

  /// Log a single AI API call with usage metadata.
  static Future<void> track({
    required String functionName,
    String? modelName,
    int? promptTokens,
    int? completionTokens,
    int? latencyMs,
    double? costEstimate,
    String status = 'success',
    String? errorMessage,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return;

      await SupabaseService.client.from('ai_usage_logs').insert({
        'user_id': userId,
        'function_name': functionName,
        if (modelName != null) 'model_name': modelName,
        if (promptTokens != null) 'prompt_tokens': promptTokens,
        if (completionTokens != null) 'completion_tokens': completionTokens,
        if (latencyMs != null) 'latency_ms': latencyMs,
        if (costEstimate != null) 'cost_estimate': costEstimate,
        'status': status,
        if (errorMessage != null) 'error_message': errorMessage,
      });
    } catch (_) {
      // Silently ignore — tracking must never crash the app
    }
  }

  /// Auto-extract usage from edge function response and log it.
  /// Call this from EdgeFunctionService after every successful invoke.
  static Future<void> trackEdgeFunction(
    String functionName,
    Map<String, dynamic> response,
    int latencyMs,
  ) async {
    final usage = response['usage'] as Map<String, dynamic>?;

    await track(
      functionName: functionName,
      modelName: usage?['model'] as String?,
      promptTokens: usage?['prompt_tokens'] as int?,
      completionTokens: usage?['completion_tokens'] as int?,
      latencyMs: latencyMs,
      status: 'success',
    );
  }

  /// Track a failed edge function call.
  static Future<void> trackError(
    String functionName,
    String error,
    int latencyMs,
  ) async {
    await track(
      functionName: functionName,
      latencyMs: latencyMs,
      status: 'error',
      errorMessage: error,
    );
  }

  /// Get usage summary for current user (for future analytics dashboard).
  static Future<Map<String, dynamic>> getUsageSummary() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return {};

      final data = await SupabaseService.client
          .from('ai_usage_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      final logs = List<Map<String, dynamic>>.from(data);
      int totalTokens = 0;
      int totalCalls = logs.length;
      for (final log in logs) {
        totalTokens += (log['prompt_tokens'] as int? ?? 0) +
            (log['completion_tokens'] as int? ?? 0);
      }

      return {
        'total_calls': totalCalls,
        'total_tokens': totalTokens,
        'recent_logs': logs.take(10).toList(),
      };
    } catch (_) {
      return {};
    }
  }
}
