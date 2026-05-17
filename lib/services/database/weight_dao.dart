import 'package:sqflite/sqflite.dart';

import '../../models/weight_entry_model.dart';
import 'database_helper.dart';

class WeightDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insert(WeightEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert(
      'weight_history',
      {
        'id': entry.id,
        'userId': entry.userId,
        'weight': entry.weight,
        'recordedAt': entry.recordedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WeightEntry>> getByUser(String userId, {int? limit}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'weight_history',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'recordedAt ASC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  Future<void> replaceAllForUser(String userId, List<WeightEntry> entries) async {
    final db = await _dbHelper.database;
    await db.delete('weight_history', where: 'userId = ?', whereArgs: [userId]);
    final batch = db.batch();
    for (final entry in entries) {
      batch.insert('weight_history', {
        'id': entry.id,
        'userId': entry.userId,
        'weight': entry.weight,
        'recordedAt': entry.recordedAt.toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  WeightEntry createEntry({
    required String userId,
    required double weight,
    DateTime? recordedAt,
  }) {
    final at = recordedAt ?? DateTime.now();
    return WeightEntry(
      id: '${userId}_${at.millisecondsSinceEpoch}',
      userId: userId,
      weight: weight,
      recordedAt: at,
    );
  }

  WeightEntry _fromRow(Map<String, dynamic> row) {
    return WeightEntry(
      id: row['id'] as String,
      userId: row['userId'] as String,
      weight: (row['weight'] as num).toDouble(),
      recordedAt: DateTime.parse(row['recordedAt'] as String),
    );
  }
}
