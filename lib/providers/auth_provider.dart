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
      // Прямой вызов FirebaseAuth вместо AuthService
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      
      print('✅ [register] Регистрация успешна! uid: ${result.user?.uid}');
      _user = result.user;
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ [register] FirebaseAuthException: ${e.code}');
      setLoading(false);
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Слишком простой пароль';
          break;
        case 'email-already-in-use':
          message = 'Этот email уже зарегистрирован';
          break;
        case 'invalid-email':
          message = 'Некорректный email';
          break;
        default:
          message = 'Ошибка регистрации: ${e.code}';
      }
      setError(message);
      return false;
    } catch (e) {
      print('❌ [register] Ошибка: $e');
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    print('🔐 [signIn] Начало входа для: $email');
    setLoading(true);
    setError(null);

    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      
      print('✅ [signIn] Вход успешен! uid: ${result.user?.uid}');
      _user = result.user;
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ [signIn] FirebaseAuthException: ${e.code}');
      setLoading(false);
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Пользователь не найден';
          break;
        case 'wrong-password':
          message = 'Неверный пароль';
          break;
        case 'invalid-email':
          message = 'Некорректный email';
          break;
        default:
          message = 'Ошибка входа: ${e.code}';
      }
      setError(message);
      return false;
    } catch (e) {
      print('❌ [signIn] Ошибка: $e');
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    print('🚪 signOut вызван');
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    print('🧹 clearError');
    _errorMessage = null;
    notifyListeners();
  }
}