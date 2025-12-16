import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pantry_pal/data/models/inventory_item.dart';

void main() {
  // Use ffi for in-memory database tests
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // dbHelper = DatabaseHelper();
    // Since DatabaseHelper is a singleton...
  });

  // Given we didn't modify DatabaseHelper to accept an override path for testing,
  // and we want unit tests, we should probably refactor DatabaseHelper slightly to allow testing,
  // OR we mock the database factory if possible.
  // But simpler is to modify DatabaseHelper to be testable.

  // Let's modify DatabaseHelper to optionally verify the fix, but first let's see if we can just run it.

  test('InventoryItem toMap and fromMap', () {
    final item = InventoryItem(
      id: '1',
      name: 'Test Apple',
      category: 'Fruit',
      quantity: 5.0,
      unit: 'kg',
      purchaseDate: DateTime(2023, 1, 1),
      expiryDate: DateTime(2023, 1, 10),
      addedDate: DateTime(2023, 1, 1),
      notes: 'Fresh',
    );

    final map = item.toMap();
    expect(map['id'], '1');
    expect(map['name'], 'Test Apple');

    final fromMap = InventoryItem.fromMap(map);
    expect(fromMap.id, item.id);
    expect(fromMap.name, item.name);
  });
}
