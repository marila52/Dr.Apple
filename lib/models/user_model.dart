import '../utils/kcal_calculator.dart';

class AppUser {
  final String uid;
  final String email;
  final String? name;

  final Gender? gender;
  final double? weight;
  final double? height;
  final int? age;
  final ActivityLevel? activityLevel;
  final Goal? goal;

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
    this.gender,
    this.weight,
    this.height,
    this.age,
    this.activityLevel,
    this.goal,
    this.dailyCalories,
    this.dailyProteins,
    this.dailyFats,
    this.dailyCarbs,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      gender: _enumFromString(Gender.values, json['gender'] as String?),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      age: (json['age'] as num?)?.toInt(),
      activityLevel: _enumFromString(
        ActivityLevel.values,
        json['activityLevel'] as String?,
      ),
      goal: _enumFromString(Goal.values, json['goal'] as String?),
      dailyCalories: (json['dailyCalories'] as num?)?.toDouble(),
      dailyProteins: (json['dailyProteins'] as num?)?.toDouble(),
      dailyFats: (json['dailyFats'] as num?)?.toDouble(),
      dailyCarbs: (json['dailyCarbs'] as num?)?.toDouble(),
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'gender': gender?.name,
      'weight': weight,
      'height': height,
      'age': age,
      'activityLevel': activityLevel?.name,
      'goal': goal?.name,
      'dailyCalories': dailyCalories,
      'dailyProteins': dailyProteins,
      'dailyFats': dailyFats,
      'dailyCarbs': dailyCarbs,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    Gender? gender,
    double? weight,
    double? height,
    int? age,
    ActivityLevel? activityLevel,
    Goal? goal,
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
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProteins: dailyProteins ?? this.dailyProteins,
      dailyFats: dailyFats ?? this.dailyFats,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static T? _enumFromString<T extends Enum>(List<T> values, String? value) {
    if (value == null) return null;
    for (final item in values) {
      if (item.name == value) return item;
    }
    return null;
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}