import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../welcome_screen.dart';
import 'login_screen.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF3D2B1F)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
        ),
        title: Text(
          'Регистрация',
          style: GoogleFonts.robotoMono(color: Color(0xFF3D2B1F)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Картинка
              Image.asset(
                'assets/images/dr_apple_reg.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              // Email поле
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Color(0xFF3D2B1F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Color(0xFF3D2B1F)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              // Пароль
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF3D2B1F)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF3D2B1F),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Color(0xFF3D2B1F)),
                ),
                obscureText: _obscurePassword,
              ),
              SizedBox(height: 16),
              // Подтверждение пароля
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Подтвердите пароль',
                  prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF3D2B1F)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF3D2B1F),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Color(0xFF3D2B1F)),
                ),
                obscureText: _obscureConfirmPassword,
              ),
              SizedBox(height: 24),
              // Ошибка
              if (authProvider.errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              SizedBox(height: 16),
              // Кнопка регистрации (тёмная)
              authProvider.isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D2B1F)),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (passwordController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Пароль должен быть минимум 6 символов'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (passwordController.text != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Пароли не совпадают'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        bool success = await authProvider.register(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        if (!success) {}
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 55),
                        backgroundColor: Color(0xFF3D2B1F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Зарегистрироваться',
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  authProvider.clearError();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF3D2B1F),
                ),
                child: Text(
                  'Уже есть аккаунт? Войти',
                  style: GoogleFonts.robotoMono(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}