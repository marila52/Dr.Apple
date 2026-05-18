import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/diary_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/spiral_loader.dart';

void main() {
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
        home: AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);
    final isLoading = authProvider.isLoading;
    final user = authProvider.user;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: SpiralLoader(size: 72)),
      );
    }

    if (user != null) {
      return _AuthenticatedGate();
    }

    return WelcomeScreen();
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
    await context.read<UserDataProvider>().loadCurrentUser(context);
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
      return WelcomeScreen();
    }

    return DiaryScreen();
  }
}