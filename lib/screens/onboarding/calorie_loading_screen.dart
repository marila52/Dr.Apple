import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/spiral_loader.dart';
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
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SpiralLoader(size: 80),
              const SizedBox(height: 32),
              Text(
                'Рассчитываем\nвашу норму калорий',
                textAlign: TextAlign.center,
                style: AppFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Подбираем персональную норму...',
                textAlign: TextAlign.center,
                style: AppFonts.roboto(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
