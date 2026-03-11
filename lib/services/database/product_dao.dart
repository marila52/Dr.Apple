import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/product_model.dart';

class ProductDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Вставка продукта
  Future<int> insertProduct(Product product) async {
    Database db = await _dbHelper.database;
    return await db.insert(
      'products',
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Вставка нескольких продуктов (для синхронизации)
  Future<void> insertProducts(List<Product> products) async {
    Database db = await _dbHelper.database;
    Batch batch = db.batch();
    for (var product in products) {
      batch.insert(
        'products',
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  // Получение всех продуктов
  Future<List<Product>> getAllProducts() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  // Поиск продуктов по названию
  Future<List<Product>> searchProducts(String query) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name',
    );
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  // Получение продукта по штрихкоду
  Future<Product?> getProductByBarcode(String barcode) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }
    return null;
  }

  // Получение продукта по ID
  Future<Product?> getProductById(String id) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }
    return null;
  }

  // Получение пользовательских продуктов
  Future<List<Product>> getUserProducts(String userId) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name',
    );
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  // Обновление продукта
  Future<int> updateProduct(Product product) async {
    Database db = await _dbHelper.database;
    return await db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Удаление продукта
  Future<int> deleteProduct(String id) async {
    Database db = await _dbHelper.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Удаление всех продуктов
  Future<void> deleteAllProducts() async {
    Database db = await _dbHelper.database;
    await db.delete('products');
  }
}