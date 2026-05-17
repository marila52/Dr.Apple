import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/diary_entry_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database/favorites_dao.dart';
import '../../services/diary_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_header.dart';
import '../../widgets/spiral_loader.dart';

enum PortionUnit { grams, ml, portion }

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.mealType,
    required this.selectedDate,
  });

  final Product product;
  final String mealType;
  final DateTime selectedDate;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _weightController = TextEditingController(text: '100');
  final DiaryService _diaryService = DiaryService();
  final FavoritesDao _favoritesDao = FavoritesDao();

  PortionUnit _unit = PortionUnit.grams;
  bool _isFavorite = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final userId = context.read<CustomAuthProvider>().user?.uid;
    if (userId == null) return;
    final fav = await _favoritesDao.isFavorite(userId, widget.product.id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  double get _grams {
    final value = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0;
    if (_unit == PortionUnit.portion) return value * 100;
    return value;
  }

  double _scaled(double per100) => (per100 * _grams) / 100;

  Future<void> _toggleFavorite() async {
    final userId = context.read<CustomAuthProvider>().user?.uid;
    if (userId == null) return;

    if (_isFavorite) {
      await _favoritesDao.remove(userId, widget.product.id);
    } else {
      await _favoritesDao.add(userId, widget.product.id);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _addToDiary() async {
    final userId = context.read<CustomAuthProvider>().user?.uid;
    if (userId == null) return;

    final grams = _grams;
    if (grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите корректный вес порции')),
      );
      return;
    }

    setState(() => _saving = true);

    final entry = DiaryEntry.fromProduct(
      userId: userId,
      product: widget.product,
      quantity: grams,
      mealType: widget.mealType,
      dateTime: DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
    );

    await _diaryService.addEntry(entry);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBackHeader(
              trailing: IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.spiralPink,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: AppFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (p.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        p.brand!,
                        style: AppFonts.roboto(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Введите вес продукта',
                              filled: true,
                              fillColor: AppColors.cardFill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _UnitDropdown(
                          value: _unit,
                          onChanged: (u) => setState(() => _unit = u),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _infoHeader(),
                    const SizedBox(height: 8),
                    _nutritionCard(p),
                    const SizedBox(height: 16),
                    Text(
                      'На выбранную порцию: ${_scaled(p.calories).round()} ккал',
                      style: AppFonts.robotoMono(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _addToDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSage,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _saving
                      ? const SpiralLoader(size: 28)
                      : Text(
                          'Добавить в дневник',
                          style: AppFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            'Информация о продукте',
            style: AppFonts.roboto(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const Spacer(),
          Text(
            'на 100 грамм',
            style: AppFonts.roboto(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _nutritionCard(Product p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _nutrientRow('Калорийность', '${p.calories.round()} ккал'),
          _nutrientRow('Белки', '${p.proteins.toStringAsFixed(1)} гр.'),
          _nutrientRow('Жиры', '${p.fats.toStringAsFixed(1)} гр.'),
          _nutrientRow('Углеводы', '${p.carbs.toStringAsFixed(1)} гр.'),
        ],
      ),
    );
  }

  Widget _nutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppFonts.roboto(color: AppColors.primaryDark)),
          ),
          Text(
            value,
            style: AppFonts.robotoMono(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({required this.value, required this.onChanged});

  final PortionUnit value;
  final ValueChanged<PortionUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PortionUnit>(
      initialValue: value,
      onSelected: onChanged,
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFFFF9F2),
      itemBuilder: (_) => [
        _item(PortionUnit.grams, 'гр.'),
        _item(PortionUnit.ml, 'мл.'),
        _item(PortionUnit.portion, 'порция'),
      ],
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardFill,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value == PortionUnit.grams
                  ? 'гр.'
                  : value == PortionUnit.ml
                      ? 'мл.'
                      : 'порция',
              style: AppFonts.roboto(color: AppColors.borderLight),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.borderLight),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<PortionUnit> _item(PortionUnit unit, String label) {
    return PopupMenuItem(
      value: unit,
      child: Text(label, style: AppFonts.roboto(color: AppColors.borderLight)),
    );
  }
}
