import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/repositories/chat_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../nutrition/providers/nutrition_providers.dart' as medassist_ai_nutrition;

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatState {
  final String sessionId;
  final List<Map<String, dynamic>> messages;
  final bool isTyping;
  final Map<String, dynamic>? lastResult;
  final bool isEmergency;

  const ChatState({
    this.sessionId = '',
    this.messages = const [],
    this.isTyping = false,
    this.lastResult,
    this.isEmergency = false,
  });

  /// v2 field accessors
  int get riskScore => lastResult?['risk_score'] ?? 0;
  String get specialization => lastResult?['specialization'] ?? 'General Physician';
  List<dynamic> get confidenceReasoning => lastResult?['confidence_reasoning'] ?? [];
  Map<String, dynamic> get monitoringPlan => Map<String, dynamic>.from(lastResult?['monitoring_plan'] ?? {});
  Map<String, dynamic> get doctorHandoff => Map<String, dynamic>.from(lastResult?['doctor_handoff'] ?? {});
  List<dynamic> get prescriptionHints => lastResult?['prescription_hints'] ?? [];
  List<dynamic> get conditions => lastResult?['conditions'] ?? [];
  String get action => lastResult?['action'] ?? 'monitor';

  ChatState copyWith({
    String? sessionId,
    List<Map<String, dynamic>>? messages,
    bool? isTyping,
    Map<String, dynamic>? lastResult,
    bool? isEmergency,
  }) {
    return ChatState(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      lastResult: lastResult ?? this.lastResult,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late final ChatRepository _chatRepo;

  @override
  ChatState build() {
    _chatRepo = ref.read(chatRepositoryProvider);
    final initialSessionId = const Uuid().v4();
    
    return ChatState(
      sessionId: initialSessionId,
      messages: [
        {
          'id': 'init_1',
          'role': 'ai',
          'text': 'Hello. I\'m your MedAssist AI assistant. Describe your symptoms and I\'ll help analyze them.',
          'timestamp': 'Just now',
        }
      ],
    );
  }

  Future<void> sendMessage(String text, double severity, String bodyPart, {String aiMode = 'default'}) async {
    final userMsg = {
      'id': 'u_${DateTime.now().millisecondsSinceEpoch}',
      'role': 'user',
      'text': text,
      'timestamp': 'Just now',
    };
    
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    try {
      // Create a real DB session on the first user message
      if (state.messages.length <= 2) {
        final newId = await _chatRepo.createSession(
          bodyRegion: bodyPart,
          severity: severity.toInt(),
        );
        if (newId != null && newId != 'mock-session-id') {
          state = state.copyWith(sessionId: newId);
        }
      }

      // Build context payload for the Edge Function
      final contextPayload = state.messages.map((m) => <String, dynamic>{
        'role': m['role'],
        'content': m['text'],
      }).toList();

      final user = ref.read(authProvider);
      
      // Inject Nutrition Activity if known today
      final nutritionState = ref.read(medassist_ai_nutrition.nutritionDiaryProvider);
      final todaySummary = nutritionState.summary;

      final patientContext = <String, dynamic>{
        'body_region': bodyPart,
        'severity': severity.toInt(),
        'chronic_conditions': user?['chronicConditions'] ?? user?['chronic_conditions'] ?? [],
        'allergies': user?['allergies'] ?? [],
        'nutrition_logged': todaySummary.caloriesLogged > 0,
        'calories_last_24h': todaySummary.caloriesLogged,
        'calories_burned_last_24h': todaySummary.activityBurnLogged,
      };

      final response = await _chatRepo.sendSymptomMessage(
        bodyPart: bodyPart,
        severity: severity.toInt(),
        message: text,
        chatHistory: contextPayload,
        patientContext: patientContext,
        aiMode: aiMode,
        sessionId: state.sessionId,
      );
      
      final aiReplyText = response['reply'] ?? response['next_question'] ?? 'Please provide more details.';
      final isEmergency = response['emergency'] == true;

      final aiMsg = {
        'id': 'ai_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'ai',
        'text': aiReplyText,
        'timestamp': 'Just now',
        if (isEmergency) 'emergency': true,
      };

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
        lastResult: response,
        isEmergency: isEmergency,
      );
      
    } catch (e) {
      final errorStr = e.toString();
      final errorMsg = {
        'id': 'err_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'ai',
        'text': 'Error: $errorStr\n(Please screenshot this)',
        'timestamp': 'Just now',
      };
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
      );
    }
  }
}
