import 'package:equatable/equatable.dart';
import '../../data/models/shopping_item.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();
  @override
  List<Object?> get props => [];
}

// Shopping Lists Events
class LoadShoppingLists extends ShoppingEvent {}

class CreateShoppingList extends ShoppingEvent {
  final String title;
  final DateTime shoppingDate;
  final List<String> initialItems;

  const CreateShoppingList({
    required this.title,
    required this.shoppingDate,
    this.initialItems = const [],
  });

  @override
  List<Object?> get props => [title, shoppingDate, initialItems];
}

class DeleteShoppingList extends ShoppingEvent {
  final String id;
  const DeleteShoppingList(this.id);
  @override
  List<Object?> get props => [id];
}

// Archive Events
class ArchiveShoppingList extends ShoppingEvent {
  final String id;
  const ArchiveShoppingList(this.id);
  @override
  List<Object?> get props => [id];
}

class LoadArchivedLists extends ShoppingEvent {}

class RestoreShoppingList extends ShoppingEvent {
  final String id;
  const RestoreShoppingList(this.id);
  @override
  List<Object?> get props => [id];
}

class DeleteArchivedList extends ShoppingEvent {
  final String id;
  const DeleteArchivedList(this.id);
  @override
  List<Object?> get props => [id];
}

// Shopping List Detail Events
class LoadShoppingListDetail extends ShoppingEvent {
  final String listId;
  const LoadShoppingListDetail(this.listId);
  @override
  List<Object?> get props => [listId];
}

class AddItemToList extends ShoppingEvent {
  final String listId;
  final String itemName;
  const AddItemToList({required this.listId, required this.itemName});
  @override
  List<Object?> get props => [listId, itemName];
}

class ToggleListItem extends ShoppingEvent {
  final ShoppingItem item;
  const ToggleListItem(this.item);
  @override
  List<Object?> get props => [item];
}

class DeleteListItem extends ShoppingEvent {
  final ShoppingItem item;
  const DeleteListItem(this.item);
  @override
  List<Object?> get props => [item];
}
