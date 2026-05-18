import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/user_model.dart';
import 'dart:convert';
import 'dart:math';
import 'database_helper.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Создание таблицы пользователей
  Future<void> createTable(Database db) async {
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

  // Хеширование пароля (простой способ для локального хранения)
  String _hashPassword(String password) {
    // В реальном проекте используйте bcrypt или argon2
    // Здесь для простоты - base64 + соль
    final salt = 'dr_apple_salt_2025';
    final combined = password + salt;
    return base64.encode(utf8.encode(combined));
  }

  // Проверка пароля
  bool _verifyPassword(String password, String hash) {
    final computedHash = _hashPassword(password);
    return computedHash == hash;
  }

  // Регистрация нового пользователя
  Future<bool> registerUser(AppUser user, String password) async {
    final db = await _dbHelper.database;
    try {
      final hash = _hashPassword(password);
      await db.insert(
        'users',
        {
          'uid': user.uid,
          'email': user.email,
          'passwordHash': hash,
          'name': user.name,
          'gender': user.gender?.name,
          'weight': user.weight,
          'height': user.height,
          'age': user.age,
          'activityLevel': user.activityLevel?.name,
          'goal': user.goal?.name,
          'dailyCalories': user.dailyCalories,
          'dailyProteins': user.dailyProteins,
          'dailyFats': user.dailyFats,
          'dailyCarbs': user.dailyCarbs,
          'createdAt': user.createdAt.toIso8601String(),
          'updatedAt': user.updatedAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Ошибка регистрации пользователя: $e');
      return false;
    }
  }

  // Вход пользователя
  Future<AppUser?> loginUser(String email, String password) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final storedHash = row['passwordHash'] as String;
    if (!_verifyPassword(password, storedHash)) return null;
    return AppUser.fromJson(row);
  }

  // Получение пользователя по uid
  Future<AppUser?> getUserByUid(String uid) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (rows.isEmpty) return null;
    return AppUser.fromJson(rows.first);
  }

  // Получение пользователя по email
  Future<AppUser?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (rows.isEmpty) return null;
    return AppUser.fromJson(rows.first);
  }

  // Обновление пользователя
  Future<bool> updateUser(AppUser user) async {
    final db = await _dbHelper.database;
    try {
      await db.update(
        'users',
        {
          'name': user.name,
          'gender': user.gender?.name,
          'weight': user.weight,
          'height': user.height,
          'age': user.age,
          'activityLevel': user.activityLevel?.name,
          'goal': user.goal?.name,
          'dailyCalories': user.dailyCalories,
          'dailyProteins': user.dailyProteins,
          'dailyFats': user.dailyFats,
          'dailyCarbs': user.dailyCarbs,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'uid = ?',
        whereArgs: [user.uid],
      );
      return true;
    } catch (e) {
      print('Ошибка обновления пользователя: $e');
      return false;
    }
  }
}