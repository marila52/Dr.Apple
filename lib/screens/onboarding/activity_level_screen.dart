import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'goal_screen.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  int _selectedLevel = -1;
  
  final List<Map<String, dynamic>> _levels = [
    {
      'title': 'Изначальный',
      'subtitle': 'почти нет физической нагрузки, сидящий образ жизни',
    },
    {
      'title': 'Легкий',
      'subtitle': '1-2 тренировки в неделю, легкие прогулки',
    },
    {
      'title': 'Средний',
      'subtitle': '3-4 тренировки в неделю, умеренная активность в течение дня',
    },
    {
      'title': 'Высокий',
      'subtitle': '5-6 тренировок в неделю, активный образ жизни',
    },
    {
      'title': 'Очень высокий',
      'subtitle': 'ежедневные тренировки, профессиональный спорт',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Активность',
          style: GoogleFonts.roboto(color: const Color(0xFF5C5248)),
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
              'Ваш уровень активности',
              style: GoogleFonts.literata(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5248),
              ),
            ),
            
            const SizedBox(height: 30),
            
            Expanded(
              child: ListView.separated(
                itemCount: _levels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  final isSelected = _selectedLevel == index;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLevel = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                                  level['title'],
                                  style: GoogleFonts.literata(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? const Color(0xFF5C5248)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  level['subtitle'],
                                  style: GoogleFonts.roboto(
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
                onPressed: _selectedLevel != -1
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GoalScreen()),
                        );
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
                  'ДАЛЕЕ',
                  style: GoogleFonts.roboto(
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