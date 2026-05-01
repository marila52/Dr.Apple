// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class GenderScreen extends StatelessWidget {
//   const GenderScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Размеры экрана (для адаптивности, но мы используем точные значения)
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Отступ сверху и снизу (для красоты)
//     final topPadding = screenHeight * 0.05;
//     final bottomPadding = screenHeight * 0.03;

//     return Scaffold(
//       backgroundColor: Colors.white, // белый фон
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//           child: Column(
//             children: [
//               SizedBox(height: topPadding),
//               // Заголовок
//               Text(
//                 'Выберите пол',
//                 style: GoogleFonts.robotoMono(
//                   fontSize: 26,
//                   fontWeight: FontWeight.w500,
//                   color: const Color(0xFF5C5248),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.05),
//               // Две картинки с кнопками
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Женский вариант
//                   _GenderOption(
//                     imagePath: 'assets/images/womansign.png',
//                     buttonText: 'Женский',
//                     buttonColor: const Color(0xFFF0B1C4),
//                     onPressed: () {
//                       // TODO: сохранить пол и перейти дальше
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Выбран женский пол')),
//                       );
//                     },
//                   ),
//                   // Мужской вариант
//                   _GenderOption(
//                     imagePath: 'assets/images/mansign.png',
//                     buttonText: 'Мужской',
//                     buttonColor: const Color(0xFF9991DA),
//                     onPressed: () {
//                       // TODO: сохранить пол и перейти дальше
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Выбран мужской пол')),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               const Spacer(), // всё, что снизу, прижимается к низу
//               // Картинка внизу
//               Image.asset(
//                 'assets/images/sexguy.png',
//                 width: 353,
//                 height: 325,
//                 fit: BoxFit.contain,
//               ),
//               SizedBox(height: bottomPadding),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Вспомогательный виджет для пары "картинка + кнопка"
// class _GenderOption extends StatelessWidget {
//   final String imagePath;
//   final String buttonText;
//   final Color buttonColor;
//   final VoidCallback onPressed;

//   const _GenderOption({
//     required this.imagePath,
//     required this.buttonText,
//     required this.buttonColor,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Image.asset(
//           imagePath,
//           width: 134,
//           height: 134,
//           fit: BoxFit.contain,
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: buttonColor,
//             foregroundColor: Colors.white,
//             fixedSize: const Size(131, 38),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: Text(
//             buttonText,
//             style: GoogleFonts.robotoMono(
//               fontSize: 21,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weight_screen.dart';  // 👈 ДОБАВЛЕН импорт для перехода

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Размеры экрана (для адаптивности, но мы используем точные значения)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Отступ сверху и снизу (для красоты)
    final topPadding = screenHeight * 0.05;
    final bottomPadding = screenHeight * 0.03;

    return Scaffold(
      backgroundColor: Colors.white, // белый фон
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
              SizedBox(height: topPadding),
              // Заголовок
              Text(
                'Выберите пол',
                style: GoogleFonts.robotoMono(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5C5248),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              // Две картинки с кнопками
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Женский вариант
                  _GenderOption(
                    imagePath: 'assets/images/womansign.png',
                    buttonText: 'Женский',
                    buttonColor: const Color(0xFFF0B1C4),
                    onPressed: () {
                      // 👇 ИЗМЕНЕНО: переходим на экран веса
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WeightScreen()),
                      );
                    },
                  ),
                  // Мужской вариант
                  _GenderOption(
                    imagePath: 'assets/images/mansign.png',
                    buttonText: 'Мужской',
                    buttonColor: const Color(0xFF9991DA),
                    onPressed: () {
                      // 👇 ИЗМЕНЕНО: переходим на экран веса
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WeightScreen()),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(), // всё, что снизу, прижимается к низу
              // Картинка внизу
              Image.asset(
                'assets/images/sexguy.png',
                width: 353,
                height: 325,
                fit: BoxFit.contain,
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}

// Вспомогательный виджет для пары "картинка + кнопка"
class _GenderOption extends StatelessWidget {
  final String imagePath;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _GenderOption({
    required this.imagePath,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          width: 134,
          height: 134,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            fixedSize: const Size(131, 38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            buttonText,
            style: GoogleFonts.robotoMono(
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
