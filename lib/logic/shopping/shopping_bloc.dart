import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../data/models/shopping_list.dart';
import '../../data/models/shopping_item.dart';
import 'shopping_event.dart';
import 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  final ShoppingListRepository repository;

  ShoppingBloc({required this.repository}) : super(const ShoppingState()) {
    on<LoadShoppingLists>(_onLoadShoppingLists);
    on<CreateShoppingList>(_onCreateShoppingList);
    on<DeleteShoppingList>(_onDeleteShoppingList);
    on<ArchiveShoppingList>(_onArchiveShoppingList);
    on<LoadArchivedLists>(_onLoadArchivedLists);
    on<RestoreShoppingList>(_onRestoreShoppingList);
    on<DeleteArchivedList>(_onDeleteArchivedList);
    on<LoadShoppingListDetail>(_onLoadShoppingListDetail);
    on<AddItemToList>(_onAddItemToList);
    on<ToggleListItem>(_onToggleListItem);
    on<DeleteListItem>(_onDeleteListItem);
  }

  Future<void> _onLoadShoppingLists(
    LoadShoppingLists event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(status: ShoppingStatus.loading));
    try {
      // Auto-cleanup expired archived lists
      await repository.deleteExpiredArchivedLists();

      final lists = await repository.getShoppingLists();

      // Get item counts for each list
      final Map<String, int> itemCounts = {};
      final Map<String, int> checkedCounts = {};

      for (final list in lists) {
        itemCounts[list.id] = await repository.getItemCount(list.id);
        checkedCounts[list.id] = await repository.getCheckedItemCount(list.id);
      }

      emit(
        state.copyWith(
          status: ShoppingStatus.loaded,
          shoppingLists: lists,
          itemCounts: itemCounts,
          checkedCounts: checkedCounts,
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

  Future<void> _onCreateShoppingList(
    CreateShoppingList event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      final newList = ShoppingList(
        id: const Uuid().v4(),
        title: event.title,
        shoppingDate: event.shoppingDate,
        createdAt: DateTime.now(),
      );

      await repository.createShoppingList(newList);

      // Add initial items if provided
      for (final itemName in event.initialItems) {
        if (itemName.trim().isNotEmpty) {
          final item = ShoppingItem(
            id: const Uuid().v4(),
            listId: newList.id,
            name: itemName.trim(),
            category: 'Uncategorized',
          );
          await repository.addItem(item);
        }
      }

      add(LoadShoppingLists());
    } catch (e) {
      emit(
        state.copyWith(
          status: ShoppingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteShoppingList(
    DeleteShoppingList event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      await repository.deleteShoppingList(event.id);
      add(LoadShoppingLists());
    } catch (e) {
      emit(
        state.copyWith(
          status: ShoppingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onArchiveShoppingList(
    ArchiveShoppingList event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      await repository.archiveShoppingList(event.id);
      add(LoadShoppingLists());
    } catch (e) {
      emit(
        state.copyWith(
          status: ShoppingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadArchivedLists(
    LoadArchivedLists event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(archiveStatus: ArchiveStatus.loading));
    try {
      final archivedLists = await repository.getArchivedShoppingLists();
      emit(
        state.copyWith(
          archiveStatus: ArchiveStatus.loaded,
          archivedLists: archivedLists,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          archiveStatus: ArchiveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRestoreShoppingList(
    RestoreShoppingList event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      await repository.restoreShoppingList(event.id);
      add(LoadArchivedLists());
      add(LoadShoppingLists()); // Refresh main list as well
    } catch (e) {
      emit(
        state.copyWith(
          archiveStatus: ArchiveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteArchivedList(
    DeleteArchivedList event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      await repository.deleteShoppingList(event.id);
      add(LoadArchivedLists());
    } catch (e) {
      emit(
        state.copyWith(
          archiveStatus: ArchiveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadShoppingListDetail(
    LoadShoppingListDetail event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(detailStatus: ShoppingDetailStatus.loading));
    try {
      final list = await repository.getShoppingListById(event.listId);
      final items = await repository.getItemsByListId(event.listId);

      emit(
        state.copyWith(
          detailStatus: ShoppingDetailStatus.loaded,
          currentList: list,
          currentListItems: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: ShoppingDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddItemToList(
    AddItemToList event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      final item = ShoppingItem(
        id: const Uuid().v4(),
        listId: event.listId,
        name: event.itemName,
        category: 'Uncategorized',
      );
      await repository.addItem(item);
      add(LoadShoppingListDetail(event.listId));
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: ShoppingDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleListItem(
    ToggleListItem event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      final updatedItem = event.item.copyWith(isChecked: !event.item.isChecked);
      await repository.updateItem(updatedItem);
      add(LoadShoppingListDetail(event.item.listId));
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: ShoppingDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteListItem(
    DeleteListItem event,
    Emitter<ShoppingState> emit,
  ) async {
    try {
      await repository.deleteItem(event.item.id);
      add(LoadShoppingListDetail(event.item.listId));
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: ShoppingDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
