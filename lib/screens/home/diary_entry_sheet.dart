import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../../models/diary_entry_model.dart';
import '../../services/diary_service.dart';
import '../../theme/app_colors.dart';

class DiaryEntrySheet extends StatefulWidget {
  const DiaryEntrySheet({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final DiaryEntry entry;
  final Future<void> Function() onChanged;

  @override
  State<DiaryEntrySheet> createState() => _DiaryEntrySheetState();
}

class _DiaryEntrySheetState extends State<DiaryEntrySheet> {
  final DiaryService _diaryService = DiaryService();
  late TextEditingController _gramsController;
  late String _mealType;
  bool _busy = false;

  static const _meals = {
    'breakfast': 'Завтрак',
    'lunch': 'Обед',
    'dinner': 'Ужин',
    'snack': 'Перекус',
  };

  @override
  void initState() {
    super.initState();
    _gramsController =
        TextEditingController(text: widget.entry.quantity.toStringAsFixed(0));
    _mealType = widget.entry.mealType;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final grams = double.tryParse(_gramsController.text.replaceAll(',', '.'));
    if (grams == null || grams <= 0) return;

    setState(() => _busy = true);
    final updated = widget.entry.copyWith(quantity: grams, mealType: _mealType);
    await _diaryService.updateEntry(updated);
    await widget.onChanged();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    setState(() => _busy = true);
    await _diaryService.deleteEntry(widget.entry.id);
    await widget.onChanged();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entry.productName,
              style: AppFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.calories.round()} ккал · Б ${entry.proteins.toStringAsFixed(0)} · Ж ${entry.fats.toStringAsFixed(0)} · У ${entry.carbs.toStringAsFixed(0)}',
              style: AppFonts.robotoMono(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Вес порции (г)',
                filled: true,
                fillColor: AppColors.cardFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mealType,
              decoration: InputDecoration(
                labelText: 'Приём пищи',
                filled: true,
                fillColor: AppColors.cardFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: _meals.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _mealType = v);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _busy ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentSage,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Сохранить'),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _delete,
              child: Text(
                'Удалить из дневника',
                style: AppFonts.roboto(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
