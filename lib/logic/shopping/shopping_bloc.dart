import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/shopping_repository.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/models/shopping_item.dart';
import 'shopping_event.dart';
import 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  final ShoppingRepository repository;
  final InventoryRepository inventoryRepository;

  ShoppingBloc({required this.repository, InventoryRepository? inventoryRepo})
    : inventoryRepository = inventoryRepo ?? InventoryRepository(),
      super(const ShoppingState()) {
    on<LoadShoppingList>(_onLoadShoppingList);
    on<AddShoppingItem>(_onAddShoppingItem);
    on<ToggleShoppingItem>(_onToggleShoppingItem);
    on<DeleteShoppingItem>(_onDeleteShoppingItem);
  }

  Future<void> _onLoadShoppingList(
    LoadShoppingList event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(status: ShoppingStatus.loading));
    try {
      final items = await repository.getShoppingList();
      final lowStockItems = await inventoryRepository.getLowStockItems();

      // Filter out items already in shopping list
      final existingNames = items.map((e) => e.name.toLowerCase()).toSet();

      final suggestions =
          lowStockItems
              .where(
                (invItem) =>
                    !existingNames.contains(invItem.name.toLowerCase()),
              )
              .map(
                (invItem) => ShoppingItem(
                  id: const Uuid().v4(), // Temporary ID, changes on add
                  name: invItem.name,
                  category: invItem.category,
                  isChecked: false,
                ),
              )
              .toList();

      emit(
        state.copyWith(
          status: ShoppingStatus.loaded,
          items: items,
          suggestions: suggestions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ShoppingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddShoppingItem(
    AddShoppingItem event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      await repository.addItem(event.item);
      add(LoadShoppingList());
    } catch (e) {
      emit(
        state.copyWith(
          status: ShoppingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleShoppingItem(
    ToggleShoppingItem event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      final updatedItem = event.item.copyWith(isChecked: !event.item.isChecked);
      await repository.updateItem(updatedItem);
      add(LoadShoppingList());
    } catch (e) {
      emit(
        state.copyWith(
          status: ShoppingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteShoppingItem(
    DeleteShoppingItem event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      await repository.deleteItem(event.id);
      add(LoadShoppingList());
    } catch (e) {
      emit(
        state.copyWith(
          status: ShoppingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
