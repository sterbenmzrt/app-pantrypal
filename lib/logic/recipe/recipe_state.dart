import 'package:equatable/equatable.dart';
import '../../data/models/recipe.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();
  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoadingMore extends RecipeState {
  final List<Recipe> currentRecipes;
  final int displayCount;
  const RecipeLoadingMore(this.currentRecipes, this.displayCount);
  @override
  List<Object> get props => [currentRecipes, displayCount];
}

class RecipeLoaded extends RecipeState {
  final List<Recipe> allRecipes;
  final int displayCount;

  const RecipeLoaded({required this.allRecipes, this.displayCount = 10});

  List<Recipe> get recipes => allRecipes.take(displayCount).toList();
  bool get hasMore => displayCount < allRecipes.length;

  RecipeLoaded copyWith({List<Recipe>? allRecipes, int? displayCount}) {
    return RecipeLoaded(
      allRecipes: allRecipes ?? this.allRecipes,
      displayCount: displayCount ?? this.displayCount,
    );
  }

  @override
  List<Object> get props => [allRecipes, displayCount];
}

class RecipeError extends RecipeState {
  final String message;
  const RecipeError(this.message);
  @override
  List<Object> get props => [message];
}
