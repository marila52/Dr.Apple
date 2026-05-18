import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/diary_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';
import 'theme/app_colors.dart';
import 'widgets/spiral_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase init error: $e');
    if (Firebase.apps.isEmpty) rethrow;
  }

  runApp(const MyApp()); // Здесь const можно оставить, т.к. MyApp — константный конструктор
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
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        home: const AuthChecker(), // Здесь const можно оставить
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
          return Scaffold(
            backgroundColor: AppColors.white,
            body: const Center(child: SpiralLoader(size: 72)), // SpiralLoader, возможно, не const, убираем const перед Center? Оставим const для Center, если его конструктор константный. Если ошибка — уберите const.
          );
        }
        if (snapshot.hasData) {
          return const _AuthenticatedGate(); // _AuthenticatedGate — константный конструктор (если все поля final)
        }
        return WelcomeScreen(); // Убрали const
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
      // Таймаут уже внутри UserDataProvider.loadCurrentUser
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
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(child: SpiralLoader(size: 72)),
      );
    }

    final user = context.watch<UserDataProvider>().currentUser;

    // Если пользователь не найден или нет dailyCalories — показываем экран онбординга
    if (user == null || user.dailyCalories == null) {
      return WelcomeScreen(); // Убрали const
    }

    return const DiaryScreen(); // Если DiaryScreen имеет const конструктор — оставляем, иначе убираем const
  }
}