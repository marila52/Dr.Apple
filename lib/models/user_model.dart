import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final String? name;
  final double? dailyCalories;
  final double? dailyProteins;
  final double? dailyFats;
  final double? dailyCarbs;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.dailyCalories,
    this.dailyProteins,
    this.dailyFats,
    this.dailyCarbs,
    required this.createdAt,
    this.updatedAt,
  });

  // ✅ ИСПРАВЛЕНО: Создание пользователя из Firebase User
  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email!,
      name: user.displayName,
      createdAt: DateTime.now(),
    );
  }

  // Создание из JSON (для Firestore)
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      dailyCalories: (json['dailyCalories'] as num?)?.toDouble(),
      dailyProteins: (json['dailyProteins'] as num?)?.toDouble(),
      dailyFats: (json['dailyFats'] as num?)?.toDouble(),
      dailyCarbs: (json['dailyCarbs'] as num?)?.toDouble(),
      createdAt: (json['createdAt'] as DateTime?) ?? DateTime.now(),
      updatedAt: json['updatedAt'] as DateTime?,
    );
  }

  // Преобразование в JSON (для Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'dailyCalories': dailyCalories,
      'dailyProteins': dailyProteins,
      'dailyFats': dailyFats,
      'dailyCarbs': dailyCarbs,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  // Копирование с изменениями
  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    double? dailyCalories,
    double? dailyProteins,
    double? dailyFats,
    double? dailyCarbs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProteins: dailyProteins ?? this.dailyProteins,
      dailyFats: dailyFats ?? this.dailyFats,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}