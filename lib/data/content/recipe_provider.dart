import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

class RecipeProvider {
  final Dio _dio;
  final String _baseUrl = "https://www.themealdb.com/api/json/v1/1";

  RecipeProvider({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              // Enable HTTPS certificate validation
              validateStatus: (status) => status != null && status < 500,
            ),
          );

  Future<List<Recipe>> searchRecipesByIngredient(String ingredient) async {
    try {
      // Sanitize input
      final sanitizedIngredient = ingredient.trim();
      if (sanitizedIngredient.isEmpty) {
        return [];
      }

      final response = await _dio.get(
        "$_baseUrl/filter.php",
        queryParameters: {'i': sanitizedIngredient},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] == null) return [];

        return (data['meals'] as List).map((e) => Recipe.fromJson(e)).toList();
      } else {
        // Log internally but don't expose to user
        debugPrint('Recipe API returned status: ${response.statusCode}');
        throw RecipeException('Unable to load recipes. Please try again.');
      }
    } on DioException catch (e) {
      // Log the actual error internally
      debugPrint('Recipe API error: ${e.type}');

      // Return user-friendly error based on type
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw RecipeException(
            'Connection timed out. Please check your internet connection.',
          );
        case DioExceptionType.connectionError:
          throw RecipeException(
            'No internet connection. Please try again when connected.',
          );
        default:
          throw RecipeException(
            'Unable to load recipes. Please try again later.',
          );
      }
    } catch (e) {
      if (e is RecipeException) rethrow;
      // Log unknown errors internally
      debugPrint('Unknown recipe error occurred');
      throw RecipeException('An unexpected error occurred. Please try again.');
    }
  }

  /// Fetches detailed recipe information by meal ID.
  Future<RecipeDetail> getRecipeDetails(String mealId) async {
    try {
      if (mealId.isEmpty) {
        throw RecipeException('Invalid recipe ID.');
      }

      final response = await _dio.get(
        "$_baseUrl/lookup.php",
        queryParameters: {'i': mealId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] == null || (data['meals'] as List).isEmpty) {
          throw RecipeException('Recipe not found.');
        }

        return RecipeDetail.fromJson(data['meals'][0]);
      } else {
        debugPrint('Recipe API returned status: ${response.statusCode}');
        throw RecipeException(
          'Unable to load recipe details. Please try again.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Recipe API error: ${e.type}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw RecipeException(
            'Connection timed out. Please check your internet connection.',
          );
        case DioExceptionType.connectionError:
          throw RecipeException(
            'No internet connection. Please try again when connected.',
          );
        default:
          throw RecipeException(
            'Unable to load recipe details. Please try again later.',
          );
      }
    } catch (e) {
      if (e is RecipeException) rethrow;
      debugPrint('Unknown recipe error occurred');
      throw RecipeException('An unexpected error occurred. Please try again.');
    }
  }
}

/// Custom exception for recipe-related errors with user-friendly messages.
class RecipeException implements Exception {
  final String message;

  RecipeException(this.message);

  @override
  String toString() => message;
}
