import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';
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
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(InventoryTable.createTableQuery);
    await db.execute(ShoppingListsTable.createTableQuery);
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
    if (oldVersion < 5) {
      // Create the new shopping_lists table
      await db.execute(ShoppingListsTable.createTableQuery);
      // Add listId column to shopping_list table
      await db.execute(
        'ALTER TABLE ${ShoppingListTable.tableName} ADD COLUMN ${ShoppingListTable.colListId} TEXT',
      );
    }
    if (oldVersion < 6) {
      // Add archive columns to shopping_lists table
      await db.execute(
        'ALTER TABLE ${ShoppingListsTable.tableName} ADD COLUMN ${ShoppingListsTable.colIsArchived} INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE ${ShoppingListsTable.tableName} ADD COLUMN ${ShoppingListsTable.colArchivedAt} TEXT',
      );
    }
  }

  // Clear all user-specific data (for logout/new user)
  Future<void> clearAllUserData() async {
    final db = await database;
    await db.delete(InventoryTable.tableName);
    await db.delete(ShoppingListsTable.tableName);
    await db.delete(ShoppingListTable.tableName);
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

  // Shopping Lists CRUD Operations
  Future<int> insertShoppingList(ShoppingList list) async {
    final db = await database;
    return await db.insert(
      ShoppingListsTable.tableName,
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ShoppingList>> getShoppingLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      ShoppingListsTable.tableName,
      where: '${ShoppingListsTable.colIsArchived} = ?',
      whereArgs: [0],
      orderBy: '${ShoppingListsTable.colShoppingDate} DESC',
    );
    return List.generate(maps.length, (i) {
      return ShoppingList.fromMap(maps[i]);
    });
  }

  Future<List<ShoppingList>> getArchivedShoppingLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      ShoppingListsTable.tableName,
      where: '${ShoppingListsTable.colIsArchived} = ?',
      whereArgs: [1],
      orderBy: '${ShoppingListsTable.colArchivedAt} DESC',
    );
    return List.generate(maps.length, (i) {
      return ShoppingList.fromMap(maps[i]);
    });
  }

  Future<int> archiveShoppingList(String id) async {
    final db = await database;
    return await db.update(
      ShoppingListsTable.tableName,
      {
        ShoppingListsTable.colIsArchived: 1,
        ShoppingListsTable.colArchivedAt: DateTime.now().toIso8601String(),
      },
      where: '${ShoppingListsTable.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreShoppingList(String id) async {
    final db = await database;
    return await db.update(
      ShoppingListsTable.tableName,
      {
        ShoppingListsTable.colIsArchived: 0,
        ShoppingListsTable.colArchivedAt: null,
      },
      where: '${ShoppingListsTable.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExpiredArchivedLists() async {
    final db = await database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    // Get lists to delete (for cascade delete of items)
    final listsToDelete = await db.query(
      ShoppingListsTable.tableName,
      where:
          '${ShoppingListsTable.colIsArchived} = ? AND ${ShoppingListsTable.colArchivedAt} < ?',
      whereArgs: [1, sevenDaysAgo.toIso8601String()],
    );

    // Delete items for each list
    for (final list in listsToDelete) {
      await db.delete(
        ShoppingListTable.tableName,
        where: '${ShoppingListTable.colListId} = ?',
        whereArgs: [list['id']],
      );
    }

    // Delete the lists themselves
    return await db.delete(
      ShoppingListsTable.tableName,
      where:
          '${ShoppingListsTable.colIsArchived} = ? AND ${ShoppingListsTable.colArchivedAt} < ?',
      whereArgs: [1, sevenDaysAgo.toIso8601String()],
    );
  }

  Future<ShoppingList?> getShoppingListById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      ShoppingListsTable.tableName,
      where: '${ShoppingListsTable.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ShoppingList.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateShoppingList(ShoppingList list) async {
    final db = await database;
    return await db.update(
      ShoppingListsTable.tableName,
      list.toMap(),
      where: '${ShoppingListsTable.colId} = ?',
      whereArgs: [list.id],
    );
  }

  Future<int> deleteShoppingList(String id) async {
    final db = await database;
    // First delete all items associated with this list
    await db.delete(
      ShoppingListTable.tableName,
      where: '${ShoppingListTable.colListId} = ?',
      whereArgs: [id],
    );
    // Then delete the list itself
    return await db.delete(
      ShoppingListsTable.tableName,
      where: '${ShoppingListsTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // Shopping List Items CRUD Operations
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

  Future<List<ShoppingItem>> getShoppingItemsByListId(String listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      ShoppingListTable.tableName,
      where: '${ShoppingListTable.colListId} = ?',
      whereArgs: [listId],
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

  Future<int> getShoppingItemCountByListId(String listId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${ShoppingListTable.tableName} WHERE ${ShoppingListTable.colListId} = ?',
      [listId],
    );
    return result.first['count'] as int;
  }

  Future<int> getCheckedItemCountByListId(String listId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${ShoppingListTable.tableName} WHERE ${ShoppingListTable.colListId} = ? AND ${ShoppingListTable.colIsChecked} = 1',
      [listId],
    );
    return result.first['count'] as int;
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
