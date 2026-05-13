import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/user_data_provider.dart';
import '../home/home_screen.dart';

class CalorieResultScreen extends StatelessWidget {
  const CalorieResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final user = userProvider.currentUser;

    final calories = user?.dailyCalories?.round() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Color(0xFF2F2924),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Назад',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: const Color(0xFF2F2924),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 55),

              Text(
                'Ваша норма\nкалорий:',
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4D3F3A),
                ),
              ),

              const Spacer(),

              Text(
                '$calories ккал',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5C5248),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'в день для достижения\nвашей цели',
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  height: 1.35,
                  color: const Color(0xFF4D3F3A),
                ),
              ),

              const Spacer(),

              Text(
                'Это твой ориентир\nСлушай организм\nи двигайся в своем темпе',
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  height: 1.45,
                  color: const Color(0xFFC1AEA7),
                ),
              ),

              const SizedBox(height: 42),

              SizedBox(
                width: 120,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  // style: ElevatedButton.styleFrom(
                  //   elevation: 0,
                  //   backgroundColor: const Color(0xFF8DB6B3),
                  //   foregroundColor: Colors.white,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(9),
                  //   ),
                  //   padding: EdgeInsets.zero,
                  // ),
                  // child: Text(
                  //   'ГОТОВО',
                  //   style: GoogleFonts.robotoMono(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w700,
                  //     letterSpacing: 1.2,
                  //   ),
                  // ),


                  style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C5248),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'ГОТОВО',
                              style: GoogleFonts.roboto(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                
              
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}