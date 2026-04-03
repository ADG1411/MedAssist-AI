import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/edge_function_service.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

class ChatRepository {
  bool get useMock => dotenv.env['USE_MOCK'] == 'true';

  /// Send a symptom message via the symptom-triage Edge Function (v2 contract)
  Future<Map<String, dynamic>> sendSymptomMessage({
    required String bodyPart,
    required int severity,
    required String message,
    required List<Map<String, dynamic>> chatHistory,
    Map<String, dynamic>? patientContext,
    String aiMode = 'default',
    String? sessionId,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return {
        'reply': 'Based on your symptoms of $bodyPart pain with severity $severity, '
            'I recommend monitoring for the next 24 hours. If pain persists, consider consulting a specialist.',
        'conditions': [
          {'name': 'Gastric Inflammation', 'confidence': 78, 'risk': 'Medium'},
          {'name': 'GERD Flare-up', 'confidence': 65, 'risk': 'Low'},
        ],
        'specialization': 'Gastroenterologist',
        'next_question': null,
        'emergency': false,
        'action': 'monitor',
        'prescription_hints': ['Take antacid after meals', 'Avoid spicy food for 48 hours'],
        'monitoring_plan': {
          'track_for_days': 5,
          'focus_metrics': ['pain_score', 'hydration', 'meal_trigger', 'sleep'],
          'red_flags': ['vomiting blood', 'black stools'],
        },
        'doctor_handoff': {
          'summary': 'Patient presents with epigastric pain, likely gastritis. History of GERD.',
          'urgency': 'routine',
          'recommended_tests': ['CBC', 'H. pylori test'],
        },
        'risk_score': 45,
        'confidence_reasoning': [
          'Symptom pattern consistent with gastric inflammation',
          'History of GERD increases likelihood',
        ],
      };
    }

    return await EdgeFunctionService.invoke(
      'symptom-triage',
      body: {
        'messages': chatHistory,
        'session_id': sessionId,
        'patient_context': {
          'body_region': bodyPart,
          'severity': severity,
          'latest_message': message,
          'ai_mode': aiMode,
          ...?patientContext,
        },
      },
    );
  }

  /// Save a chat message to the symptom_messages table
  Future<void> saveMessage({
    required String sessionId,
    required String role,
    required String content,
  }) async {
    if (useMock) return;
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    await SupabaseService.client.from('symptom_messages').insert({
      'session_id': sessionId,
      'user_id': userId,
      'role': role,
      'content': content,
    });
  }

  /// Create a new symptom session
  Future<String?> createSession({
    required String bodyRegion,
    required int severity,
  }) async {
    if (useMock) return 'mock-session-id';
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;

    final data = await SupabaseService.client
        .from('symptom_sessions')
        .insert({
          'user_id': userId,
          'body_region': bodyRegion,
          'severity': severity,
        })
        .select('id')
        .single();
    return data['id'] as String?;
  }

  /// Save AI result to the ai_results table (v2 expanded)
  Future<void> saveAiResult({
    required String? sessionId,
    required List<Map<String, dynamic>> conditions,
    required String riskLevel,
    String? recommendedAction,
    int? riskScore,
    Map<String, dynamic>? monitoringPlan,
    Map<String, dynamic>? doctorHandoff,
    List<dynamic>? confidenceReasoning,
    List<dynamic>? prescriptionHints,
    String? specialization,
  }) async {
    if (useMock) return;
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    await SupabaseService.client.from('ai_results').insert({
      'user_id': userId,
      'session_id': sessionId,
      'conditions': conditions,
      'risk_level': riskLevel,
      'recommended_action': recommendedAction,
      'risk_score': riskScore,
      'monitoring_plan': monitoringPlan ?? {},
      'doctor_handoff': doctorHandoff ?? {},
      'confidence_reasoning': confidenceReasoning ?? [],
      'prescription_hints': prescriptionHints ?? [],
      'specialization': specialization,
    });
  }
}
