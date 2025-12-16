import 'package:flutter_bloc/flutter_bloc.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';
import '../../data/repositories/recipe_repository.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository repository;

  RecipeBloc({required this.repository}) : super(RecipeInitial()) {
    on<SearchRecipes>(_onSearchRecipes);
    on<LoadMoreRecipes>(_onLoadMoreRecipes);
  }

  Future<void> _onSearchRecipes(
    SearchRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final recipes = await repository.getRecipes(event.query);
      emit(RecipeLoaded(allRecipes: recipes, displayCount: 10));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  void _onLoadMoreRecipes(LoadMoreRecipes event, Emitter<RecipeState> emit) {
    final currentState = state;
    if (currentState is RecipeLoaded && currentState.hasMore) {
      emit(currentState.copyWith(displayCount: currentState.displayCount + 10));
    }
  }
}
