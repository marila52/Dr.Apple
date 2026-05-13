// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_model.dart';
// import '../models/product_model.dart';
// import '../models/diary_entry_model.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // ==================== ПОЛЬЗОВАТЕЛИ ====================

//   // Сохранить данные пользователя
//   Future<void> saveUser(AppUser user) async {
//     try {
//       await _firestore.collection('users').doc(user.uid).set(user.toJson());
//       print('Пользователь сохранен: ${user.uid}');
//     } catch (e) {
//       print('Ошибка сохранения пользователя: $e');
//       rethrow;
//     }
//   }

//   // Получить пользователя
//   Future<AppUser?> getUser(String uid) async {
//     try {
//       final doc = await _firestore.collection('users').doc(uid).get();
//       if (doc.exists) {
//         return AppUser.fromJson(doc.data()!);
//       }
//       return null;
//     } catch (e) {
//       print('Ошибка получения пользователя: $e');
//       return null;
//     }
//   }

//   // Обновить данные пользователя
//   Future<void> updateUser(AppUser user) async {
//     try {
//       await _firestore.collection('users').doc(user.uid).update(user.toJson());
//       print('Пользователь обновлен: ${user.uid}');
//     } catch (e) {
//       print('Ошибка обновления пользователя: $e');
//       rethrow;
//     }
//   }

//   Future<void> saveWaterIntake({
//     required String userId,
//     required DateTime date,
//     required int waterIntake,
//   }) async {
//     try {
//       final dateKey =
//           '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

//       await _firestore
//           .collection('water_entries')
//           .doc('${userId}_$dateKey')
//           .set({
//         'userId': userId,
//         'date': dateKey,
//         'waterIntake': waterIntake,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       print('Ошибка сохранения воды: $e');
//     }
//   }

//   Future<int> getWaterIntake({
//     required String userId,
//     required DateTime date,
//   }) async {
//     try {
//       final dateKey =
//           '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

//       final doc = await _firestore
//           .collection('water_entries')
//           .doc('${userId}_$dateKey')
//           .get();

//       if (!doc.exists) return 0;

//       final data = doc.data();
//       return (data?['waterIntake'] ?? 0) as int;
//     } catch (e) {
//       print('Ошибка загрузки воды: $e');
//       return 0;
//     }
//   }

//   // ==================== ПРОДУКТЫ ====================

//   // Сохранить продукт
//   Future<void> saveProduct(Product product) async {
//     try {
//       await _firestore.collection('products').doc(product.id).set(product.toJson());
//       print('Продукт сохранен: ${product.name}');
//     } catch (e) {
//       print('Ошибка сохранения продукта: $e');
//       rethrow;
//     }
//   }

//   // Сохранить несколько продуктов (для синхронизации)
//   Future<void> saveProducts(List<Product> products) async {
//     try {
//       WriteBatch batch = _firestore.batch();
//       for (var product in products) {
//         batch.set(_firestore.collection('products').doc(product.id), product.toJson());
//       }
//       await batch.commit();
//       print('Сохранено ${products.length} продуктов');
//     } catch (e) {
//       print('Ошибка массового сохранения продуктов: $e');
//       rethrow;
//     }
//   }

//   // Получить продукт по ID
//   Future<Product?> getProduct(String id) async {
//     try {
//       final doc = await _firestore.collection('products').doc(id).get();
//       if (doc.exists) {
//         return Product.fromJson(doc.data()!);
//       }
//       return null;
//     } catch (e) {
//       print('Ошибка получения продукта: $e');
//       return null;
//     }
//   }

//   // Получить продукты пользователя (свои рецепты)
//   Future<List<Product>> getUserProducts(String userId) async {
//     try {
//       final query = await _firestore
//           .collection('products')
//           .where('userId', isEqualTo: userId)
//           .orderBy('createdAt', descending: true)
//           .get();
      
//       return query.docs.map((doc) => Product.fromJson(doc.data())).toList();
//     } catch (e) {
//       print('Ошибка получения продуктов пользователя: $e');
//       return [];
//     }
//   }

//   // Поиск продуктов по названию (общие + пользовательские)
//   Future<List<Product>> searchProducts(String query, {String? userId}) async {
//     try {
//       // Ищем по названию (содержит подстроку)
//       // В Firestore нет прямого LIKE, используем начало строки
//       final snapshot = await _firestore
//           .collection('products')
//           .where('name', isGreaterThanOrEqualTo: query)
//           .where('name', isLessThanOrEqualTo: '${query}z')
//           .limit(20)
//           .get();
      
//       return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
//     } catch (e) {
//       print('Ошибка поиска продуктов: $e');
//       return [];
//     }
//   }

//   // Удалить продукт
//   Future<void> deleteProduct(String id) async {
//     try {
//       await _firestore.collection('products').doc(id).delete();
//       print('Продукт удален: $id');
//     } catch (e) {
//       print('Ошибка удаления продукта: $e');
//       rethrow;
//     }
//   }

//   // ==================== ДНЕВНИК ====================

//   // Сохранить запись в дневнике
//   Future<void> saveDiaryEntry(DiaryEntry entry) async {
//     try {
//       await _firestore.collection('diary_entries').doc(entry.id).set(entry.toJson());
//       print('Запись сохранена: ${entry.id}');
//     } catch (e) {
//       print('Ошибка сохранения записи: $e');
//       rethrow;
//     }
//   }

//   // Сохранить несколько записей
//   Future<void> saveDiaryEntries(List<DiaryEntry> entries) async {
//     try {
//       WriteBatch batch = _firestore.batch();
//       for (var entry in entries) {
//         batch.set(_firestore.collection('diary_entries').doc(entry.id), entry.toJson());
//       }
//       await batch.commit();
//       print('Сохранено ${entries.length} записей');
//     } catch (e) {
//       print('Ошибка массового сохранения записей: $e');
//       rethrow;
//     }
//   }

//   // Получить записи пользователя за день
//   Future<List<DiaryEntry>> getDailyEntries(String userId, DateTime date) async {
//     try {
//       final startOfDay = DateTime(date.year, date.month, date.day);
//       final endOfDay = startOfDay.add(const Duration(days: 1));
      
//       final query = await _firestore
//           .collection('diary_entries')
//           .where('userId', isEqualTo: userId)
//           .where('dateTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
//           .where('dateTime', isLessThan: endOfDay.toIso8601String())
//           .orderBy('dateTime')
//           .get();
      
//       return query.docs.map((doc) => DiaryEntry.fromJson(doc.data())).toList();
//     } catch (e) {
//       print('Ошибка получения записей за день: $e');
//       return [];
//     }
//   }

//   // Получить записи за период
//   Future<List<DiaryEntry>> getEntriesForPeriod(
//     String userId,
//     DateTime start,
//     DateTime end,
//   ) async {
//     try {
//       final query = await _firestore
//           .collection('diary_entries')
//           .where('userId', isEqualTo: userId)
//           .where('dateTime', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('dateTime', isLessThanOrEqualTo: end.toIso8601String())
//           .orderBy('dateTime')
//           .get();
      
//       return query.docs.map((doc) => DiaryEntry.fromJson(doc.data())).toList();
//     } catch (e) {
//       print('Ошибка получения записей за период: $e');
//       return [];
//     }
//   }

//   // Получить последние записи пользователя
//   Future<List<DiaryEntry>> getRecentEntries(String userId, {int limit = 10}) async {
//     try {
//       final query = await _firestore
//           .collection('diary_entries')
//           .where('userId', isEqualTo: userId)
//           .orderBy('dateTime', descending: true)
//           .limit(limit)
//           .get();
      
//       return query.docs.map((doc) => DiaryEntry.fromJson(doc.data())).toList();
//     } catch (e) {
//       print('Ошибка получения последних записей: $e');
//       return [];
//     }
//   }

//   // Обновить запись
//   Future<void> updateDiaryEntry(DiaryEntry entry) async {
//     try {
//       await _firestore.collection('diary_entries').doc(entry.id).update(entry.toJson());
//       print('Запись обновлена: ${entry.id}');
//     } catch (e) {
//       print('Ошибка обновления записи: $e');
//       rethrow;
//     }
//   }

//   // Удалить запись
//   Future<void> deleteDiaryEntry(String id) async {
//     try {
//       await _firestore.collection('diary_entries').doc(id).delete();
//       print('Запись удалена: $id');
//     } catch (e) {
//       print('Ошибка удаления записи: $e');
//       rethrow;
//     }
//   }

//   // Удалить записи за день
//   Future<void> deleteDailyEntries(String userId, DateTime date) async {
//     try {
//       final entries = await getDailyEntries(userId, date);
//       WriteBatch batch = _firestore.batch();
//       for (var entry in entries) {
//         batch.delete(_firestore.collection('diary_entries').doc(entry.id));
//       }
//       await batch.commit();
//       print('Удалено ${entries.length} записей за ${date.toIso8601String()}');
//     } catch (e) {
//       print('Ошибка удаления записей за день: $e');
//       rethrow;
//     }
//   }

//   // ==================== СТАТИСТИКА ====================

//   // Получить суммарную статистику за день
//   Future<Map<String, double>> getDailyStats(String userId, DateTime date) async {
//     try {
//       final entries = await getDailyEntries(userId, date);
      
//       double totalCalories = 0;
//       double totalProteins = 0;
//       double totalFats = 0;
//       double totalCarbs = 0;
      
//       for (var entry in entries) {
//         totalCalories += entry.calories;
//         totalProteins += entry.proteins;
//         totalFats += entry.fats;
//         totalCarbs += entry.carbs;
//       }
      
//       return {
//         'calories': totalCalories,
//         'proteins': totalProteins,
//         'fats': totalFats,
//         'carbs': totalCarbs,
//       };
//     } catch (e) {
//       print('Ошибка получения статистики за день: $e');
//       return {
//         'calories': 0,
//         'proteins': 0,
//         'fats': 0,
//         'carbs': 0,
//       };
//     }
//   }

//   // Получить статистику за неделю (по дням)
//   Future<Map<DateTime, Map<String, double>>> getWeeklyStats(String userId, DateTime startOfWeek) async {
//     try {
//       final endOfWeek = startOfWeek.add(const Duration(days: 7));
//       final entries = await getEntriesForPeriod(userId, startOfWeek, endOfWeek);
      
//       final Map<DateTime, Map<String, double>> weeklyStats = {};
      
//       // Группируем по дням
//       for (var entry in entries) {
//         final day = DateTime(entry.dateTime.year, entry.dateTime.month, entry.dateTime.day);
        
//         if (!weeklyStats.containsKey(day)) {
//           weeklyStats[day] = {
//             'calories': 0,
//             'proteins': 0,
//             'fats': 0,
//             'carbs': 0,
//           };
//         }
        
//         weeklyStats[day]!['calories'] = (weeklyStats[day]!['calories']! + entry.calories);
//         weeklyStats[day]!['proteins'] = (weeklyStats[day]!['proteins']! + entry.proteins);
//         weeklyStats[day]!['fats'] = (weeklyStats[day]!['fats']! + entry.fats);
//         weeklyStats[day]!['carbs'] = (weeklyStats[day]!['carbs']! + entry.carbs);
//       }
      
//       return weeklyStats;
//     } catch (e) {
//       print('Ошибка получения статистики за неделю: $e');
//       return {};
//     }
//   }
// }








import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/diary_entry_model.dart';

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
          .collection('daily_diary')
          .doc('${userId}_$dateKey')
          .set({
        'userId': userId,
        'date': dateKey,

        // вода
        'waterIntake': waterIntake,

        // суммарные показатели
        'calories': calories,
        'proteins': proteins,
        'fats': fats,
        'carbs': carbs,

        // приемы пищи
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
          .collection('daily_diary')
          .doc('${userId}_$dateKey')
          .get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      print('Ошибка загрузки дневника: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDiaryHistory(String userId) async {
    try {
      final query = await _firestore
          .collection('daily_diary')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Ошибка получения истории дневника: $e');
      return [];
    }
  }
}