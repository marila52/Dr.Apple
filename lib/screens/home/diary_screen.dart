// screens/home/diary_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../models/diary_entry_model.dart';
import '../../services/database/diary_dao.dart';
import '../../services/firestore_service.dart';
import '../onboarding/gender_screen.dart';
import '../home/home_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryDao _diaryDao = DiaryDao();
  final FirestoreService _firestoreService = FirestoreService();
  late final ScrollController _dateScrollController;

  static const int _initialDateIndex = 100000;
  static const double _dateItemExtent = 64;

  DateTime _selectedDate = DateTime.now();
  List<DiaryEntry> _entries = [];

  Map<String, double> _dailySummary = {
    'calories': 0,
    'proteins': 0,
    'fats': 0,
    'carbs': 0,
  };

  int _waterIntake = 0;
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

    _selectedDate = DateTime.now();

    _dateScrollController = ScrollController(
    initialScrollOffset: _initialDateIndex * _dateItemExtent,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UserDataProvider>().loadCurrentUser();
      await _loadData();
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    

    final authProvider = Provider.of<CustomAuthProvider>(
      context,
      listen: false,
    );

    final userId = authProvider.user?.uid;

    if (userId == null) {
      print('LOAD DATA: userId is null');
      return;
    }

    final entries = await _diaryDao.getEntriesByDate(
      _selectedDate,
      userId,
    );

    final savedDiary = await _firestoreService.getDailyDiary(
      userId: userId,
      date: _selectedDate,
    );

    if (!mounted) return;

    setState(() {
      _entries = entries;
      _waterIntake = ((savedDiary?['waterIntake'] ?? 0) as num).toInt();
      _groupEntriesByMeal();
      _calculateDailySummaryWithoutSetState();
    });
  }

  void _groupEntriesByMeal() {
    for (final key in _meals.keys) {
      _meals[key]!.clear();
    }

    for (final entry in _entries) {
      if (_meals.containsKey(entry.mealType)) {
        _meals[entry.mealType]!.add(entry);
      }
    }
  }

  void _calculateDailySummaryWithoutSetState() {
    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;

    for (final entry in _entries) {
      calories += entry.calories;
      proteins += entry.proteins;
      fats += entry.fats;
      carbs += entry.carbs;
    }

    _dailySummary = {
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
    };
  }

  Future<void> _changeDate(DateTime newDate) async {
    setState(() {
      _selectedDate = newDate;
    });

    await _loadData();
  }

  Future<void> _jumpToSelectedDateInCalendar() async {
    final today = DateTime.now();
    final difference = _selectedDate.difference(
      DateTime(today.year, today.month, today.day),
    ).inDays;

    final targetIndex = _initialDateIndex + difference;

    if (!_dateScrollController.hasClients) return;

    await _dateScrollController.animateTo(
      targetIndex * _dateItemExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showMonthPicker() async {
    final selectedMonth = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final month = index + 1;
            final isSelected = month == _selectedDate.month;

            return GestureDetector(
              onTap: () => Navigator.pop(context, month),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5C5248)
                      : const Color(0xFFFDF8FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _getMonthName(month),
                  style: GoogleFonts.roboto(
                    color:
                        isSelected ? Colors.white : const Color(0xFF5C5248),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedMonth == null) return;

    final daysInSelectedMonth = DateTime(
      _selectedDate.year,
      selectedMonth + 1,
      0,
    ).day;

    final correctedDay = _selectedDate.day > daysInSelectedMonth
        ? daysInSelectedMonth
        : _selectedDate.day;

    await _changeDate(
      DateTime(
        _selectedDate.year,
        selectedMonth,
        correctedDay,
      ),
    );
    await _jumpToSelectedDateInCalendar();
  }

  Future<void> _showYearPicker() async {
    final currentYear = DateTime.now().year;
    final years = List.generate(21, (index) => currentYear - 10 + index);

    final selectedYear = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            final isSelected = year == _selectedDate.year;

            return ListTile(
              title: Text(
                year.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: isSelected
                      ? const Color(0xFF5C5248)
                      : Colors.grey.shade700,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => Navigator.pop(context, year),
            );
          },
        );
      },
    );

    if (selectedYear == null) return;

    final daysInSelectedMonth = DateTime(
      selectedYear,
      _selectedDate.month + 1,
      0,
    ).day;

    final correctedDay = _selectedDate.day > daysInSelectedMonth
        ? daysInSelectedMonth
        : _selectedDate.day;

    await _changeDate(
      DateTime(
        selectedYear,
        _selectedDate.month,
        correctedDay,
      ),
    );
    await _jumpToSelectedDateInCalendar();
  }

  Future<void> _saveDailyDiary() async {
    final authProvider = Provider.of<CustomAuthProvider>(
      context,
      listen: false,
    );

    final userId = authProvider.user?.uid;

    if (userId == null) return;

    _groupEntriesByMeal();
    _calculateDailySummaryWithoutSetState();

    final mealsMap = {
      'breakfast': _meals['breakfast']!.map((entry) => entry.toJson()).toList(),
      'lunch': _meals['lunch']!.map((entry) => entry.toJson()).toList(),
      'dinner': _meals['dinner']!.map((entry) => entry.toJson()).toList(),
      'snack': _meals['snack']!.map((entry) => entry.toJson()).toList(),
    };

    try {
      await _firestoreService.saveDailyDiary(
        userId: userId,
        date: _selectedDate,
        waterIntake: _waterIntake,
        calories: _dailySummary['calories'] ?? 0,
        proteins: _dailySummary['proteins'] ?? 0,
        fats: _dailySummary['fats'] ?? 0,
        carbs: _dailySummary['carbs'] ?? 0,
        meals: mealsMap,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddEntryModal(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEntryBottomSheet(
        mealType: mealType,
        onEntryAdded: () async {
          await _loadData();
          await _saveDailyDiary();
        },
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
        onEntryDeleted: () async {
          await _loadData();
          await _saveDailyDiary();
        },
        onEntryEdited: () async {
          await _loadData();
          await _saveDailyDiary();
        },
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
          style: GoogleFonts.roboto(
            color: const Color(0xFF5C5248),
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const GenderScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF5C5248)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
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
                  const SizedBox(height: 16),
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
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Row(
                    children: [
                      Text(
                        _getMonthName(_selectedDate.month),
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5C5248),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF5C5248),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showYearPicker,
                  child: Row(
                    children: [
                      Text(
                        '${_selectedDate.year}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.builder(
              controller: _dateScrollController,
              scrollDirection: Axis.horizontal,
              itemExtent: _dateItemExtent,
              itemBuilder: (context, index) {
                final date = today.add(
                  Duration(days: index - _initialDateIndex),
                );

                final isSelected =
                    date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;

                final isToday =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                return GestureDetector(
                  onTap: () => _changeDate(date),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5C5248)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isToday && !isSelected
                          ? Border.all(color: const Color(0xFF5C5248))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekDayName(date.weekday),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5C5248),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekDayName(int weekday) {
    const days = [
      'Пн',
      'Вт',
      'Ср',
      'Чт',
      'Пт',
      'Сб',
      'Вс',
    ];

    return days[weekday - 1];
  }

  Widget _buildMacroCard() {
    final user = context.watch<UserDataProvider>().currentUser;

    final double caloriesTarget = user?.dailyCalories ?? 0;
    final double proteinsTarget = user?.dailyProteins ?? 0;
    final double fatsTarget = user?.dailyFats ?? 0;
    final double carbsTarget = user?.dailyCarbs ?? 0;

    final double caloriesPercent = caloriesTarget > 0
        ? (_dailySummary['calories']! / caloriesTarget)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5C5248),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${_dailySummary['calories']!.toInt()} / ${caloriesTarget.toInt()} ккал',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: caloriesPercent.clamp(0.0, 1.0),
            backgroundColor: Colors.white24,
            color: Colors.amber,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMacroItem(
                'Белки',
                _dailySummary['proteins']!,
                proteinsTarget,
              ),
              const SizedBox(width: 12),
              _buildMacroItem(
                'Жиры',
                _dailySummary['fats']!,
                fatsTarget,
              ),
              const SizedBox(width: 12),
              _buildMacroItem(
                'Углеводы',
                _dailySummary['carbs']!,
                carbsTarget,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String title, double current, double target) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${current.toInt()}/${target.toInt()} г',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMealSections() {
    return _mealNames.entries.map((entry) {
      final mealType = entry.key;
      final mealName = entry.value;
      final meals = _meals[mealType] ?? [];

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_mealIcons[mealType], color: const Color(0xFF5C5248)),
                const SizedBox(width: 8),
                Text(
                  mealName,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C5248),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF5C5248),
                  ),
                  onPressed: () => _showAddEntryModal(mealType),
                ),
              ],
            ),
            if (meals.isEmpty)
              const Text('Добавить', style: TextStyle(color: Colors.grey))
            else
              ...meals.map(
                (meal) => ListTile(
                  title: Text(meal.productName),
                  trailing: Text('${meal.calories.toInt()} ккал'),
                  onTap: () => _showEntryDetails(meal),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildWaterCard() {
    final double percent = (_waterIntake / _waterTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Водный баланс:',
                style: GoogleFonts.roboto(
                  color: const Color(0xFF5C5248),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Color(0xFF5C5248),
                ),
                onPressed: () async {
                  if (_waterIntake >= 250) {
                    setState(() {
                      _waterIntake -= 250;
                    });

                    await _saveDailyDiary();
                  }
                },
              ),
              Text(
                '$_waterIntake/$_waterTarget мл',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5C5248),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF5C5248),
                ),
                onPressed: () async {
                  if (_waterIntake + 250 <= _waterTarget) {
                    setState(() {
                      _waterIntake += 250;
                    });

                    await _saveDailyDiary();
                  }
                },
              ),
            ],
          ),
          LinearProgressIndicator(
            value: percent,
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
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];

    return months[month - 1];
  }
}

class _AddEntryBottomSheet extends StatelessWidget {
  final String mealType;
  final Future<void> Function() onEntryAdded;

  const _AddEntryBottomSheet({
    required this.mealType,
    required this.onEntryAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text(
          'Здесь будет поиск продуктов\nпока еда не добавляется',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _EntryDetailsBottomSheet extends StatelessWidget {
  final DiaryEntry entry;
  final Future<void> Function() onEntryDeleted;
  final Future<void> Function() onEntryEdited;

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
      child: Text(entry.productName),
    );
  }
}