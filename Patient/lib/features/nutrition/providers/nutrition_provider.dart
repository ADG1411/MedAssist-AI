import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/nutrition_mock.dart';
import '../../../core/repositories/nutrition_repository.dart';

final nutritionProvider = NotifierProvider<NutritionNotifier, NutritionState>(NutritionNotifier.new);

class NutritionState {
  final List<Map<String, dynamic>> foods;
  final String searchQuery;
  final Set<String> activeFilters;
  final bool isScanning;
  final Map<String, dynamic>? scannedResult;

  const NutritionState({
    this.foods = const [],
    this.searchQuery = '',
    this.activeFilters = const {},
    this.isScanning = false,
    this.scannedResult,
  });

  List<Map<String, dynamic>> get filteredFoods {
    var list = foods;
    if (searchQuery.isNotEmpty) {
      list = list.where((f) => f['name'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    if (activeFilters.contains('Recovery Diet')) list = list.where((f) => f['isRecoverySafe'] == true).toList();
    if (activeFilters.contains('Diabetic Safe')) list = list.where((f) => f['diabeticSafe'] == true).toList();
    if (activeFilters.contains('Low Sodium')) list = list.where((f) => f['lowSodium'] == true).toList();
    if (activeFilters.contains('High Protein')) list = list.where((f) => f['highProtein'] == true).toList();
    
    return list;
  }

  NutritionState copyWith({
    List<Map<String, dynamic>>? foods,
    String? searchQuery,
    Set<String>? activeFilters,
    bool? isScanning,
    Map<String, dynamic>? scannedResult,
  }) {
    return NutritionState(
      foods: foods ?? this.foods,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      isScanning: isScanning ?? this.isScanning,
      scannedResult: scannedResult ?? this.scannedResult,
    );
  }
}

class NutritionNotifier extends Notifier<NutritionState> {
  late final NutritionRepository _repo;

  @override
  NutritionState build() {
    _repo = ref.read(nutritionRepositoryProvider);
    return NutritionState(foods: NutritionMock.dietaryRecommendations);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFilter(String filter) {
    final updated = Set<String>.from(state.activeFilters);
    if (updated.contains(filter)) {
      updated.remove(filter);
    } else {
      updated.add(filter);
    }
    state = state.copyWith(activeFilters: updated);
  }

  Future<bool> scanImageFakeBase64() async {
    state = state.copyWith(isScanning: true, scannedResult: null);
    try {
      final res = await _repo.scanFoodImage('dummy_base64_string');
      
      final items = res['detected_items'] as List? ?? [];
      final firstItem = items.isNotEmpty ? items.first as Map<String, dynamic> : <String, dynamic>{};
      
      final simulatedResult = {
        'id': 'scanned',
        'name': res['meal_description'] ?? firstItem['name'] ?? 'Analyzed Meal',
        'description': 'AI Vision matched visual macronutrient constraints.',
        'calories': firstItem['calories'] ?? 480,
        'carbs': firstItem['carbs_g'] ?? 65,
        'protein': firstItem['protein_g'] ?? 12,
        'fat': firstItem['fat_g'] ?? 22,
        'sugar': 8,
        'sodium': firstItem['sodium_mg'] ?? 1800,
        'isRecoverySafe': false,
        'lowSodium': false,
        'diabeticSafe': false,
        'recoveryScore': 35,
        'reason': 'Check nutritional values against your health profile for safety assessment.',
        'detected_items': items,
        'image_url': 'https://images.unsplash.com/photo-1612929633738-8fe01f7c845f?q=80&w=600&auto=format&fit=crop',
      };

      state = state.copyWith(
        isScanning: false,
        scannedResult: simulatedResult,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isScanning: false);
      return false;
    }
  }
}

