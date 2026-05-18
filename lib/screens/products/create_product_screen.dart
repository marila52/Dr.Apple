import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../../models/product_model.dart';
import '../../services/database/product_dao.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_header.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key, required this.userId});

  final String userId;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbController = TextEditingController();
  final _nameFocus = FocusNode();
  final ProductDao _productDao = ProductDao();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название продукта')),
      );
      return;
    }

    final product = Product(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      calories: double.tryParse(_kcalController.text) ?? 0,
      proteins: double.tryParse(_proteinController.text) ?? 0,
      fats: double.tryParse(_fatController.text) ?? 0,
      carbs: double.tryParse(_carbController.text) ?? 0,
      isCustom: true,
      userId: widget.userId,
      createdAt: DateTime.now(),
    );

    await _productDao.insertProduct(product);
    if (!mounted) return;
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppBackHeader(title: 'Создать продукт'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _field(_nameController, 'Введите название своего продукта', focus: _nameFocus),
                    const SizedBox(height: 12),
                    _field(_kcalController, 'Введите количество ккал на 100 грамм', number: true),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _field(_proteinController, 'Белки на 100 грамм', number: true)),
                        const SizedBox(width: 10),
                        Expanded(child: _field(_fatController, 'Жиры на 100 грамм', number: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field(_carbController, 'Углеводы на 100 грамм', number: true),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/image54.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSage,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'ГОТОВО',
                    style: AppFonts.roboto(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint, {
    bool number = false,
    FocusNode? focus,
  }) {
    return TextField(
      controller: c,
      focusNode: focus,
      autofocus: focus != null,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppFonts.roboto(fontSize: 13, color: AppColors.textMuted),
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
    );
  }
}
