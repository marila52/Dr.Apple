import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/diary_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';
import 'theme/app_colors.dart';
import 'widgets/spiral_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase init error: $e');
    if (Firebase.apps.isEmpty) rethrow;
  }

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
          scaffoldBackgroundColor: Colors.white,
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
            backgroundColor: AppColors.white,
            body: Center(child: SpiralLoader(size: 72)),
          );
        }

        if (snapshot.hasData) {
          return const _AuthenticatedGate();
        }

        return const WelcomeScreen();
      },
    );
  }
}

class _AuthenticatedGate extends StatefulWidget {
  const _AuthenticatedGate();

  @override
  State<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<_AuthenticatedGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    try {
      await context.read<UserDataProvider>().loadCurrentUser();
    } catch (e) {
      print('Profile loading error: $e');
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: SpiralLoader(size: 72)),
      );
    }

    final user = context.watch<UserDataProvider>().currentUser;

    if (user == null || user.dailyCalories == null) {
      return const WelcomeScreen();
    }

    return const DiaryScreen();
  }
}