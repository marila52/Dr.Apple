import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../theme/app_colors.dart';

/// Выбор месяца и года с листанием стрелками.
Future<DateTime?> showMonthYearPickerSheet({
  required BuildContext context,
  required DateTime initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _MonthYearPickerSheet(initialDate: initialDate),
  );
}

class _MonthYearPickerSheet extends StatefulWidget {
  const _MonthYearPickerSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<_MonthYearPickerSheet> {
  late int _year;
  late int _month;

  static const _monthNames = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
    _month = widget.initialDate.month;
  }

  void _apply() {
    final day = widget.initialDate.day;
    final maxDay = DateTime(_year, _month + 1, 0).day;
    final safeDay = day > maxDay ? maxDay : day;
    Navigator.pop(context, DateTime(_year, _month, safeDay));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() => _year--),
                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
              ),
              Text(
                '$_year',
                style: AppFonts.robotoMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _year++),
                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, index) {
              final m = index + 1;
              final selected = m == _month;
              return GestureDetector(
                onTap: () => setState(() => _month = m),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.macroPink : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.macroPink : AppColors.border,
                    ),
                  ),
                  child: Text(
                    _monthNames[index],
                    style: AppFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Выбрать'),
            ),
          ),
        ],
      ),
    );
  }
}
