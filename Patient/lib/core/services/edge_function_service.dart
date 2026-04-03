import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../ai/ai_usage_tracker.dart';

class EdgeFunctionService {
  EdgeFunctionService._();

  static Future<Map<String, dynamic>> invoke(
    String functionName, {
    Map<String, dynamic>? body,
    int maxRetries = 2,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    int attempts = 0;
    final stopwatch = Stopwatch()..start();
    
    while (attempts <= maxRetries) {
      try {
        final response = await SupabaseService.client.functions.invoke(
          functionName,
          body: body,
        ).timeout(timeout);
        
        stopwatch.stop();
        
        // Supabase functions.invoke returns FunctionResponse
        // response.data can be a Map, a String, or null
        final data = response.data;
        
        Map<String, dynamic> result;
        if (data != null && data is Map) {
          result = Map<String, dynamic>.from(data);
        } else if (data != null && data is String) {
          // Try parsing string as JSON
          try {
            final parsed = jsonDecode(data);
            if (parsed is Map) {
              result = Map<String, dynamic>.from(parsed);
            } else {
              result = {'result': parsed};
            }
          } catch (_) {
            result = {'result': data};
          }
        } else {
          result = {};
        }

        // Auto-track usage (fire-and-forget)
        AiUsageTracker.trackEdgeFunction(
          functionName, result, stopwatch.elapsedMilliseconds,
        );

        return result;
      } on TimeoutException catch (_) {
        if (attempts >= maxRetries) {
          stopwatch.stop();
          AiUsageTracker.trackError(
            functionName, 'Timeout', stopwatch.elapsedMilliseconds,
          );
          throw Exception('Timeout waiting for $functionName');
        }
      } on FunctionException catch (e) {
        if (attempts >= maxRetries) {
          stopwatch.stop();
          AiUsageTracker.trackError(
            functionName, e.toString(), stopwatch.elapsedMilliseconds,
          );
          throw Exception('Edge Function Error [$functionName]: ${e.toString()}');
        }
      } catch (e) {
        if (attempts >= maxRetries) {
          stopwatch.stop();
          AiUsageTracker.trackError(
            functionName, e.toString(), stopwatch.elapsedMilliseconds,
          );
          throw Exception('Network Error [$functionName]: ${e.toString()}');
        }
      }
      
      attempts++;
      await Future.delayed(Duration(milliseconds: 500 * attempts));
    }
    
    throw Exception('Failed to invoke $functionName after $maxRetries retries.');
  }
}


