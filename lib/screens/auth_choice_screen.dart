import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Картинка внизу (широкая, прижата к низу)
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/dr_apple_2_screen.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),

          // Основной контент
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Frame 2.png (прямоугольная картинка)
                  Container(
                    width: double.infinity,
                    height: 200, // можешь изменить на 150, 180, 220 и т.д.
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage('assets/images/Frame 2.png'),
                        fit: BoxFit.cover, // заполнит контейнер
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30), // отступ перед кнопками
                  
                  // Кнопка "Создать аккаунт"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      backgroundColor: Color(0xFF3D2B1F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Создать аккаунт',
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Кнопка "Войти"
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      foregroundColor: Color(0xFF3D2B1F),
                      side: BorderSide(color: Color(0xFF3D2B1F), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Войти',
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Текст под кнопками
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Никаких навороченных тренеров, социальных сетей и рекламы. Только ты, твоя тарелка и честная математика здоровья.',
                      style: GoogleFonts.robotoMono(
                        fontSize: 15,
                        height: 1.4,
                        color: Color(0xFF3D2B1F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}