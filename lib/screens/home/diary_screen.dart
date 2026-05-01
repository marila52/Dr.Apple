// // screens/home/diary_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../providers/auth_provider.dart';
// import '../../models/diary_entry_model.dart';
// import '../../services/database/diary_dao.dart';
// import 'home_screen.dart';  // 👈 ДОБАВЛЕН импорт HomeScreen

// class DiaryScreen extends StatefulWidget {
//   const DiaryScreen({super.key});

//   @override
//   State<DiaryScreen> createState() => _DiaryScreenState();
// }

// class _DiaryScreenState extends State<DiaryScreen> {
//   final DiaryDao _diaryDao = DiaryDao();
  
//   DateTime _selectedDate = DateTime.now();
//   List<DiaryEntry> _entries = [];
//   Map<String, double> _dailySummary = {
//     'calories': 0,
//     'proteins': 0,
//     'fats': 0,
//     'carbs': 0,
//   };
  
//   // Нормы КБЖУ (позже будут из UserDataProvider)
//   final Map<String, double> _dailyTargets = {
//     'calories': 2000,
//     'proteins': 150,
//     'fats': 200,
//     'carbs': 200,
//   };
  
//   int _waterIntake = 250;
//   final int _waterTarget = 2000;
  
//   final Map<String, List<DiaryEntry>> _meals = {
//     'breakfast': [],
//     'lunch': [],
//     'dinner': [],
//     'snack': [],
//   };
  
//   final Map<String, String> _mealNames = {
//     'breakfast': 'Завтрак',
//     'lunch': 'Обед',
//     'dinner': 'Ужин',
//     'snack': 'Перекус',
//   };
  
//   final Map<String, IconData> _mealIcons = {
//     'breakfast': Icons.brightness_5,
//     'lunch': Icons.light_mode,
//     'dinner': Icons.nightlight_round,
//     'snack': Icons.cake,
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
  
//   Future<void> _loadData() async {
//     final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
//     final userId = authProvider.user?.uid;
    
//     if (userId != null) {
//       final entries = await _diaryDao.getEntriesByDate(_selectedDate, userId);
//       setState(() {
//         _entries = entries;
//         _groupEntriesByMeal();
//         _calculateDailySummary();
//       });
//     }
//   }
  
//   void _groupEntriesByMeal() {
//     _meals.forEach((key, _) => _meals[key]!.clear());
    
//     for (var entry in _entries) {
//       if (_meals.containsKey(entry.mealType)) {
//         _meals[entry.mealType]!.add(entry);
//       }
//     }
//   }
  
//   void _calculateDailySummary() {
//     double calories = 0;
//     double proteins = 0;
//     double fats = 0;
//     double carbs = 0;
    
//     for (var entry in _entries) {
//       calories += entry.calories;
//       proteins += entry.proteins;
//       fats += entry.fats;
//       carbs += entry.carbs;
//     }
    
//     setState(() {
//       _dailySummary = {
//         'calories': calories,
//         'proteins': proteins,
//         'fats': fats,
//         'carbs': carbs,
//       };
//     });
//   }
  
//   Future<void> _changeDate(DateTime newDate) async {
//     setState(() {
//       _selectedDate = newDate;
//     });
//     await _loadData();
//   }
  
//   void _showAddEntryModal(String mealType) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _AddEntryBottomSheet(
//         mealType: mealType,
//         onEntryAdded: () => _loadData(),
//       ),
//     );
//   }
  
//   void _showEntryDetails(DiaryEntry entry) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _EntryDetailsBottomSheet(
//         entry: entry,
//         onEntryDeleted: () => _loadData(),
//         onEntryEdited: () => _loadData(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDF8FF),
//       appBar: AppBar(
//         title: Text(
//           'Дневник питания',
//           style: GoogleFonts.robotoMono(
//             color: const Color(0xFF5C5248),
//             fontSize: 16,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
//           onPressed: () {},
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline, color: Color(0xFF5C5248)),
//             onPressed: () {},
//           ),
//         ],
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _buildCalendar(),
          
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 children: [
//                   _buildMacroCard(),
//                   const SizedBox(height: 20),
//                   ..._buildMealSections(),
//                   const SizedBox(height: 20),
//                   _buildWaterCard(),
//                   const SizedBox(height: 80),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddEntryModal('breakfast'),
//         backgroundColor: const Color(0xFF5C5248),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
  
//   Widget _buildCalendar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 4,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   _getMonthName(_selectedDate.month),
//                   style: GoogleFonts.robotoMono(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF5C5248),
//                   ),
//                 ),
//                 Text(
//                   '${_selectedDate.year}',
//                   style: GoogleFonts.robotoMono(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'].map((day) {
//                 return Text(
//                   day,
//                   style: GoogleFonts.robotoMono(
//                     fontSize: 12,
//                     color: Colors.grey.shade500,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 8),
          
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: List.generate(30, (index) {
//                 final day = index + 1;
//                 final isSelected = day == _selectedDate.day;
//                 return GestureDetector(
//                   onTap: () {
//                     _changeDate(DateTime(_selectedDate.year, _selectedDate.month, day));
//                   },
//                   child: Container(
//                     width: 44,
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                       color: isSelected ? const Color(0xFF5C5248) : Colors.transparent,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       day.toString(),
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.robotoMono(
//                         color: isSelected ? Colors.white : const Color(0xFF5C5248),
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildMacroCard() {
//     final caloriesPercent = (_dailySummary['calories']! / _dailyTargets['calories']!) * 100;
    
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF5C5248),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '${_dailySummary['calories']!.toInt()} ккал съедено',
//                 style: GoogleFonts.robotoMono(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 '${_dailyTargets['calories']!.toInt()}',
//                 style: GoogleFonts.robotoMono(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: caloriesPercent / 100,
//             backgroundColor: Colors.white24,
//             color: Colors.amber,
//             minHeight: 8,
//             borderRadius: BorderRadius.circular(4),
//           ),
//           const SizedBox(height: 16),
          
//           Row(
//             children: [
//               _buildMacroItem('Белки', _dailySummary['proteins']!, _dailyTargets['proteins']!, Colors.green),
//               const SizedBox(width: 16),
//               _buildMacroItem('Жиры', _dailySummary['fats']!, _dailyTargets['fats']!, Colors.orange),
//               const SizedBox(width: 16),
//               _buildMacroItem('Углеводы', _dailySummary['carbs']!, _dailyTargets['carbs']!, Colors.blue),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildMacroItem(String title, double current, double target, Color color) {
//     final percent = target > 0 ? (current / target * 100).toInt() : 0;
//     final percentValue = percent > 100 ? 100 : percent;
    
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.robotoMono(
//               fontSize: 12,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               Expanded(
//                 child: LinearProgressIndicator(
//                   value: percentValue / 100,
//                   backgroundColor: Colors.white24,
//                   color: color,
//                   minHeight: 6,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 '${current.toInt()}/${target.toInt()} г',
//                 style: GoogleFonts.robotoMono(
//                   fontSize: 11,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   List<Widget> _buildMealSections() {
//     return _mealNames.entries.map((entry) {
//       final mealType = entry.key;
//       final mealName = entry.value;
//       final meals = _meals[mealType] ?? [];
      
//       return _buildMealSection(
//         title: mealName,
//         icon: _mealIcons[mealType]!,
//         meals: meals,
//         onAdd: () => _showAddEntryModal(mealType),
//       );
//     }).toList();
//   }
  
//   Widget _buildMealSection({
//     required String title,
//     required IconData icon,
//     required List<DiaryEntry> meals,
//     required VoidCallback onAdd,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(icon, color: const Color(0xFF5C5248), size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: GoogleFonts.robotoMono(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF5C5248),
//                   ),
//                 ),
//                 const Spacer(),
//                 if (meals.isNotEmpty)
//                   Text(
//                     '${meals.fold(0.0, (sum, m) => sum + m.calories).toInt()} ккал',
//                     style: GoogleFonts.robotoMono(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 IconButton(
//                   icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5C5248)),
//                   onPressed: onAdd,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
//           if (meals.isEmpty)
//             const Padding(
//               padding: EdgeInsets.only(bottom: 16),
//               child: Center(
//                 child: Text(
//                   'Добавить',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             )
//           else
//             Column(
//               children: meals.map((meal) {
//                 return ListTile(
//                   title: Text(
//                     meal.productName,
//                     style: GoogleFonts.robotoMono(fontSize: 14),
//                   ),
//                   trailing: Text(
//                     '${meal.calories.toInt()} ккал',
//                     style: GoogleFonts.robotoMono(
//                       fontSize: 14,
//                       color: const Color(0xFF5C5248),
//                     ),
//                   ),
//                   onTap: () => _showEntryDetails(meal),
//                 );
//               }).toList(),
//             ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildWaterCard() {
//     final percent = (_waterIntake / _waterTarget) * 100;
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Водный баланс:',
//                 style: GoogleFonts.robotoMono(
//                   fontSize: 14,
//                   color: const Color(0xFF5C5248),
//                 ),
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF5C5248)),
//                     onPressed: () => setState(() {
//                       if (_waterIntake >= 250) _waterIntake -= 250;
//                     }),
//                   ),
//                   Text(
//                     '$_waterIntake/$_waterTarget мл',
//                     style: GoogleFonts.robotoMono(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF5C5248),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5C5248)),
//                     onPressed: () => setState(() {
//                       if (_waterIntake + 250 <= _waterTarget) _waterIntake += 250;
//                     }),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: percent / 100,
//             backgroundColor: Colors.grey.shade200,
//             color: Colors.blue,
//             minHeight: 8,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ],
//       ),
//     );
//   }
  
//   String _getMonthName(int month) {
//     const months = [
//       'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
//       'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
//     ];
//     return months[month - 1];
//   }
// }

// // ==================== ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ====================

// class _AddEntryBottomSheet extends StatelessWidget {
//   final String mealType;
//   final VoidCallback onEntryAdded;
  
//   const _AddEntryBottomSheet({
//     required this.mealType,
//     required this.onEntryAdded,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               'Добавить продукт',
//               style: GoogleFonts.robotoMono(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF5C5248),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: Text(
//                 'Здесь будет поиск продуктов\n(скоро будет реализовано)',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.robotoMono(color: Colors.grey),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _EntryDetailsBottomSheet extends StatelessWidget {
//   final DiaryEntry entry;
//   final VoidCallback onEntryDeleted;
//   final VoidCallback onEntryEdited;
  
//   const _EntryDetailsBottomSheet({
//     required this.entry,
//     required this.onEntryDeleted,
//     required this.onEntryEdited,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             entry.productName,
//             style: GoogleFonts.robotoMono(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF5C5248),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow('Количество', '${entry.quantity.toInt()} г'),
//           _buildDetailRow('Калории', '${entry.calories.toInt()} ккал'),
//           _buildDetailRow('Белки', '${entry.proteins.toInt()} г'),
//           _buildDetailRow('Жиры', '${entry.fats.toInt()} г'),
//           _buildDetailRow('Углеводы', '${entry.carbs.toInt()} г'),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     onEntryDeleted();
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.red,
//                     side: const BorderSide(color: Colors.red),
//                   ),
//                   child: const Text('Удалить'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5C5248),
//                   ),
//                   child: const Text('Редактировать'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.robotoMono(color: Colors.grey.shade600),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.robotoMono(
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF5C5248),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// screens/home/diary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/diary_entry_model.dart';
import '../../services/database/diary_dao.dart';
import '../auth/login_screen.dart';  // 👈 ИЗМЕНЕНО: импорт LoginScreen

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryDao _diaryDao = DiaryDao();
  
  DateTime _selectedDate = DateTime.now();
  List<DiaryEntry> _entries = [];
  Map<String, double> _dailySummary = {
    'calories': 0,
    'proteins': 0,
    'fats': 0,
    'carbs': 0,
  };
  
  // Нормы КБЖУ (позже будут из UserDataProvider)
  final Map<String, double> _dailyTargets = {
    'calories': 2000,
    'proteins': 150,
    'fats': 200,
    'carbs': 200,
  };
  
  int _waterIntake = 250;
  final int _waterTarget = 2000;
  
  final Map<String, List<DiaryEntry>> _meals = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snack': [],
  };
  
  final Map<String, String> _mealNames = {
    'breakfast': 'Завтрак',
    'lunch': 'Обед',
    'dinner': 'Ужин',
    'snack': 'Перекус',
  };
  
  final Map<String, IconData> _mealIcons = {
    'breakfast': Icons.brightness_5,
    'lunch': Icons.light_mode,
    'dinner': Icons.nightlight_round,
    'snack': Icons.cake,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      final entries = await _diaryDao.getEntriesByDate(_selectedDate, userId);
      setState(() {
        _entries = entries;
        _groupEntriesByMeal();
        _calculateDailySummary();
      });
    }
  }
  
  void _groupEntriesByMeal() {
    _meals.forEach((key, _) => _meals[key]!.clear());
    
    for (var entry in _entries) {
      if (_meals.containsKey(entry.mealType)) {
        _meals[entry.mealType]!.add(entry);
      }
    }
  }
  
  void _calculateDailySummary() {
    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;
    
    for (var entry in _entries) {
      calories += entry.calories;
      proteins += entry.proteins;
      fats += entry.fats;
      carbs += entry.carbs;
    }
    
    setState(() {
      _dailySummary = {
        'calories': calories,
        'proteins': proteins,
        'fats': fats,
        'carbs': carbs,
      };
    });
  }
  
  Future<void> _changeDate(DateTime newDate) async {
    setState(() {
      _selectedDate = newDate;
    });
    await _loadData();
  }
  
  void _showAddEntryModal(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEntryBottomSheet(
        mealType: mealType,
        onEntryAdded: () => _loadData(),
      ),
    );
  }
  
  void _showEntryDetails(DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntryDetailsBottomSheet(
        entry: entry,
        onEntryDeleted: () => _loadData(),
        onEntryEdited: () => _loadData(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        title: Text(
          'Дневник питания',
          style: GoogleFonts.robotoMono(
            color: const Color(0xFF5C5248),
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () {
            // 👇 ИЗМЕНЕНО: переход на LoginScreen при нажатии "Назад"
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF5C5248)),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMacroCard(),
                  const SizedBox(height: 20),
                  ..._buildMealSections(),
                  const SizedBox(height: 20),
                  _buildWaterCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryModal('breakfast'),
        backgroundColor: const Color(0xFF5C5248),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMonthName(_selectedDate.month),
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5C5248),
                  ),
                ),
                Text(
                  '${_selectedDate.year}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'].map((day) {
                return Text(
                  day,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(30, (index) {
                final day = index + 1;
                final isSelected = day == _selectedDate.day;
                return GestureDetector(
                  onTap: () {
                    _changeDate(DateTime(_selectedDate.year, _selectedDate.month, day));
                  },
                  child: Container(
                    width: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5C5248) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      day.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(
                        color: isSelected ? Colors.white : const Color(0xFF5C5248),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMacroCard() {
    final caloriesPercent = (_dailySummary['calories']! / _dailyTargets['calories']!) * 100;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5C5248),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_dailySummary['calories']!.toInt()} ккал съедено',
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_dailyTargets['calories']!.toInt()}',
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: caloriesPercent / 100,
            backgroundColor: Colors.white24,
            color: Colors.amber,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildMacroItem('Белки', _dailySummary['proteins']!, _dailyTargets['proteins']!, Colors.green),
              const SizedBox(width: 16),
              _buildMacroItem('Жиры', _dailySummary['fats']!, _dailyTargets['fats']!, Colors.orange),
              const SizedBox(width: 16),
              _buildMacroItem('Углеводы', _dailySummary['carbs']!, _dailyTargets['carbs']!, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMacroItem(String title, double current, double target, Color color) {
    final percent = target > 0 ? (current / target * 100).toInt() : 0;
    final percentValue = percent > 100 ? 100 : percent;
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentValue / 100,
                  backgroundColor: Colors.white24,
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${current.toInt()}/${target.toInt()} г',
                style: GoogleFonts.robotoMono(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildMealSections() {
    return _mealNames.entries.map((entry) {
      final mealType = entry.key;
      final mealName = entry.value;
      final meals = _meals[mealType] ?? [];
      
      return _buildMealSection(
        title: mealName,
        icon: _mealIcons[mealType]!,
        meals: meals,
        onAdd: () => _showAddEntryModal(mealType),
      );
    }).toList();
  }
  
  Widget _buildMealSection({
    required String title,
    required IconData icon,
    required List<DiaryEntry> meals,
    required VoidCallback onAdd,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF5C5248), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C5248),
                  ),
                ),
                const Spacer(),
                if (meals.isNotEmpty)
                  Text(
                    '${meals.fold(0.0, (sum, m) => sum + m.calories).toInt()} ккал',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5C5248)),
                  onPressed: onAdd,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          if (meals.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text(
                  'Добавить',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: meals.map((meal) {
                return ListTile(
                  title: Text(
                    meal.productName,
                    style: GoogleFonts.robotoMono(fontSize: 14),
                  ),
                  trailing: Text(
                    '${meal.calories.toInt()} ккал',
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      color: const Color(0xFF5C5248),
                    ),
                  ),
                  onTap: () => _showEntryDetails(meal),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildWaterCard() {
    final percent = (_waterIntake / _waterTarget) * 100;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Водный баланс:',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: const Color(0xFF5C5248),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF5C5248)),
                    onPressed: () => setState(() {
                      if (_waterIntake >= 250) _waterIntake -= 250;
                    }),
                  ),
                  Text(
                    '$_waterIntake/$_waterTarget мл',
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5C5248),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5C5248)),
                    onPressed: () => setState(() {
                      if (_waterIntake + 250 <= _waterTarget) _waterIntake += 250;
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[month - 1];
  }
}

// ==================== ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ====================

class _AddEntryBottomSheet extends StatelessWidget {
  final String mealType;
  final VoidCallback onEntryAdded;
  
  const _AddEntryBottomSheet({
    required this.mealType,
    required this.onEntryAdded,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Добавить продукт',
              style: GoogleFonts.robotoMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5C5248),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Здесь будет поиск продуктов\n(скоро будет реализовано)',
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryDetailsBottomSheet extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onEntryDeleted;
  final VoidCallback onEntryEdited;
  
  const _EntryDetailsBottomSheet({
    required this.entry,
    required this.onEntryDeleted,
    required this.onEntryEdited,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.productName,
            style: GoogleFonts.robotoMono(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5C5248),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Количество', '${entry.quantity.toInt()} г'),
          _buildDetailRow('Калории', '${entry.calories.toInt()} ккал'),
          _buildDetailRow('Белки', '${entry.proteins.toInt()} г'),
          _buildDetailRow('Жиры', '${entry.fats.toInt()} г'),
          _buildDetailRow('Углеводы', '${entry.carbs.toInt()} г'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onEntryDeleted();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Удалить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C5248),
                  ),
                  child: const Text('Редактировать'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5C5248),
            ),
          ),
        ],
      ),
    );
  }
}