import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../models/diary_entry_model.dart';
import '../../models/weight_entry_model.dart';

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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Создание таблицы пользователей
    await _createUsersTable(db);
    
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

    await _createWeightHistoryTable(db);
    await _createFavoritesTable(db);
    await _createAppSettingsTable(db);
    
    // Загружаем продукты из JSON
    await _loadProductsFromAssets(db);
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        uid TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        name TEXT,
        gender TEXT,
        weight REAL,
        height REAL,
        age INTEGER,
        activityLevel TEXT,
        goal TEXT,
        dailyCalories REAL,
        dailyProteins REAL,
        dailyFats REAL,
        dailyCarbs REAL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  Future<void> _createWeightHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS weight_history(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        weight REAL NOT NULL,
        recordedAt TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_weight_history_user ON weight_history(userId, recordedAt)',
    );
  }

  Future<void> _createFavoritesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites(
        userId TEXT NOT NULL,
        productId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        PRIMARY KEY (userId, productId)
      )
    ''');
  }

  Future<void> _createAppSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        userId TEXT NOT NULL,
        settingKey TEXT NOT NULL,
        settingValue TEXT NOT NULL,
        PRIMARY KEY (userId, settingKey)
      )
    ''');
  }

  Future<void> _loadProductsFromAssets(Database db) async {
    final jsonString = await rootBundle.loadString('assets/products.json');
    final List<dynamic> products = json.decode(jsonString);
    
    for (final p in products) {
      await db.insert('products', {
        'id': p['id'],
        'name': p['name'],
        'brand': p['brand'] ?? '',
        'calories': p['calories'],
        'proteins': p['proteins'],
        'fats': p['fats'],
        'carbs': p['carbs'],
        'isCustom': 0,
        'userId': null,
        'createdAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createWeightHistoryTable(db);
    }
    if (oldVersion < 3) {
      await _createFavoritesTable(db);
      await _createAppSettingsTable(db);
    }
    if (oldVersion < 4) {
      await _createUsersTable(db);
    }
  }
}