import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class CustomAuthProvider extends ChangeNotifier {  // ← Переименовала
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  CustomAuthProvider() {  // ← Переименовала конструктор
    _authService.user.listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await _authService.registerWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}