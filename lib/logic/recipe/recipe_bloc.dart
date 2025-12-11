import 'package:flutter_bloc/flutter_bloc.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';
import '../../data/repositories/recipe_repository.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository repository;

  RecipeBloc({required this.repository}) : super(RecipeInitial()) {
    on<SearchRecipes>(_onSearchRecipes);
  }

  Future<void> _onSearchRecipes(
    SearchRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final recipes = await repository.getRecipes(event.query);
      emit(RecipeLoaded(recipes));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }
}
