import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dr. Apple',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              'Создайте аккаунт',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),

            // Email поле
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            // Пароль поле
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            SizedBox(height: 16),

            // Подтверждение пароля
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
            ),
            SizedBox(height: 24),

            // Сообщение об ошибке
            if (authProvider.errorMessage != null)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),

            // Кнопка регистрации
            authProvider.isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Валидация
                          if (passwordController.text != confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Пароли не совпадают'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          
                          if (passwordController.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Пароль должен быть минимум 6 символов'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Попытка регистрации
                          bool success = await authProvider.register(
                            emailController.text,
                            passwordController.text,
                          );
                          
                          if (success) {
                            // Если успешно - ничего не делаем, провайдер сам переключит на HomeScreen
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          'Зарегистрироваться',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          authProvider.clearError();
                          Navigator.pop(context); // Вернуться на вход
                        },
                        child: Text('Уже есть аккаунт? Войти'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}