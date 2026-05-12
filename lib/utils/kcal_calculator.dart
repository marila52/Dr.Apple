// enum Gender { male, female }

// enum ActivityLevel { sedentary, light, moderate, active, veryActive }

// enum Goal { weightLoss, maintenance, weightGain }


enum Gender { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum Goal { weightLoss, maintenance, weightGain }

class KcalCalculator {
  static double calculateDailyCalories({
    required Gender gender,
    required double weight,
    required double height,
    required int age,
    required ActivityLevel activityLevel,
    required Goal goal,
  }) {
    // Формула Mifflin-St Jeor
    final bmr = gender == Gender.male
        ? (10 * weight) + (6.25 * height) - (5 * age) + 5
        : (10 * weight) + (6.25 * height) - (5 * age) - 161;

    final maintenanceCalories = bmr * _activityFactor(activityLevel);

    switch (goal) {
      case Goal.weightLoss:
        return maintenanceCalories * 0.85;
      case Goal.maintenance:
        return maintenanceCalories;
      case Goal.weightGain:
        return maintenanceCalories * 1.15;
    }
  }

  static double calculateDailyProteins({
    required double weight,
    required Goal goal,
  }) {
    double factor;
    switch (goal) {
      case Goal.weightLoss:
        factor = 2.0;
        break;
      case Goal.maintenance:
        factor = 1.6;
        break;
      case Goal.weightGain:
        factor = 1.8;
        break;
    }
    return weight * factor;
  }

  static double calculateDailyFats({
    required double dailyCalories,
  }) {
    // 25% калорий из жиров, 1 г жира = 9 ккал
    return (dailyCalories * 0.25) / 9;
  }

  static double calculateDailyCarbs({
    required double dailyCalories,
    required double dailyProteins,
    required double dailyFats,
  }) {
    // Остаток калорий после белков и жиров, 1 г углеводов = 4 ккал
    final caloriesFromProteins = dailyProteins * 4;
    final caloriesFromFats = dailyFats * 9;
    return (dailyCalories - caloriesFromProteins - caloriesFromFats) / 4;
  }

  static double _activityFactor(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }
}
