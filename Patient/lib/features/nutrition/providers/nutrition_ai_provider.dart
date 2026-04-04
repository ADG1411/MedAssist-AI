import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medassist_ai/features/auth/providers/auth_provider.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';
import 'package:medassist_ai/core/services/edge_function_service.dart';

class NutritionAiState {
  final List<Map<String, dynamic>> messages;
  final bool isTyping;
  final String? lastDailyTip;
  final String? lastMealSuggestion;
  final String? lastMacroNote;

  const NutritionAiState({
    this.messages = const [],
    this.isTyping = false,
    this.lastDailyTip,
    this.lastMealSuggestion,
    this.lastMacroNote,
  });

  NutritionAiState copyWith({
    List<Map<String, dynamic>>? messages,
    bool? isTyping,
    String? lastDailyTip,
    String? lastMealSuggestion,
    String? lastMacroNote,
  }) {
    return NutritionAiState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      lastDailyTip: lastDailyTip ?? this.lastDailyTip,
      lastMealSuggestion: lastMealSuggestion ?? this.lastMealSuggestion,
      lastMacroNote: lastMacroNote ?? this.lastMacroNote,
    );
  }
}

class NutritionAiNotifier extends Notifier<NutritionAiState> {
  @override
  NutritionAiState build() {
    return const NutritionAiState(
      messages: [
        {
          'id': 'init_1',
          'role': 'ai',
          'text':
              'Hey there! I\'m Dr. NutriAssist, your personal nutrition coach. '
              'I can review your meals, flag food-condition conflicts, suggest healthy '
              'alternatives, and help you hit your dietary goals. What can I help you with?',
          'timestamp': 'Just now',
          'flags': [],
        }
      ],
    );
  }

  Future<void> sendMessage(String text) async {
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
      final contextPayload = state.messages.map((m) => <String, dynamic>{
            'role': m['role'],
            'content': m['text'],
          }).toList();

      final user = ref.read(authProvider);

      // Inject today's dietary summary
      final diaryState = ref.read(nutritionDiaryProvider);
      final todaySummary = diaryState.summary;

      final patientContext = <String, dynamic>{
        'chronic_conditions':
            user?['chronicConditions'] ?? user?['chronic_conditions'] ?? [],
        'allergies': user?['allergies'] ?? [],
        'calories': todaySummary.caloriesLogged,
        'carbs': todaySummary.carbsLogged,
        'fat': todaySummary.fatLogged,
        'protein': todaySummary.proteinLogged,
        'calories_burned': todaySummary.activityBurnLogged,
      };

      final response = await EdgeFunctionService.invoke(
        'nutrition-ai',
        body: {
          'messages': contextPayload,
          'patient_context': patientContext,
        },
      );

      final aiReplyText =
          response['reply'] ?? 'I cannot analyze that right now.';
      final flags = response['flags'] ?? [];
      final dailyTip = response['daily_tip'] as String?;
      final mealSuggestion = response['meal_suggestion'] as String?;
      final macroNote = response['macro_note'] as String?;

      final aiMsg = {
        'id': 'ai_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'ai',
        'text': aiReplyText,
        'timestamp': 'Just now',
        'flags': flags,
        if (dailyTip != null && dailyTip.isNotEmpty) 'daily_tip': dailyTip,
        if (mealSuggestion != null && mealSuggestion.isNotEmpty)
          'meal_suggestion': mealSuggestion,
        if (macroNote != null && macroNote.isNotEmpty)
          'macro_note': macroNote,
      };

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
        lastDailyTip: dailyTip,
        lastMealSuggestion: mealSuggestion,
        lastMacroNote: macroNote,
      );
    } catch (e) {
      final errorStr = e.toString();
      final errorMsg = {
        'id': 'err_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'ai',
        'text':
            'I\'m having trouble connecting right now. Please try again in a moment.\n\nDetails: $errorStr',
        'timestamp': 'Just now',
        'isError': true,
      };
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
      );
    }
  }
}

final nutritionAiProvider =
    NotifierProvider<NutritionAiNotifier, NutritionAiState>(
  NutritionAiNotifier.new,
);

