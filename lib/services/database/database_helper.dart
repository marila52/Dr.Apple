import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import '../../models/product_model.dart';
// import '../../models/diary_entry_model.dart';  // 👈 УДАЛИ ЭТУ СТРОКУ

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dr_apple.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Создание таблицы продуктов
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        calories REAL NOT NULL,
        proteins REAL NOT NULL,
        fats REAL NOT NULL,
        carbs REAL NOT NULL,
        fiber REAL,
        barcode TEXT,
        imageUrl TEXT,
        isCustom INTEGER NOT NULL,
        userId TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Создание таблицы записей дневника
    await db.execute('''
      CREATE TABLE diary_entries(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantity REAL NOT NULL,
        dateTime TEXT NOT NULL,
        mealType TEXT NOT NULL,
        productCaloriesPer100g REAL NOT NULL,
        productProteinsPer100g REAL NOT NULL,
        productFatsPer100g REAL NOT NULL,
        productCarbsPer100g REAL NOT NULL,
        productSnapshot TEXT,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Индекс для быстрого поиска по дате
    await db.execute('CREATE INDEX idx_diary_entries_date ON diary_entries(dateTime)');
    
    // Индекс для поиска по штрихкоду
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Здесь будут миграции при обновлении версии БД
  }
}