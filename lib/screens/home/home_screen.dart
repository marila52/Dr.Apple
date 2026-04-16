import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Color(0xFFFDF8), // ← новый фон
      appBar: AppBar(
        title: Text(
          'Dr. Apple',
          style: GoogleFonts.robotoMono(
            color: Color(0xFF5C5248),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF5C5248)),
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
              color: Color(0xFF5C5248),
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Добро пожаловать!',
              style: GoogleFonts.robotoMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C5248),
              ),
            ),
            SizedBox(height: 10),
            Text(
              user?.email ?? 'Пользователь',
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                color: Color(0xFF5C5248).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}