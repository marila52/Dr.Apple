import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/auth_provider.dart';
//import 'screens/home/diary_screen.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomAuthProvider()),
      ],
      child: MaterialApp(
        title: 'Dr. Apple',
        theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 255, 0), //
      ),
        debugShowCheckedModeBanner: false,
        // theme НЕ указываем — используем системную тему
        // или можно явно: theme: ThemeData.light(),
        home: AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5C5248)),
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return WelcomeScreen();
      },
    );
  }
}