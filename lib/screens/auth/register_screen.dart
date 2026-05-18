import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/spiral_loader.dart';
import '../onboarding/gender_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Регистрация',
          style: AppFonts.robotoMono(color: Color(0xFF5C5248)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset(
                'assets/images/dr_apple_reg.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                focusNode: _emailFocus,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: AppFonts.robotoMono(color: Color(0xFF5C5248)),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: AppFonts.robotoMono(color: Color(0xFF5C5248)),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF5C5248)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                style: AppFonts.robotoMono(color: Color(0xFF5C5248)),
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  labelStyle: AppFonts.robotoMono(color: Color(0xFF5C5248)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF5C5248)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF5C5248),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                style: AppFonts.robotoMono(color: Color(0xFF5C5248)),
                decoration: InputDecoration(
                  labelText: 'Подтвердите пароль',
                  labelStyle: AppFonts.robotoMono(color: Color(0xFF5C5248)),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Color(0xFF5C5248)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color(0xFF5C5248),
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              if (authProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    authProvider.errorMessage!,
                    style: AppFonts.robotoMono(color: Colors.red.shade900),
                  ),
                ),
              const SizedBox(height: 16),
              authProvider.isLoading
                  ? const Center(child: SpiralLoader(size: 48))
                  : ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (!isValidEmail(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Введите корректный email'),
                            ),
                          );
                          return;
                        }
                        if (passwordController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Пароль должен быть минимум 6 символов'),
                            ),
                          );
                          return;
                        }
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пароли не совпадают')),
                          );
                          return;
                        }
                        final success = await authProvider.register(
                          email,
                          passwordController.text.trim(),
                        );
                        if (success && mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GenderScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Color(0xFF5C5248),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Зарегистрироваться',
                        style: AppFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  authProvider.clearError();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text(
                  'Уже есть аккаунт? Войти',
                  style: AppFonts.robotoMono(fontSize: 16, color: Color(0xFF5C5248)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
