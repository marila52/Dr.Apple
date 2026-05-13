import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calorie_result_screen.dart';

class CalorieLoadingScreen extends StatefulWidget {
  const CalorieLoadingScreen({super.key});

  @override
  State<CalorieLoadingScreen> createState() => _CalorieLoadingScreenState();
}

class _CalorieLoadingScreenState extends State<CalorieLoadingScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CalorieResultScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calculate_outlined,
                color: const Color(0xFF5C5248),
                size: 80,
              ),

              const SizedBox(height: 20),

              Text(
                'Рассчитываем\nвашу норму калорий',
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: const Color(0xFF5C5248),
                ),
              ),

              const SizedBox(height: 30),

              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF5C5248),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Подбираем персональную норму...',
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: Color(0xFF5C5248),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}