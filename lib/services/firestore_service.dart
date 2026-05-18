import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/diary_entry_model.dart';
import '../models/weight_entry_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== ПОЛЬЗОВАТЕЛИ ====================

  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
      print('Пользователь сохранен: ${user.uid}');
    } catch (e) {
      print('Ошибка сохранения пользователя: $e');
      rethrow;
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      print('Ошибка получения пользователя: $e');
      return null;
    }
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
      print('Пользователь обновлен: ${user.uid}');
    } catch (e) {
      print('Ошибка обновления пользователя: $e');
      rethrow;
    }
  }

  // ==================== ПРОДУКТЫ ====================

  Future<void> saveProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toJson());

      print('Продукт сохранен: ${product.name}');
    } catch (e) {
      print('Ошибка сохранения продукта: $e');
      rethrow;
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    try {
      final batch = _firestore.batch();

      for (final product in products) {
        batch.set(
          _firestore.collection('products').doc(product.id),
          product.toJson(),
        );
      }

      await batch.commit();

      print('Сохранено ${products.length} продуктов');
    } catch (e) {
      print('Ошибка массового сохранения продуктов: $e');
      rethrow;
    }
  }

  Future<Product?> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();

      if (!doc.exists) return null;

      return Product.fromJson(doc.data()!);
    } catch (e) {
      print('Ошибка получения продукта: $e');
      return null;
    }
  }

  Future<List<Product>> getUserProducts(String userId) async {
    try {
      final query = await _firestore
          .collection('products')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка получения продуктов пользователя: $e');
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query, {String? userId}) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка поиска продуктов: $e');
      return [];
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      print('Продукт удален: $id');
    } catch (e) {
      print('Ошибка удаления продукта: $e');
      rethrow;
    }
  }

  // ==================== ДНЕВНИК ПИТАНИЯ ====================

  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    try {
      await _firestore
          .collection('diary_entries')
          .doc(entry.id)
          .set(entry.toJson());

      print('Запись сохранена: ${entry.id}');
    } catch (e) {
      print('Ошибка сохранения записи: $e');
      rethrow;
    }
  }

  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    try {
      await _firestore
          .collection('diary_entries')
          .doc(entry.id)
          .update(entry.toJson());

      print('Запись обновлена: ${entry.id}');
    } catch (e) {
      print('Ошибка обновления записи: $e');
      rethrow;
    }
  }

  Future<void> deleteDiaryEntry(String id) async {
    try {
      await _firestore.collection('diary_entries').doc(id).delete();
      print('Запись удалена: $id');
    } catch (e) {
      print('Ошибка удаления записи: $e');
      rethrow;
    }
  }

  Future<void> saveDiaryEntries(List<DiaryEntry> entries) async {
    try {
      final batch = _firestore.batch();

      for (final entry in entries) {
        batch.set(
          _firestore.collection('diary_entries').doc(entry.id),
          entry.toJson(),
        );
      }

      await batch.commit();
      print('Сохранено ${entries.length} записей');
    } catch (e) {
      print('Ошибка массового сохранения записей: $e');
      rethrow;
    }
  }

  Future<List<DiaryEntry>> getEntriesForPeriod(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final query = await _firestore
          .collection('diary_entries')
          .where('userId', isEqualTo: userId)
          .where('dateTime', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('dateTime', isLessThanOrEqualTo: end.toIso8601String())
          .orderBy('dateTime')
          .get();

      return query.docs
          .map((doc) => DiaryEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка получения записей за период: $e');
      return [];
    }
  }

  Future<List<DiaryEntry>> getDailyEntries(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _firestore
          .collection('diary_entries')
          .where('userId', isEqualTo: userId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where(
            'dateTime',
            isLessThan: endOfDay.toIso8601String(),
          )
          .orderBy('dateTime')
          .get();

      return query.docs
          .map((doc) => DiaryEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка получения записей: $e');
      return [];
    }
  }

  // ==================== ЕЖЕДНЕВНЫЙ ДНЕВНИК ====================

  Future<void> saveDailyDiary({
    required String userId,
    required DateTime date,
    required int waterIntake,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
    required Map<String, dynamic> meals,
  }) async {
    try {
      final dateKey =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_diary')
          .doc(dateKey)
          .set({
        'date': dateKey,
        'waterIntake': waterIntake,
        'calories': calories,
        'proteins': proteins,
        'fats': fats,
        'carbs': carbs,
        'meals': meals,
        'updatedAt': FieldValue.serverTimestamp(),
      });


      print('Дневник за день сохранен');
    } catch (e) {
      print('Ошибка сохранения дневника: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDailyDiary({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final dateKey =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_diary')
          .doc(dateKey)
          .get();


      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      print('Ошибка загрузки дневника: $e');
      return null;
    }
  }

  // ==================== ИСТОРИЯ ВЕСА ====================

  Future<void> saveWeightEntry(WeightEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(entry.userId)
          .collection('weight_history')
          .doc(entry.id)
          .set(entry.toJson());
    } catch (e) {
      print('Ошибка сохранения веса: $e');
      rethrow;
    }
  }

  Future<List<WeightEntry>> getWeightHistory(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weight_history')
          .orderBy('recordedAt')
          .get();

      return query.docs
          .map((doc) => WeightEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка загрузки истории веса: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDiaryHistory(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_diary')
          .orderBy('date', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Ошибка получения истории дневника: $e');
      return [];
    }
  }
}