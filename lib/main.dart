
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CustomAuthProvider>(
          create: (_) => CustomAuthProvider(),
        ),
        ChangeNotifierProvider<UserDataProvider>(
          create: (_) => UserDataProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Dr. Apple',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFDF8FF),
        ),
        home: const AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF5C5248),
                ),
              ),
            ),
          );
        }

        // if (snapshot.hasData) {
        //   return const HomeScreen();
        // }

        if (snapshot.hasData) {
          return Consumer<UserDataProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.currentUser;

              if (user == null || user.dailyCalories == null) {
                return WelcomeScreen();
              }

              return const HomeScreen();
        },
      );
    }

        return WelcomeScreen();
      },
    );
  }
}