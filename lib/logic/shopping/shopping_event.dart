import 'package:equatable/equatable.dart';
import '../../data/models/shopping_item.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();
  @override
  List<Object?> get props => [];
}

class LoadShoppingList extends ShoppingEvent {}

class AddShoppingItem extends ShoppingEvent {
  final ShoppingItem item;
  const AddShoppingItem(this.item);
  @override
  List<Object?> get props => [item];
}

class ToggleShoppingItem extends ShoppingEvent {
  final ShoppingItem item;
  const ToggleShoppingItem(this.item);
  @override
  List<Object?> get props => [item];
}

class DeleteShoppingItem extends ShoppingEvent {
  final String id;
  const DeleteShoppingItem(this.id);
  @override
  List<Object?> get props => [id];
}
