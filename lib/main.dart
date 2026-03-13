import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/auth_provider.dart';  // Твой CustomAuthProvider здесь

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
        theme: ThemeData.dark(),
        home: AuthChecker(),  // ← AuthChecker внутри MultiProvider, всё ок!
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Теперь можно получить провайдер, если нужно
    // final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}