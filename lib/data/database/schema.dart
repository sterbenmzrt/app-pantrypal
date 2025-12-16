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

class ShoppingListTable {
  static const String tableName = 'shopping_list';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colIsChecked = 'isChecked';
  static const String colCategory = 'category';

  static const String createTableQuery = '''
    CREATE TABLE $tableName(
      $colId TEXT PRIMARY KEY,
      $colName TEXT,
      $colIsChecked INTEGER,
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
