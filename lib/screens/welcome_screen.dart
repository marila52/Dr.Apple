import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_choice_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // длительность исчезновения
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Запускаем исчезновение через 5 секунд
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _controller.forward();
      }
    });

    // Переход на следующий экран через 7 секунд (5 + 2)
    Future.delayed(Duration(seconds: 7), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthChoiceScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // фон всегда белый
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Логотип PNG (больше)
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/dr_apple_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                // Название
                Text(
                  'Dr. Apple',
                  style: GoogleFonts.indieFlower(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2B1F), // новый цвет
                  ),
                ),
                SizedBox(height: 16),
                // Подзаголовок (теперь тоже этим цветом)
                Text(
                  'Твой идеальный дневник питания',
                  style: GoogleFonts.badScript(
                    fontSize: 20,
                    color: Color(0xFF3D2B1F),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}