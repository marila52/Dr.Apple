import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import '../../providers/user_data_provider.dart';
import '../../utils/kcal_calculator.dart';
import '../../screens/onboarding/calorie_loading_screen.dart';
//import '../../screens/home/home_screen.dart';
//import '../../screens/onboarding/calorie_result_screen.dart';
//import '../../screens/home/diary_screen.dart'; // если файл так называется

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  int _selectedGoal = -1;
  
  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Сбросить вес',
      'subtitle': 'Дефицит калорий 15%',
      'goal': Goal.weightLoss,
    },
    {
      'title': 'Поддерживать вес',
      'subtitle': 'Поддержание текущего веса',
      'goal': Goal.maintenance,
    },
    {
      'title': 'Набрать массу',
      'subtitle': 'Профицит калорий 15%',
      'goal': Goal.weightGain,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Цель',
          style: AppFonts.roboto(color: const Color(0xFF5C5248)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            Text(
              'Ваша цель',
              style: AppFonts.literata(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5248),
              ),
            ),
            
            const SizedBox(height: 30),
            
            Expanded(
              child: ListView.separated(
                itemCount: _goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final isSelected = _selectedGoal == index;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGoal = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF5C5248).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF5C5248)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal['title'],
                                  style: AppFonts.literata(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? const Color(0xFF5C5248)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  goal['subtitle'],
                                  style: AppFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF5C5248),
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedGoal != -1
                    ? () async {
                        final userProvider = context.read<UserDataProvider>();
                        final goal = _goals[_selectedGoal]['goal'] as Goal;

                        final success = await userProvider.savePersonalData(goal: goal);

                        if (!mounted) return;

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => CalorieLoadingScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(userProvider.error ?? 'Не удалось сохранить данные'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C5248),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'ЗАВЕРШИТЬ',
                  style: AppFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}