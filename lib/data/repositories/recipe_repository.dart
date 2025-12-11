import '../content/recipe_provider.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final RecipeProvider _provider = RecipeProvider();

  Future<List<Recipe>> getRecipes(String ingredients) =>
      _provider.searchRecipesByIngredient(ingredients);
}
