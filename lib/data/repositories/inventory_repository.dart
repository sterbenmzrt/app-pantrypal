import '../database/database_helper.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  final DatabaseHelper _dbHelper;

  InventoryRepository({DatabaseHelper? helper})
    : _dbHelper = helper ?? DatabaseHelper();

  Future<List<InventoryItem>> getInventory() => _dbHelper.getItems();

  Future<List<InventoryItem>> getLowStockItems({double threshold = 2.0}) =>
      _dbHelper.getLowStockItems(threshold);

  Future<void> addItem(InventoryItem item) => _dbHelper.insertItem(item);
  Future<void> updateItem(InventoryItem item) => _dbHelper.updateItem(item);
  Future<void> deleteItem(String id) => _dbHelper.deleteItem(id);
}
