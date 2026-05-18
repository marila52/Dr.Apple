import 'package:flutter/material.dart';
import '../services/database/user_dao.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class CustomAuthProvider extends ChangeNotifier {
  final UserDao _userDao = UserDao();
  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Проверяем, существует ли пользователь с таким email
      final existing = await _userDao.getUserByEmail(email);
      if (existing != null) {
        _errorMessage = 'Пользователь с таким email уже существует';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Создаем нового пользователя
      final newUser = AppUser(
        uid: Uuid().v4(),
        email: email.toLowerCase(),
        name: null,
        gender: null,
        weight: null,
        height: null,
        age: null,
        activityLevel: null,
        goal: null,
        dailyCalories: null,
        dailyProteins: null,
        dailyFats: null,
        dailyCarbs: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      final success = await _userDao.registerUser(newUser, password);
      if (success) {
        _user = newUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Ошибка при регистрации';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userDao.loginUser(email.toLowerCase(), password);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Неверный email или пароль';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void signOut() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}