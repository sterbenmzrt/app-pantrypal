import '../database/database_helper.dart';
import '../models/shopping_item.dart';

class ShoppingRepository {
  final DatabaseHelper _dbHelper;

  ShoppingRepository({DatabaseHelper? helper})
    : _dbHelper = helper ?? DatabaseHelper();

  Future<List<ShoppingItem>> getShoppingList() => _dbHelper.getShoppingItems();

  Future<void> addItem(ShoppingItem item) => _dbHelper.insertShoppingItem(item);

  Future<void> updateItem(ShoppingItem item) =>
      _dbHelper.updateShoppingItem(item);

  Future<void> deleteItem(String id) => _dbHelper.deleteShoppingItem(id);
}
