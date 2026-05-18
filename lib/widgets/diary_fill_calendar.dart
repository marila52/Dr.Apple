import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../theme/app_colors.dart';

/// Календарь месяца с отметками дней, когда дневник заполнен.
class DiaryFillCalendar extends StatelessWidget {
  const DiaryFillCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.filledDays,
    required this.selectedDate,
    required this.onDayTap,
  });

  final int year;
  final int month;
  final Set<int> filledDays;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заполнение дневника',
            style: AppFonts.roboto(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map(
                  (d) => Text(
                    d,
                    style: AppFonts.robotoMono(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: startWeekday - 1 + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday - 1) return const SizedBox.shrink();

              final day = index - (startWeekday - 1) + 1;
              final date = DateTime(year, month, day);
              final isSelected = selectedDate.year == year &&
                  selectedDate.month == month &&
                  selectedDate.day == day;
              final isFilled = filledDays.contains(day);

              return GestureDetector(
                onTap: () => onDayTap(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.macroPink
                        : isFilled
                            ? AppColors.macroPink.withValues(alpha: 0.35)
                            : Colors.transparent,
                    border: Border.all(
                      color: isFilled || isSelected
                          ? AppColors.macroPink
                          : AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '$day',
                    style: AppFonts.robotoMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.primaryDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
