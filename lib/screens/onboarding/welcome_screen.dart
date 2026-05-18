import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import '../auth/auth_choice_screen.dart';

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
      duration: Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _controller.forward();
      }
    });

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
      backgroundColor: Color.fromARGB(255, 255, 255, 255), // ← новый фон
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/dr_apple_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Dr. Apple',
                  style: AppFonts.indieFlower(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C5248), // ← новый цвет текста
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Твой идеальный дневник питания',
                  style: AppFonts.badScript(
                    fontSize: 20,
                    color: Color(0xFF5C5248), // ← новый цвет текста
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