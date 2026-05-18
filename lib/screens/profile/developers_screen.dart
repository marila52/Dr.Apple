import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_colors.dart';
import 'package:dr_apple/theme/app_fonts.dart';

class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Назад",
          style: AppFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                'Разработчики:',
                style: AppFonts.prata(
                  fontSize: 32,
                  color: AppColors.darkRed,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 52),
              _developerTile(
                surname: 'Кудряшова',
                name: 'Мария',
                imagePath: 'assets/images/kl.png',
                borderColor: AppColors.darkRed,
              ),
              const SizedBox(height: 40),
              _developerTile(
                surname: 'Анчикова',
                name: 'Милана',
                imagePath: 'assets/images/go.png',
                borderColor: AppColors.darkBlue,
              ),
              const SizedBox(height: 40),
              _developerTile(
                surname: 'Жесткова',
                name: 'Екатерина',
                imagePath: 'assets/images/ej.png',
                borderColor: AppColors.darkPurple,
              ),
              const SizedBox(height: 50),
              Text(
                '6205-010302D',
                style: AppFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkRed,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _developerTile({
    required String surname,
    required String name,
    required String imagePath,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    surname,
                    style: AppFonts.prata(
                      fontSize: 22,
                      color: borderColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: AppFonts.prata(
                      fontSize: 22,
                      color: borderColor,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}