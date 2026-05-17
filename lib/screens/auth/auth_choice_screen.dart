import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 ВАЖНО: меняем на min
            children: [
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/Frame 2.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C5248),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Создать аккаунт',
                    style: AppFonts.robotoMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C5248),
                    side: const BorderSide(color: Color(0xFF5C5248), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Войти',
                    style: AppFonts.robotoMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Никаких навороченных тренеров, социальных сетей и рекламы. '
                'Только ты, твоя тарелка и честная математика здоровья!',
                textAlign: TextAlign.center,
                style: AppFonts.robotoMono(
                  fontSize: 15,
                  height: 1.4,
                  color: Color(0xFF5C5248),
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/dr_apple_2_screen.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}