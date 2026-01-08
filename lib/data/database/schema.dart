class InventoryTable {
  static const String tableName = 'inventory';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCategory = 'category';
  static const String colQuantity = 'quantity';
  static const String colUnit = 'unit';
  static const String colPurchaseDate = 'purchaseDate';
  static const String colExpiryDate = 'expiryDate';
  static const String colAddedDate = 'addedDate';
  static const String colNotes = 'notes';

  static const String createTableQuery = '''
    CREATE TABLE $tableName(
      $colId TEXT PRIMARY KEY,
      $colName TEXT,
      $colCategory TEXT,
      $colQuantity REAL,
      $colUnit TEXT,
      $colPurchaseDate TEXT,
      $colExpiryDate TEXT,
      $colAddedDate TEXT,
      $colNotes TEXT
    )
  ''';
}

class ShoppingListsTable {
  static const String tableName = 'shopping_lists';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colShoppingDate = 'shoppingDate';
  static const String colCreatedAt = 'createdAt';
  static const String colIsArchived = 'isArchived';
  static const String colArchivedAt = 'archivedAt';

  static const String createTableQuery = '''
    CREATE TABLE $tableName(
      $colId TEXT PRIMARY KEY,
      $colTitle TEXT,
      $colShoppingDate TEXT,
      $colCreatedAt TEXT,
      $colIsArchived INTEGER DEFAULT 0,
      $colArchivedAt TEXT
    )
  ''';
}

class ShoppingListTable {
  static const String tableName = 'shopping_list';

  static const String colId = 'id';
  static const String colListId = 'listId';
  static const String colName = 'name';
  static const String colIsChecked = 'isChecked';
  static const String colCategory = 'category';

  static const String createTableQuery = '''
    CREATE TABLE $tableName(
      $colId TEXT PRIMARY KEY,
      $colListId TEXT NOT NULL,
      $colName TEXT,
      $colIsChecked INTEGER DEFAULT 0,
      $colCategory TEXT
    )
  ''';
}

class UserTable {
  static const String tableName = 'user_profile';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colEmail = 'email';
  static const String colPassword = 'password';
  static const String colProfileImage = 'profileImage';

  static const String createTableQuery = '''
    CREATE TABLE $tableName(
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colName TEXT,
      $colEmail TEXT,
      $colPassword TEXT,
      $colProfileImage TEXT
    )
  ''';
}
