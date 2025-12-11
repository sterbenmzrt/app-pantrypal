import 'package:dio/dio.dart';
import '../models/recipe.dart';

class RecipeProvider {
  final Dio _dio = Dio();
  final String _baseUrl = "https://www.themealdb.com/api/json/v1/1";

  Future<List<Recipe>> searchRecipesByIngredient(String ingredient) async {
    try {
      // TheMealDB uses comma separation for mult-ingredient (sometimes flaky on free tier, but we'll try)
      // Or just search by the primary one.
      final response = await _dio.get(
        "$_baseUrl/filter.php",
        queryParameters: {'i': ingredient},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] == null) return [];

        return (data['meals'] as List).map((e) => Recipe.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load recipes");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
