// lib/services/database/sync_service.dart
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'product_dao.dart';
import 'diary_dao.dart';
import '../firestore_service.dart';
import '../../models/product_model.dart';
import '../../models/diary_entry_model.dart';

class SyncService {
  final ProductDao _productDao = ProductDao();
  final DiaryDao _diaryDao = DiaryDao();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestore = FirestoreService();

  // Полная синхронизация: облако → локально
  Future<void> syncFromCloud(String userId) async {
    try {
      // Получаем продукты пользователя из облака
      final cloudProducts = await _firestore.getUserProducts(userId);
      await _productDao.insertProducts(cloudProducts);
      
      // Получаем записи за последние 30 дней
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final cloudEntries = await _firestore.getEntriesForPeriod(
        userId, 
        thirtyDaysAgo, 
        DateTime.now(),
      );
      await _diaryDao.insertEntries(cloudEntries);
      
      print('Синхронизация из облака завершена');
    } catch (e) {
      print('Ошибка синхронизации из облака: $e');
      rethrow;
    }
  }

  // Полная синхронизация: локально → облако
  Future<void> syncToCloud(String userId) async {
    try {
      // Получаем все локальные продукты пользователя
      final localProducts = await _productDao.getUserProducts(userId);
      await _firestore.saveProducts(localProducts);
      
      // Получаем все локальные записи
      final localEntries = await _getAllLocalEntries(userId);
      await _firestore.saveDiaryEntries(localEntries);
      
      print('Синхронизация в облако завершена');
    } catch (e) {
      print('Ошибка синхронизации в облако: $e');
      rethrow;
    }
  }

  // Двусторонняя синхронизация
  Future<void> syncAll(String userId) async {
    await syncToCloud(userId);
    await syncFromCloud(userId);
  }

  // Сохранить продукт и в локальную БД, и в облако
  Future<void> saveProductSync(Product product) async {
    await _productDao.insertProduct(product);
    await _firestore.saveProduct(product);
  }

  // Сохранить запись и в локальную БД, и в облако
  Future<void> saveEntrySync(DiaryEntry entry) async {
    await _diaryDao.insertEntry(entry);
    await _firestore.saveDiaryEntry(entry);
  }

  // Получить все локальные записи пользователя
  Future<List<DiaryEntry>> _getAllLocalEntries(String userId) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => DiaryEntry.fromJson(map)).toList();
  }

  // Очистить всё при выходе из аккаунта
  Future<void> clearAllData() async {
    await _productDao.deleteAllProducts();
    await _diaryDao.deleteAllEntries(); // нужно добавить этот метод в DiaryDao
  }
}

// Добавить в DiaryDao:
// Future<void> deleteAllEntries() async {
//   Database db = await _dbHelper.database;
//   await db.delete('diary_entries');
// }