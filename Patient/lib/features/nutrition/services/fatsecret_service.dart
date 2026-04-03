/// FatSecret Image Recognition API Service
/// Handles OAuth2 token flow + food image recognition
/// Completely separate from existing OpenFoodFacts / barcode / USDA flows
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/models/meal_nutriments.dart';

class FatSecretService {
  static const _tokenUrl = 'https://oauth.fatsecret.com/connect/token';
  static const _apiBase = 'https://platform.fatsecret.com/rest/image-recognition/v2';

  final _client = http.Client();

  // Token cache
  String? _accessToken;
  DateTime? _tokenExpiry;

  String get _clientId => dotenv.env['FATSECRET_CLIENT_ID'] ?? '';
  String get _clientSecret => dotenv.env['FATSECRET_CLIENT_SECRET'] ?? '';

  /// Get OAuth2 access token (cached for 24h)
  Future<String> _getAccessToken() async {
    // Return cached token if still valid (with 5 min buffer)
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
      return _accessToken!;
    }

    debugPrint('🔑 Requesting FatSecret OAuth2 token...');
    debugPrint('🌐 URL: $_tokenUrl');

    final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

    final response = await _client.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      debugPrint('❌ Token error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to get FatSecret access token: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String;
    final expiresIn = data['expires_in'] as int? ?? 86400;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    debugPrint('✅ FatSecret token obtained (expires in ${expiresIn}s)');
    return _accessToken!;
  }

  /// Recognize food from image bytes
  /// Returns list of recognized food items as MealEntity
  Future<FoodRecognitionResult> recognizeImage(Uint8List imageBytes) async {
    final token = await _getAccessToken();

    // Resize/compress image if needed (FatSecret max: 1.09MB)
    // Base64 will increase size by ~33%, so limit raw bytes to ~800KB
    Uint8List processedBytes = imageBytes;
    if (imageBytes.length > 800000) {
      debugPrint('⚠️ Image too large (${imageBytes.length} bytes), may need compression');
    }

    final base64Image = base64Encode(processedBytes);

    debugPrint('📸 Sending image to FatSecret (${(base64Image.length / 1024).toStringAsFixed(0)}KB base64)...');

    try {
      final requestBody = jsonEncode({
        'image_b64': base64Image,
        'include_food_data': true,
        'region': 'US',
        'language': 'en',
      });

      final response = await _client.post(
        Uri.parse(_apiBase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      debugPrint('📡 FatSecret response: ${response.statusCode}');
      debugPrint('📡 JSON: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = response.body;
        debugPrint('❌ FatSecret API error: $errorBody');
        throw FatSecretException(
          'Image recognition failed (${response.statusCode})',
          response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        final errorInfo = data['error'] as Map<String, dynamic>;
        final msg = errorInfo['message'] ?? 'Unknown API error';
        debugPrint('❌ FatSecret API error (200 OK body): $msg');
        throw FatSecretException(msg, int.tryParse(errorInfo['code'].toString()) ?? 400);
      }

      return FoodRecognitionResult.fromJson(data);
    } catch (e) {
      debugPrint('⚠️ FatSecret Failed, starting GEMINI 1.5 FALLBACK. Error: $e');
      return _fallbackToGemini(base64Image);
    }
  }

  /// Ultimate Fallback using Google Gemini 2.5 Flash Vision API
  Future<FoodRecognitionResult> _fallbackToGemini(String base64Image) async {
    debugPrint('🤖 Connecting to Gemini 2.5 Flash...');
    const apiKey = 'AIzaSyCoFUFuV75g4YDegDt-IS6BEU16L5Ui9Tg';
    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';

    final prompt = '''
Analyze this food image. Provide a JSON response describing the detected food properties.
Your response MUST be ONLY a valid JSON object matching this exact structure:
{
  "foods": [
    {
      "food_name": "string (e.g. Chapati)",
      "serving_description": "string (e.g. 1 medium/serving)",
      "calories": 250,
      "protein": 5.5,
      "carbs": 30.0,
      "fat": 12.0
    }
  ]
}
Return raw JSON only, no markdown markdown blockquotes.
''';

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    });

    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
       debugPrint('❌ Gemini failed: ${response.body}');
       throw Exception('Both FatSecret and Gemini failed to recognize food.');
    }

    final data = jsonDecode(response.body);
    final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
    
    // Clean markdown syntax
    final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final parsed = jsonDecode(cleanJson);
    final foodsList = parsed['foods'] as List<dynamic>? ?? [];

    int index = 0;
    final List<RecognizedFood> foods = foodsList.map((f) {
      index++;
      final name = f['food_name'] ?? 'Unknown Food';
      return RecognizedFood(
        foodId: 999900 + index, // Mock ID for Gemini detection
        name: name,
        units: 1.0,
        servingDescription: f['serving_description'] ?? '1 serving',
        totalMetricAmount: 100, // Normalized unit base
        metricUnit: 'g',
        calories: _parseDoubleGemini(f['calories']),
        protein: _parseDoubleGemini(f['protein']),
        carbs: _parseDoubleGemini(f['carbs']),
        fat: _parseDoubleGemini(f['fat']),
        fiber: 0,
        sugar: 0,
        sodium: 0,
        saturatedFat: 0,
        cholesterol: 0,
        potassium: 0,
        rawJson: f as Map<String, dynamic>,
      );
    }).toList();

    final totalCalories = foods.fold<double>(0, (sum, f) => sum + f.calories).toInt();
    final totalProtein = foods.fold<double>(0, (sum, f) => sum + f.protein);
    final totalCarbs = foods.fold<double>(0, (sum, f) => sum + f.carbs);
    final totalFat = foods.fold<double>(0, (sum, f) => sum + f.fat);

    debugPrint('✅ Gemini returned ${foods.length} items successfully!');

    return FoodRecognitionResult(
      foods: foods,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
  }

  static double _parseDoubleGemini(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  void dispose() {
    _client.close();
  }
}

/// Result of food image recognition
class FoodRecognitionResult {
  final List<RecognizedFood> foods;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  FoodRecognitionResult({
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) {
    final foodResponses = (json['food_response'] as List<dynamic>?) ?? [];

    final foods = foodResponses.map((f) => RecognizedFood.fromJson(f as Map<String, dynamic>)).toList();

    final totalCalories = foods.fold<double>(0, (sum, f) => sum + f.calories).toInt();
    final totalProtein = foods.fold<double>(0, (sum, f) => sum + f.protein);
    final totalCarbs = foods.fold<double>(0, (sum, f) => sum + f.carbs);
    final totalFat = foods.fold<double>(0, (sum, f) => sum + f.fat);

    return FoodRecognitionResult(
      foods: foods,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
  }
}

/// A single recognized food item from the image
class RecognizedFood {
  final int foodId;
  final String name;
  final double units;
  final String servingDescription;
  final double totalMetricAmount;
  final String metricUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double saturatedFat;
  final double cholesterol;
  final double potassium;

  // Raw JSON for creating MealEntity
  final Map<String, dynamic> rawJson;

  RecognizedFood({
    required this.foodId,
    required this.name,
    required this.units,
    required this.servingDescription,
    required this.totalMetricAmount,
    required this.metricUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.saturatedFat,
    required this.cholesterol,
    required this.potassium,
    required this.rawJson,
  });

  factory RecognizedFood.fromJson(Map<String, dynamic> json) {
    final eaten = json['eaten'] as Map<String, dynamic>? ?? {};
    
    Map<String, dynamic> nutrition = eaten['total_nutritional_content'] as Map<String, dynamic>? ?? {};
    
    if (nutrition.isEmpty) {
      try {
        // Fallback: FatSecret sometimes puts the nutrition directly in food -> servings -> serving
        final sugg = json['suggested_serving'] as Map<String, dynamic>? ?? {};
        final defaultFoodInfo = json['food'] as Map<String, dynamic>? ?? {};
        final foodInfo = sugg['food'] as Map<String, dynamic>? ?? defaultFoodInfo;
        
        final servings = foodInfo['servings'] as Map<String, dynamic>? ?? {};
        final servingData = servings['serving'];
        
        if (servingData is List && servingData.isNotEmpty) {
          nutrition = servingData.first as Map<String, dynamic>;
        } else if (servingData is Map<String, dynamic>) {
          nutrition = servingData;
        }
      } catch (e) {
        debugPrint('Fallback parsing error: $e');
      }
    }

    final foodIdStr = json['food_id']?.toString() ?? '0';

    return RecognizedFood(
      foodId: int.tryParse(foodIdStr) ?? 0,
      name: json['food_entry_name'] as String? ?? 'Unknown Food',
      units: _parseDouble(eaten['units'] ?? '1.0'),
      servingDescription: _buildServingDesc(eaten),
      totalMetricAmount: _parseDouble(eaten['total_metric_amount']),
      metricUnit: eaten['metric_description'] as String? ?? 'g',
      calories: _parseDouble(nutrition['calories']),
      protein: _parseDouble(nutrition['protein']),
      carbs: _parseDouble(nutrition['carbohydrate']),
      fat: _parseDouble(nutrition['fat']),
      fiber: _parseDouble(nutrition['fiber']),
      sugar: _parseDouble(nutrition['sugar']),
      sodium: _parseDouble(nutrition['sodium']),
      saturatedFat: _parseDouble(nutrition['saturated_fat']),
      cholesterol: _parseDouble(nutrition['cholesterol']),
      potassium: _parseDouble(nutrition['potassium']),
      rawJson: json,
    );
  }

  static String _buildServingDesc(Map<String, dynamic> eaten) {
    final units = (eaten['units'] as num?)?.toDouble() ?? 1.0;
    final singular = eaten['food_name_singular'] as String? ?? '';
    final plural = eaten['food_name_plural'] as String? ?? '';
    final desc = eaten['singular_description'] as String? ?? '';

    if (units == 1.0 && desc.isNotEmpty) {
      return '1 $desc';
    }
    if (units == 1.0) {
      return '1 $singular';
    }
    return '${units.toStringAsFixed(0)} ${desc.isNotEmpty ? desc : plural}';
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0;
    return 0;
  }

  /// Convert to MealEntity for the existing nutrition diary system
  MealEntity toMealEntity() {
    return MealEntity(
      code: 'fatsecret_$foodId',
      name: name,
      brands: null,
      category: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: 'https://foods.fatsecret.com/calories-nutrition/search?q=$name',
      mealQuantity: totalMetricAmount.toString(),
      mealUnit: metricUnit == 'ml' ? 'ml' : 'g',
      servingQuantity: totalMetricAmount,
      servingUnit: metricUnit == 'ml' ? 'ml' : 'g',
      servingSize: '$totalMetricAmount $metricUnit',
      nutriments: _buildNutriments(),
      source: MealSource.custom, // Uses existing custom source
    );
  }

  MealNutriments _buildNutriments() {
    // Nutriments are per total_metric_amount, normalize to per 100g
    final factor = totalMetricAmount > 0 ? 100.0 / totalMetricAmount : 1.0;
    return MealNutriments(
      energyKcal100: calories * factor,
      carbohydrates100: carbs * factor,
      fat100: fat * factor,
      proteins100: protein * factor,
      fiber100: fiber * factor,
      sugars100: sugar * factor,
      saturatedFat100: saturatedFat * factor,
      sodium100: sodium * factor / 1000, // API gives mg, model expects g
    );
  }
}


class FatSecretException implements Exception {
  final String message;
  final int statusCode;
  FatSecretException(this.message, this.statusCode);

  @override
  String toString() => 'FatSecretException: $message (HTTP $statusCode)';
}
