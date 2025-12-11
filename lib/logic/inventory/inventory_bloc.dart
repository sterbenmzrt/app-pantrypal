import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';
import '../../data/repositories/inventory_repository.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc({required this.repository}) : super(InventoryLoading()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddInventoryItem>(_onAddItem);
    on<UpdateInventoryItem>(_onUpdateItem);
    on<DeleteInventoryItem>(_onDeleteItem);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await repository.getInventory();
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError("Failed to load inventory: $e"));
    }
  }

  Future<void> _onAddItem(
    AddInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await repository.addItem(event.item);
      add(LoadInventory()); // Reload to ensure sort/consistency
    } catch (e) {
      emit(InventoryError("Failed to add item: $e"));
    }
  }

  Future<void> _onUpdateItem(
    UpdateInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await repository.updateItem(event.item);
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError("Failed to update item: $e"));
    }
  }

  Future<void> _onDeleteItem(
    DeleteInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await repository.deleteItem(event.id);
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError("Failed to delete item: $e"));
    }
  }
}
