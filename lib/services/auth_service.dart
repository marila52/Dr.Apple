import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Поток для отслеживания состояния пользователя
  Stream<User?> get user => _auth.authStateChanges();

  // Регистрация по email/паролю
  Future<User?> registerWithEmail(String email, String password) async {
    print('🟡 [AuthService] registerWithEmail: $email');
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      print('🟢 [AuthService] Успешно создан: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('🔴 [AuthService] FirebaseAuthException: ${e.code}');
      String message;
      if (e.code == 'weak-password') {
        message = 'Слишком простой пароль';
      } else if (e.code == 'email-already-in-use') {
        message = 'Этот email уже зарегистрирован';
      } else if (e.code == 'invalid-email') {
        message = 'Некорректный email';
      } else {
        message = 'Ошибка регистрации: ${e.code}';
      }
      throw Exception(message);
    } catch (e) {
      print('🔴 [AuthService] Ошибка: $e');
      throw Exception('Произошла ошибка: $e');
    }
  }

  // Вход по email/паролю
  Future<User?> signInWithEmail(String email, String password) async {
    print('🟡 [AuthService] signInWithEmail: $email');
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      print('🟢 [AuthService] Успешный вход: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('🔴 [AuthService] FirebaseAuthException: ${e.code}');
      String message;
      if (e.code == 'user-not-found') {
        message = 'Пользователь не найден';
      } else if (e.code == 'wrong-password') {
        message = 'Неверный пароль';
      } else if (e.code == 'invalid-email') {
        message = 'Некорректный email';
      } else {
        message = 'Ошибка входа: ${e.code}';
      }
      throw Exception(message);
    } catch (e) {
      print('🔴 [AuthService] Ошибка: $e');
      throw Exception('Произошла ошибка: $e');
    }
  }

  // Выход
  Future<void> signOut() async {
    print('🚪 [AuthService] signOut');
    await _auth.signOut();
  }
}