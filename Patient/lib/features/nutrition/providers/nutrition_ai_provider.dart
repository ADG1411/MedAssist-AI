import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medassist_ai/features/auth/providers/auth_provider.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionAiState {
  final List<Map<String, dynamic>> messages;
  final bool isTyping;

  const NutritionAiState({
    this.messages = const [],
    this.isTyping = false,
  });

  NutritionAiState copyWith({
    List<Map<String, dynamic>>? messages,
    bool? isTyping,
  }) {
    return NutritionAiState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
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
          'text': 'Hello! I am Dr. NutriAssist. I can review your meals, check them against your chronic conditions, and provide dietary advice.',
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
        'chronic_conditions': user?['chronicConditions'] ?? user?['chronic_conditions'] ?? [],
        'allergies': user?['allergies'] ?? [],
        'calories': todaySummary.caloriesLogged,
        'carbs': todaySummary.carbsLogged,
        'fat': todaySummary.fatLogged,
        'protein': todaySummary.proteinLogged,
        'calories_burned': todaySummary.activityBurnLogged,
      };

      final response = await Supabase.instance.client.functions.invoke(
        'nutrition-ai',
        body: {
          'messages': contextPayload,
          'patient_context': patientContext,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final aiReplyText = data['reply'] ?? 'I cannot analyze that right now.';
      final flags = data['flags'] ?? [];
      final dailyTip = data['daily_tip'];

      final replyContent = dailyTip != null && (dailyTip as String).isNotEmpty 
          ? '$aiReplyText\n\n Tip: $dailyTip' 
          : aiReplyText;
      
      final aiMsg = {
        'id': 'ai_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'ai',
        'text': replyContent,
        'timestamp': 'Just now',
        'flags': flags,
      };

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
      
    } catch (e) {
      final errorMsg = {
        'id': 'err_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'ai',
        'text': 'Error: Unable to reach AI Coach.',
        'timestamp': 'Just now',
      };
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
      );
    }
  }
}

final nutritionAiProvider = NotifierProvider<NutritionAiNotifier, NutritionAiState>(
  NutritionAiNotifier.new,
);

