import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      // On Web, sqflite_common_ffi_web uses the path as a key in local storage/indexedDB
      path = 'pantry_pal.db';
    } else {
      path = join(await getDatabasesPath(), 'pantry_pal.db');
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inventory(
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        quantity REAL,
        unit TEXT,
        purchaseDate TEXT,
        expiryDate TEXT,
        addedDate TEXT,
        notes TEXT
      )
    ''');
  }

  // CRUD Operations

  Future<int> insertItem(InventoryItem item) async {
    final db = await database;
    return await db.insert(
      'inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InventoryItem>> getItems() async {
    final db = await database;
    // Sort by expiry date ascending
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      orderBy: 'expiryDate ASC',
    );
    return List.generate(maps.length, (i) {
      return InventoryItem.fromMap(maps[i]);
    });
  }

  Future<int> updateItem(InventoryItem item) async {
    final db = await database;
    return await db.update(
      'inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(String id) async {
    final db = await database;
    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }
}
