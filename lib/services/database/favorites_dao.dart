import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/product_model.dart';
import 'database_helper.dart';
import 'product_dao.dart';

class FavoritesDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ProductDao _productDao = ProductDao();

  Future<void> add(String userId, String productId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'favorites',
      {
        'userId': userId,
        'productId': productId,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> remove(String userId, String productId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'favorites',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<bool> isFavorite(String userId, String productId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'favorites',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<Product>> getFavoriteProducts(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    final products = <Product>[];
    for (final row in rows) {
      final product =
          await _productDao.getProductById(row['productId'] as String);
      if (product != null) {
        products.add(product);
      }
    }
    return products;
  }
}
