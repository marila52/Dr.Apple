import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/diary_entry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../services/diary_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_header.dart';
import '../../widgets/month_year_picker_sheet.dart';
import '../products/product_search_screen.dart';
import 'diary_entry_sheet.dart';
import 'profile_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryService _diaryService = DiaryService();
  late final ScrollController _dateScrollController;

  static const int _initialDateIndex = 100000;
  static const double _dateItemExtent = 56;

  DateTime _selectedDate = DateTime.now();
  List<DiaryEntry> _entries = [];

  final Map<String, double> _dailySummary = {
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

  final Map<String, bool> _mealExpanded = {
    'breakfast': false,
    'lunch': false,
    'dinner': false,
    'snack': false,
  };

  @override
void initState() {
  super.initState();
  _dateScrollController = ScrollController(
    initialScrollOffset: _initialDateIndex * _dateItemExtent,
  );
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final ctx = context;
    await ctx.read<UserDataProvider>().loadCurrentUser(ctx);
    await _loadData();
  });
}

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = context.read<CustomAuthProvider>().user?.uid;
    if (userId == null) return;

    final entries = await _diaryService.getEntriesByDate(_selectedDate, userId);
    if (!mounted) return;

    setState(() {
      _entries = entries;
      _waterIntake = 0; // Пока нет данных о воде в локальной БД
      _groupEntriesByMeal();
      _calculateDailySummary();
    });
  }

  void _groupEntriesByMeal() {
    for (final key in _meals.keys) {
      _meals[key]!.clear();
    }
    for (final entry in _entries) {
      _meals[entry.mealType]?.add(entry);
    }
  }

  void _calculateDailySummary() {
    double calories = 0, proteins = 0, fats = 0, carbs = 0;
    for (final entry in _entries) {
      calories += entry.calories;
      proteins += entry.proteins;
      fats += entry.fats;
      carbs += entry.carbs;
    }
    _dailySummary['calories'] = calories;
    _dailySummary['proteins'] = proteins;
    _dailySummary['fats'] = fats;
    _dailySummary['carbs'] = carbs;
  }

  Future<void> _changeDate(DateTime newDate) async {
    setState(() => _selectedDate = newDate);
    await _loadData();
    
    // Прокрутка к выбранной дате
    final today = DateTime.now();
    final diff = newDate.difference(today).inDays;
    final targetIndex = _initialDateIndex + diff;
    _dateScrollController.animateTo(
      targetIndex * _dateItemExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openSearch(String mealType) async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSearchScreen(
          mealType: mealType,
          selectedDate: _selectedDate,
        ),
      ),
    );
    if (added == true) {
      await _loadData();
    }
  }

  void _showEntrySheet(DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DiaryEntrySheet(
        entry: entry,
        onChanged: () async {
          await _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDataProvider>().currentUser;
    final calTarget = user?.dailyCalories ?? 0;
    final proteinTarget = user?.dailyProteins ?? 0;
    final fatTarget = user?.dailyFats ?? 0;
    final carbTarget = user?.dailyCarbs ?? 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок с иконкой профиля справа
            AppBackHeader(
              title: 'Дневник питания',
              trailing: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Icon(Icons.person_outline, color: AppColors.primary, size: 22),
                ),
              ),
            ),
            _buildDateHeader(),
            _buildDateStrip(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  child: Column(
                    children: [
                      _buildCalorieCard(calTarget),
                      const SizedBox(height: 12),
                      _buildMacroRow(proteinTarget, fatTarget, carbTarget),
                      const SizedBox(height: 16),
                      ..._mealNames.entries.map((e) => _buildMealCard(e.key, e.value)),
                      const SizedBox(height: 12),
                      _buildWaterCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSearch('breakfast'),
        backgroundColor: const Color(0xFFFFA2C3),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Future<void> _pickMonthYear() async {
    final picked = await showMonthYearPickerSheet(
      context: context,
      initialDate: _selectedDate,
    );
    if (picked != null) {
      await _changeDate(picked);
    }
  }

  Widget _buildDateHeader() {
    const months = [
      'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
      'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: _pickMonthYear,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${months[_selectedDate.month - 1]}, ${_selectedDate.year}',
                style: AppFonts.prata(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateStrip() {
    final today = DateTime.now();
    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemExtent: _dateItemExtent,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index - _initialDateIndex));
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, today);

          return GestureDetector(
            onTap: () => _changeDate(date),
            child: Column(
              children: [
                Text(
                  _weekShort(date.weekday),
                  style: AppFonts.prata(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.macroPink : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.macroPink
                          : isToday
                              ? AppColors.primary
                              : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '${date.day}',
                    style: AppFonts.robotoMono(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalorieCard(double target) {
    final eaten = _dailySummary['calories']!;
    final progress = target > 0 ? (eaten / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                eaten.toInt().toString(),
                style: AppFonts.robotoMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'ккал съедено',
                  style: AppFonts.prata(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
              const Spacer(),
              Text(
                target.toInt().toString(),
                style: AppFonts.robotoMono(
                  fontSize: 22,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.macroPink.withValues(alpha: 0.25),
              color: AppColors.macroPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(double pTarget, double fTarget, double cTarget) {
    return Row(
      children: [
        Expanded(
          child: _macroCard(
            'белки',
            _dailySummary['proteins']!,
            pTarget,
            AppColors.macroBlue,
            const Color(0xFF7BA3C4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _macroCard(
            'жиры',
            _dailySummary['fats']!,
            fTarget,
            AppColors.macroYellow,
            const Color(0xFFE8C88A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _macroCard(
            'углеводы',
            _dailySummary['carbs']!,
            cTarget,
            AppColors.macroGreen,
            const Color(0xFF9BC49A),
          ),
        ),
      ],
    );
  }

  Widget _macroCard(
    String label,
    double current,
    double target,
    Color bg,
    Color bar,
  ) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: 66,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 8,
                height: 38 * progress,
                color: bar,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: AppFonts.prata(fontSize: 12, color: AppColors.primaryDark),
                ),
                Text(
                  '${current.toInt()}/${target.toInt()} g',
                  style: AppFonts.robotoMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealType, String title) {
    final items = _meals[mealType] ?? [];
    final expanded = _mealExpanded[mealType] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _mealExpanded[mealType] = !expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppFonts.prata(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openSearch(mealType),
                    icon: const Icon(Icons.add, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          if (expanded && items.isNotEmpty)
            ...items.map(
              (e) => ListTile(
                dense: true,
                title: Text(
                  e.productName,
                  style: AppFonts.prata(fontSize: 14),
                ),
                trailing: Text(
                  '${e.calories.round()} ккал',
                  style: AppFonts.robotoMono(fontSize: 12),
                ),
                onTap: () => _showEntrySheet(e),
              ),
            ),
          if (expanded && items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextButton(
                onPressed: () => _openSearch(mealType),
                child: Text(
                  'Добавить',
                  style: AppFonts.prata(color: AppColors.textMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaterCard() {
    const glasses = 8;
    const totalGlasses = 16;
    final perGlass = _waterTarget / glasses;
    final filled = (_waterIntake / perGlass).floor().clamp(0, totalGlasses);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Водный баланс: $_waterIntake/$_waterTarget мл',
            style: AppFonts.robotoMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(glasses, (i) {
                  final isFilled = i < filled;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        if (isFilled && i == filled - 1) {
                          _waterIntake = (i * perGlass).round();
                        } else if (!isFilled && i == filled) {
                          _waterIntake = ((i + 1) * perGlass).round().clamp(0, _waterTarget);
                        }
                      });
                    },
                    child: Icon(
                      isFilled ? Icons.local_drink : Icons.add_circle_outline,
                      color: isFilled ? Colors.blue.shade400 : AppColors.border,
                      size: 28,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(glasses, (i) {
                  final index = i + glasses;
                  final isFilled = index < filled;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        if (isFilled && index == filled - 1) {
                          _waterIntake = (index * perGlass).round();
                        } else if (!isFilled && index == filled) {
                          _waterIntake = ((index + 1) * perGlass).round().clamp(0, _waterTarget);
                        }
                      });
                    },
                    child: Icon(
                      isFilled ? Icons.local_drink : Icons.add_circle_outline,
                      color: isFilled ? Colors.blue.shade400 : AppColors.border,
                      size: 28,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekShort(int weekday) {
    const d = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
    return d[weekday - 1];
  }
}