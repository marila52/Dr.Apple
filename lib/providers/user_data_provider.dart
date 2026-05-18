import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/weight_history_service.dart';
import '../utils/kcal_calculator.dart';

class UserDataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final WeightHistoryService _weightHistoryService = WeightHistoryService();

  bool _isLoading = false;
  String? _error;
  AppUser? _currentUser;

  Gender? _gender;
  double? _weight;
  double? _height;
  int? _age;
  ActivityLevel? _activityLevel;
  Goal? _goal;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AppUser? get currentUser => _currentUser;

  Gender? get gender => _gender;
  double? get weight => _weight;
  double? get height => _height;
  int? get age => _age;
  ActivityLevel? get activityLevel => _activityLevel;
  Goal? get goal => _goal;

  void setGender(Gender value) {
    _gender = value;
    notifyListeners();
  }

  void setWeight(double value) {
    _weight = value;
    notifyListeners();
  }

  void setHeight(double value) {
    _height = value;
    notifyListeners();
  }

  void setAge(int value) {
    _age = value;
    notifyListeners();
  }

  void setActivityLevel(ActivityLevel value) {
    _activityLevel = value;
    notifyListeners();
  }

  void setGoal(Goal value) {
    _goal = value;
    notifyListeners();
  }

  Future<bool> savePersonalData({
    Gender? gender,
    double? weight,
    double? height,
    int? age,
    ActivityLevel? activityLevel,
    Goal? goal,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      if (gender != null) _gender = gender;
      if (weight != null) _weight = weight;
      if (height != null) _height = height;
      if (age != null) _age = age;
      if (activityLevel != null) _activityLevel = activityLevel;
      if (goal != null) _goal = goal;

      _validateProfileData();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      final dailyCalories = KcalCalculator.calculateDailyCalories(
        gender: _gender!,
        weight: _weight!,
        height: _height!,
        age: _age!,
        activityLevel: _activityLevel!,
        goal: _goal!,
      );
      final dailyProteins = KcalCalculator.calculateDailyProteins(
        weight: _weight!,
        goal: _goal!,
      );
      final dailyFats = KcalCalculator.calculateDailyFats(
        dailyCalories: dailyCalories,
      );
      final dailyCarbs = KcalCalculator.calculateDailyCarbs(
        dailyCalories: dailyCalories,
        dailyProteins: dailyProteins,
        dailyFats: dailyFats,
      );

      final existingUser = await _firestoreService
          .getUser(firebaseUser.uid)
          .timeout(const Duration(seconds: 5));

      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
        gender: _gender,
        weight: _weight,
        height: _height,
        age: _age,
        activityLevel: _activityLevel,
        goal: _goal,
        dailyCalories: dailyCalories.roundToDouble(),
        dailyProteins: dailyProteins.roundToDouble(),
        dailyFats: dailyFats.roundToDouble(),
        dailyCarbs: dailyCarbs.roundToDouble(),
        createdAt: existingUser?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.saveUser(appUser);
      await _weightHistoryService.recordWeight(
        userId: firebaseUser.uid,
        weight: _weight!,
      );
      _currentUser = appUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    double? weight,
    int? age,
    Gender? gender,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      if (weight != null) _weight = weight;
      if (age != null) _age = age;
      if (gender != null) _gender = gender;

      if (_currentUser == null ||
          _gender == null ||
          _weight == null ||
          _height == null ||
          _age == null ||
          _activityLevel == null ||
          _goal == null) {
        await loadCurrentUser();
      }

      _validateProfileData();

      final dailyCalories = KcalCalculator.calculateDailyCalories(
        gender: _gender!,
        weight: _weight!,
        height: _height!,
        age: _age!,
        activityLevel: _activityLevel!,
        goal: _goal!,
      );
      final dailyProteins = KcalCalculator.calculateDailyProteins(
        weight: _weight!,
        goal: _goal!,
      );
      final dailyFats = KcalCalculator.calculateDailyFats(
        dailyCalories: dailyCalories,
      );
      final dailyCarbs = KcalCalculator.calculateDailyCarbs(
        dailyCalories: dailyCalories,
        dailyProteins: dailyProteins,
        dailyFats: dailyFats,
      );

      final updated = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        gender: _gender,
        weight: _weight,
        height: _height,
        age: _age,
        activityLevel: _activityLevel,
        goal: _goal,
        dailyCalories: dailyCalories.roundToDouble(),
        dailyProteins: dailyProteins.roundToDouble(),
        dailyFats: dailyFats.roundToDouble(),
        dailyCarbs: dailyCarbs.roundToDouble(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.saveUser(updated);

      final oldWeight = _currentUser!.weight;
      if (weight != null && oldWeight != weight) {
        await _weightHistoryService.recordWeight(
          userId: firebaseUser.uid,
          weight: weight,
        );
      }

      _currentUser = updated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _error = null;

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Добавляем таймаут 5 секунд на запрос к Firestore
      _currentUser = await _firestoreService
          .getUser(firebaseUser.uid)
          .timeout(const Duration(seconds: 5));

      _gender = _currentUser?.gender;
      _weight = _currentUser?.weight;
      _height = _currentUser?.height;
      _age = _currentUser?.age;
      _activityLevel = _currentUser?.activityLevel;
      _goal = _currentUser?.goal;
    } on TimeoutException {
      _error = 'Загрузка данных заняла слишком много времени. Проверьте интернет.';
      print('Timeout при загрузке пользователя');
    } catch (e) {
      _error = e.toString();
      print('Ошибка загрузки пользователя: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearOnboardingData() {
    _gender = null;
    _weight = null;
    _height = null;
    _age = null;
    _activityLevel = null;
    _goal = null;
    _error = null;
    notifyListeners();
  }

  void _validateProfileData() {
    if (_gender == null) throw Exception('Не выбран пол');
    if (_weight == null) throw Exception('Не указан вес');
    if (_height == null) throw Exception('Не указан рост');
    if (_age == null) throw Exception('Не указан возраст');
    if (_activityLevel == null) throw Exception('Не выбран уровень активности');
    if (_goal == null) throw Exception('Не выбрана цель');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}