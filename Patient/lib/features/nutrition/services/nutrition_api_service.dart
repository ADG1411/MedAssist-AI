// Ported from OpenNutriTracker OFFDataSource + FDCDataSource
// Adapted for MedAssist  returns MealEntity directly, no Sentry, no Hive
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionApiService {
  static const _offBaseUrl = 'https://world.openfoodfacts.org';
  static const _fdcBaseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const _fdcDemoKey = 'DEMO_KEY';
  static const _timeout = Duration(seconds: 20);

  final _client = http.Client();

  // 
  // OpenFoodFacts  word search
  // 
  Future<List<MealEntity>> searchOFF(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final uri = Uri.parse(
        '$_offBaseUrl/cgi/search.pl?search_terms=$encodedQuery&search_simple=1&action=process&json=1&page_size=20&fields=code,product_name,product_name_en,brands,categories_tags,image_front_thumb_url,image_front_url,nutriments,serving_size,serving_quantity,quantity,product_quantity,url',
      );
      final response = await _client.get(uri, headers: {
        'User-Agent': 'MedAssist-AI/1.0 (medical health app)',
      }).timeout(_timeout);

      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final products = (body['products'] as List<dynamic>?) ?? [];
      return products
          .where((p) => p['product_name'] != null || p['product_name_en'] != null)
          .map((p) => MealEntity.fromOFFJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 
  // OpenFoodFacts  barcode scan
  // 
  Future<MealEntity?> fetchOFFByBarcode(String barcode) async {
    try {
      final uri = Uri.parse(
        '$_offBaseUrl/api/v2/product/$barcode.json?fields=code,product_name,product_name_en,brands,image_front_thumb_url,image_front_url,nutriments,serving_size,serving_quantity,quantity,url',
      );
      final response = await _client.get(uri, headers: {
        'User-Agent': 'MedAssist-AI/1.0',
      }).timeout(_timeout);

      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['status'] != 1) return null;
      final product = body['product'] as Map<String, dynamic>?;
      if (product == null) return null;
      return MealEntity.fromOFFJson(product);
    } catch (e) {
      return null;
    }
  }

  // 
  // USDA FoodData Central  word search
  // 
  Future<List<MealEntity>> searchFDC(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse(
        '$_fdcBaseUrl/foods/search?query=${Uri.encodeComponent(query)}&api_key=$_fdcDemoKey&pageSize=15',
      );
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final foods = (body['foods'] as List<dynamic>?) ?? [];
      return foods
          .map((f) => MealEntity.fromFDCJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 
  // Supabase Indian Food DB (IFCT 2017)
  // 
  Future<List<MealEntity>> searchIndianFoods(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final results = await Supabase.instance.client
          .from('nutrition_indian_foods')
          .select()
          .textSearch('food_name', query.trim(), config: 'english')
          .limit(20);
      return (results as List<dynamic>)
          .map((row) => MealEntity.fromIndianDB(row as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback: ilike search
      try {
        final results = await Supabase.instance.client
            .from('nutrition_indian_foods')
            .select()
            .ilike('food_name', '%${query.trim()}%')
            .limit(20);
        return (results as List<dynamic>)
            .map((row) => MealEntity.fromIndianDB(row as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return [];
      }
    }
  }

  // 
  // Cascade search  Indian  OFF  FDC
  // 
  Future<List<MealEntity>> searchAll(String query) async {
    final indian = await searchIndianFoods(query);
    if (indian.isNotEmpty) return indian;

    final off = await searchOFF(query);
    if (off.isNotEmpty) return off;

    return searchFDC(query);
  }
}

