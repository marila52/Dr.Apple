// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import 'diary_screen.dart';  // 👈 ДОБАВИТЬ ИМПОРТ

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    // Автоматический переход на DiaryScreen через 2 секунды
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DiaryScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        title: Text(
          'Dr. Apple',
          style: GoogleFonts.robotoMono(
            color: const Color(0xFF5C5248),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF5C5248)),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: const Color(0xFF5C5248),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Добро пожаловать!',
              style: GoogleFonts.robotoMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5C5248),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? 'Пользователь',
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                color: const Color(0xFF5C5248).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5C5248)),
            ),
            const SizedBox(height: 20),
            Text(
              'Переход в дневник...',
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                color: Color(0xFF5C5248),
              ),
            ),
          ],
        ),
      ),
    );
  }
}