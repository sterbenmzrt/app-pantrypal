import 'package:equatable/equatable.dart';
import '../../data/models/inventory_item.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddInventoryItem extends InventoryEvent {
  final InventoryItem item;
  const AddInventoryItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateInventoryItem extends InventoryEvent {
  final InventoryItem item;
  const UpdateInventoryItem(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteInventoryItem extends InventoryEvent {
  final String id;
  const DeleteInventoryItem(this.id);

  @override
  List<Object> get props => [id];
}
