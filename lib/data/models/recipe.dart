import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String title;
  final String imageUrl;

  const Recipe({required this.id, required this.title, required this.imageUrl});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? 'Unknown Recipe',
      imageUrl: json['strMealThumb'] ?? '',
    );
  }

  @override
  List<Object> get props => [id, title, imageUrl];
}
