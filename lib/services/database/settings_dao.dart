import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'database_helper.dart';

class SettingsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<String?> get(String userId, String key) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'app_settings',
      where: 'userId = ? AND settingKey = ?',
      whereArgs: [userId, key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['settingValue'] as String;
  }

  Future<void> set(String userId, String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'app_settings',
      {
        'userId': userId,
        'settingKey': key,
        'settingValue': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAll(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'app_settings',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return {
      for (final row in rows)
        row['settingKey'] as String: row['settingValue'] as String,
    };
  }
}
