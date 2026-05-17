import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/diary_entry_model.dart';

class DiaryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Вставка записи
  Future<int> insertEntry(DiaryEntry entry) async {
    Database db = await _dbHelper.database;
    return await db.insert(
      'diary_entries',
      entry.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Вставка нескольких записей
  Future<void> insertEntries(List<DiaryEntry> entries) async {
    Database db = await _dbHelper.database;
    Batch batch = db.batch();
    for (var entry in entries) {
      batch.insert(
        'diary_entries',
        entry.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  // Получение записей за день
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date, String userId) async {
    Database db = await _dbHelper.database;
    
    // Начало и конец выбранного дня
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'userId = ? AND dateTime >= ? AND dateTime < ?',
      whereArgs: [
        userId, 
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String()
      ],
      orderBy: 'dateTime',
    );
    
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromJson(maps[i]);
    });
  }

  // Получение записей за период
  Future<List<DiaryEntry>> getEntriesForPeriod(
    DateTime start, 
    DateTime end, 
    String userId
  ) async {
    Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'userId = ? AND dateTime >= ? AND dateTime <= ?',
      whereArgs: [
        userId,
        start.toIso8601String(),
        end.toIso8601String()
      ],
      orderBy: 'dateTime',
    );
    
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromJson(maps[i]);
    });
  }

  // Получение записи по ID
  Future<DiaryEntry?> getEntryById(String id) async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DiaryEntry.fromJson(maps.first);
    }
    return null;
  }

  // Обновление записи
  Future<int> updateEntry(DiaryEntry entry) async {
    Database db = await _dbHelper.database;
    return await db.update(
      'diary_entries',
      entry.toJson(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Удаление записи
  Future<int> deleteEntry(String id) async {
    Database db = await _dbHelper.database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Удаление записей за день
  Future<int> deleteEntriesForDate(DateTime date, String userId) async {
    Database db = await _dbHelper.database;
    
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await db.delete(
      'diary_entries',
      where: 'userId = ? AND dateTime >= ? AND dateTime < ?',
      whereArgs: [
        userId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String()
      ],
    );
  }

  // 👇 НОВЫЙ МЕТОД: Удаление всех записей
  Future<void> deleteAllEntries() async {
    Database db = await _dbHelper.database;
    await db.delete('diary_entries');
    print('Все записи дневника удалены');
  }

  // Получение статистики за день (суммы КБЖУ)
  Future<Map<String, double>> getDailySummary(DateTime date, String userId) async {
    final entries = await getEntriesByDate(date, userId);
    
    double totalCalories = 0;
    double totalProteins = 0;
    double totalFats = 0;
    double totalCarbs = 0;
    
    for (var entry in entries) {
      totalCalories += entry.calories;
      totalProteins += entry.proteins;
      totalFats += entry.fats;
      totalCarbs += entry.carbs;
    }
    
    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'fats': totalFats,
      'carbs': totalCarbs,
    };
  }
}