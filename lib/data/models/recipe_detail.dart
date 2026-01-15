import 'package:equatable/equatable.dart';

/// Detailed recipe model with full information from TheMealDB API
class RecipeDetail extends Equatable {
  final String id;
  final String title;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final String? youtubeUrl;
  final List<Ingredient> ingredients;
  final String? sourceUrl;

  const RecipeDetail({
    required this.id,
    required this.title,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    this.youtubeUrl,
    required this.ingredients,
    this.sourceUrl,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    // Parse ingredients and measures
    List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(
          Ingredient(
            name: ingredient.toString().trim(),
            measure: measure?.toString().trim() ?? '',
          ),
        );
      }
    }

    return RecipeDetail(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? 'Unknown Recipe',
      category: json['strCategory'] ?? 'Unknown',
      area: json['strArea'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      sourceUrl: json['strSource'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    area,
    instructions,
    imageUrl,
    youtubeUrl,
    ingredients,
    sourceUrl,
  ];
}

/// Individual ingredient with its measurement
class Ingredient extends Equatable {
  final String name;
  final String measure;

  const Ingredient({required this.name, required this.measure});

  @override
  List<Object> get props => [name, measure];
}
