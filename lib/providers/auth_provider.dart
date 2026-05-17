import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class CustomAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  CustomAuthProvider() {
    _authService.user.listen((User? user) {
      print('👤 AuthService user changed: ${user?.email ?? "null"}');
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    print('🔄 setLoading($value)');
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    print('❌ setError: $error');
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> register(String email, String password) async {
    print('📝 [register] Начало регистрации для: $email');
    setLoading(true);
    setError(null);

    try {
      print('📝 [register] Вызываю _authService.registerWithEmail...');
      User? user = await _authService.registerWithEmail(email, password);
      print('📝 [register] Результат: user = ${user?.uid ?? "null"}');
      setLoading(false);
      if (user != null) {
        print('✅ [register] Регистрация успешна!');
      } else {
        print('⚠️ [register] user вернулся null');
      }
      return user != null;
    } catch (e) {
      print('❌ [register] Ошибка: $e');
      setLoading(false);
      setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    print('🔐 [signIn] Начало входа для: $email');
    setLoading(true);
    setError(null);

    try {
      print('🔐 [signIn] Вызываю _authService.signInWithEmail...');
      User? user = await _authService.signInWithEmail(email, password);
      print('🔐 [signIn] Результат: user = ${user?.uid ?? "null"}');
      setLoading(false);
      return user != null;
    } catch (e) {
      print('❌ [signIn] Ошибка: $e');
      setLoading(false);
      setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> signOut() async {
    print('🚪 signOut вызван');
    await _authService.signOut();
  }

  void clearError() {
    print('🧹 clearError');
    _errorMessage = null;
    notifyListeners();
  }
}