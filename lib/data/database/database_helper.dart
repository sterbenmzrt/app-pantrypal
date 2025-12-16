import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';
import '../models/shopping_item.dart';
import '../models/user_profile.dart';
import 'schema.dart';

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

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(InventoryTable.createTableQuery);
    await db.execute(ShoppingListTable.createTableQuery);
    await db.execute(UserTable.createTableQuery);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(ShoppingListTable.createTableQuery);
    }
    if (oldVersion < 3) {
      await db.execute(UserTable.createTableQuery);
    }
    if (oldVersion < 4) {
      // Add password column if it doesn't exist (simplest way is checking version)
      // Since we are in dev, we can just alter table or if UserTable was just created in v3 but empty we are fine.
      // If v3 existed, we need to add column.
      await db.execute(
        'ALTER TABLE ${UserTable.tableName} ADD COLUMN ${UserTable.colPassword} TEXT',
      );
    }
  }

  // Inventory CRUD Operations

  Future<int> insertItem(InventoryItem item) async {
    final db = await database;
    return await db.insert(
      InventoryTable.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InventoryItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      InventoryTable.tableName,
      orderBy: '${InventoryTable.colExpiryDate} ASC',
    );
    return List.generate(maps.length, (i) {
      return InventoryItem.fromMap(maps[i]);
    });
  }

  Future<List<InventoryItem>> getLowStockItems(double threshold) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      InventoryTable.tableName,
      where: '${InventoryTable.colQuantity} <= ?',
      whereArgs: [threshold],
    );
    return List.generate(maps.length, (i) {
      return InventoryItem.fromMap(maps[i]);
    });
  }

  Future<int> updateItem(InventoryItem item) async {
    final db = await database;
    return await db.update(
      InventoryTable.tableName,
      item.toMap(),
      where: '${InventoryTable.colId} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(String id) async {
    final db = await database;
    return await db.delete(
      InventoryTable.tableName,
      where: '${InventoryTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // Shopping List CRUD Operations
  Future<int> insertShoppingItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert(
      ShoppingListTable.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ShoppingItem>> getShoppingItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      ShoppingListTable.tableName,
      orderBy:
          '${ShoppingListTable.colIsChecked} ASC, ${ShoppingListTable.colName} ASC',
    );
    return List.generate(maps.length, (i) {
      return ShoppingItem.fromMap(maps[i]);
    });
  }

  Future<int> updateShoppingItem(ShoppingItem item) async {
    final db = await database;
    return await db.update(
      ShoppingListTable.tableName,
      item.toMap(),
      where: '${ShoppingListTable.colId} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteShoppingItem(String id) async {
    final db = await database;
    return await db.delete(
      ShoppingListTable.tableName,
      where: '${ShoppingListTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // User Profile CRUD Operations
  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      UserTable.tableName,
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> saveUserProfile(UserProfile user) async {
    final db = await database;
    // Check if user exists
    final List<Map<String, dynamic>> maps = await db.query(
      UserTable.tableName,
      limit: 1,
    );

    if (maps.isEmpty) {
      // Insert new
      return await db.insert(
        UserTable.tableName,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Update existing
      // Since we only have one user, we can update the first record or by ID if consistent
      // For now we assume single user and update where ID matches or just the first row if ID is null in model but present in DB

      // Better approach for single user: always ensure ID 1 is used or similar.
      // Let's just update the existing row found.
      int idToUpdate = maps.first['id'] as int;
      return await db.update(
        UserTable.tableName,
        user.copyWith(id: idToUpdate).toMap(),
        where: '${UserTable.colId} = ?',
        whereArgs: [idToUpdate],
      );
    }
  }

  Future<UserProfile?> authenticateUser(String email, String password) async {
    print('DB: Authenticating user $email');
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        UserTable.tableName,
        where: '${UserTable.colEmail} = ? AND ${UserTable.colPassword} = ?',
        whereArgs: [email, password],
      );
      print('DB: Auth query found ${maps.length} results');
      if (maps.isNotEmpty) {
        return UserProfile.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('DB: Auth error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserByEmail(String email) async {
    final db = await database;
    print('DB: Checking email $email');
    final List<Map<String, dynamic>> maps = await db.query(
      UserTable.tableName,
      where: '${UserTable.colEmail} = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<UserProfile> registerUser(UserProfile user) async {
    print('DB: Registering user ${user.email}');
    final db = await database;

    // Check if email already exists
    final existing = await getUserByEmail(user.email);
    if (existing != null) {
      print('DB: Email already exists');
      throw Exception('Email already registered');
    }

    try {
      // Insert new user
      final id = await db.insert(UserTable.tableName, user.toMap());
      print('DB: User registered with ID $id');

      return user.copyWith(id: id);
    } catch (e) {
      print('DB: Registration error: $e');
      rethrow;
    }
  }
}
