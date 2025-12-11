import '../database/database_helper.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<InventoryItem>> getInventory() => _dbHelper.getItems();
  Future<void> addItem(InventoryItem item) => _dbHelper.insertItem(item);
  Future<void> updateItem(InventoryItem item) => _dbHelper.updateItem(item);
  Future<void> deleteItem(String id) => _dbHelper.deleteItem(id);
}
