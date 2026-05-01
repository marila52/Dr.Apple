// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../providers/auth_provider.dart';
// import '../onboarding/welcome_screen.dart';
// import 'register_screen.dart';
// import '../home/home_screen.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<CustomAuthProvider>(context);

//     return Scaffold(
//       backgroundColor: Color(0xFFFDF8FF), // ← новый фон
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => WelcomeScreen()),
//             );
//           },
//         ),
//         title: Text(
//           'Вход',
//           style: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               Image.asset(
//                 'assets/images/dr_apple_create_acc.png',
//                 width: 240,
//                 height: 240,
//                 fit: BoxFit.contain,
//               ),
//               SizedBox(height: 30),
              
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   labelStyle: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
//                   prefixIcon: Icon(Icons.email, color: Color(0xFF5C5248)),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 style: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
//               ),
//               SizedBox(height: 16),
              
//               TextField(
//                 controller: passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Пароль',
//                   labelStyle: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
//                   prefixIcon: Icon(Icons.lock, color: Color(0xFF5C5248)),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       color: Color(0xFF5C5248),
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 obscureText: _obscurePassword,
//                 style: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
//               ),
//               SizedBox(height: 24),
              
//               if (authProvider.errorMessage != null)
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Text(
//                     authProvider.errorMessage!,
//                     style: GoogleFonts.robotoMono(color: Colors.red.shade900),
//                   ),
//                 ),
//               SizedBox(height: 16),
              
//               authProvider.isLoading
//                   ? CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5C5248)),
//                     )
//                   : ElevatedButton(
//                       onPressed: () async {
//                         bool success = await authProvider.signIn(
//                           emailController.text.trim(),
//                           passwordController.text.trim(),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: Size(double.infinity, 55),
//                         backgroundColor: Color(0xFF5C5248),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       child: Text(
//                         'Войти',
//                         style: GoogleFonts.robotoMono(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//               SizedBox(height: 16),
              
//               TextButton(
//                 onPressed: () {
//                   authProvider.clearError();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RegisterScreen()),
//                   );
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: Color(0xFF5C5248),
//                 ),
//                 child: Text(
//                   'Нет аккаунта? Зарегистрироваться',
//                   style: GoogleFonts.robotoMono(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/welcome_screen.dart';
import '../home/home_screen.dart';  // 👈 ДОБАВЛЕН импорт
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFFDF8FF),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
        ),
        title: Text(
          'Вход',
          style: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/dr_apple_create_acc.png',
                width: 240,
                height: 240,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),
              
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
                  prefixIcon: Icon(Icons.email, color: Color(0xFF5C5248)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
              ),
              SizedBox(height: 16),
              
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  labelStyle: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF5C5248)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF5C5248),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: _obscurePassword,
                style: GoogleFonts.robotoMono(color: Color(0xFF5C5248)),
              ),
              SizedBox(height: 24),
              
              if (authProvider.errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    authProvider.errorMessage!,
                    style: GoogleFonts.robotoMono(color: Colors.red.shade900),
                  ),
                ),
              SizedBox(height: 16),
              
              authProvider.isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5C5248)),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        bool success = await authProvider.signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        
                        // 👇 ПЕРЕХОД НА HomeScreen ПРИ УСПЕШНОМ ВХОДЕ
                        if (success && mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 55),
                        backgroundColor: Color(0xFF5C5248),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Войти',
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  authProvider.clearError();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF5C5248),
                ),
                child: Text(
                  'Нет аккаунта? Зарегистрироваться',
                  style: GoogleFonts.robotoMono(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}