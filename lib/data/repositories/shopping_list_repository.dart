import '../database/database_helper.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

class ShoppingListRepository {
  final DatabaseHelper _dbHelper;

  ShoppingListRepository({DatabaseHelper? helper})
    : _dbHelper = helper ?? DatabaseHelper();

  // Shopping Lists
  Future<List<ShoppingList>> getShoppingLists() => _dbHelper.getShoppingLists();

  Future<ShoppingList?> getShoppingListById(String id) =>
      _dbHelper.getShoppingListById(id);

  Future<void> createShoppingList(ShoppingList list) =>
      _dbHelper.insertShoppingList(list);

  Future<void> updateShoppingList(ShoppingList list) =>
      _dbHelper.updateShoppingList(list);

  Future<void> deleteShoppingList(String id) =>
      _dbHelper.deleteShoppingList(id);

  // Archive Operations
  Future<List<ShoppingList>> getArchivedShoppingLists() =>
      _dbHelper.getArchivedShoppingLists();

  Future<void> archiveShoppingList(String id) =>
      _dbHelper.archiveShoppingList(id);

  Future<void> restoreShoppingList(String id) =>
      _dbHelper.restoreShoppingList(id);

  Future<int> deleteExpiredArchivedLists() =>
      _dbHelper.deleteExpiredArchivedLists();

  // Shopping Items
  Future<List<ShoppingItem>> getItemsByListId(String listId) =>
      _dbHelper.getShoppingItemsByListId(listId);

  Future<void> addItem(ShoppingItem item) => _dbHelper.insertShoppingItem(item);

  Future<void> updateItem(ShoppingItem item) =>
      _dbHelper.updateShoppingItem(item);

  Future<void> deleteItem(String id) => _dbHelper.deleteShoppingItem(id);

  // Stats
  Future<int> getItemCount(String listId) =>
      _dbHelper.getShoppingItemCountByListId(listId);

  Future<int> getCheckedItemCount(String listId) =>
      _dbHelper.getCheckedItemCountByListId(listId);
}
