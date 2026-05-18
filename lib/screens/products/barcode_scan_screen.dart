import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dr_apple/theme/app_fonts.dart';

import '../../models/product_model.dart';
import '../../services/open_food_facts_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_header.dart';
import '../../widgets/spiral_loader.dart';
import 'product_detail_screen.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({
    super.key,
    required this.mealType,
    required this.selectedDate,
  });

  final String mealType;
  final DateTime selectedDate;

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final OpenFoodFactsService _api = OpenFoodFactsService();
  bool _processing = false;
  bool _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _processing = true;
      _handled = true;
    });

    final product = await _api.getProductByBarcode(code);

    if (!mounted) return;

    if (product == null) {
      setState(() {
        _processing = false;
        _handled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Продукт по штрих-коду не найден')),
      );
      return;
    }

    final added = await Navigator.pushReplacement<bool?, bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          mealType: widget.mealType,
          selectedDate: widget.selectedDate,
        ),
      ),
    );

    if (added == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppBackHeader(title: 'Сканер штрих-кода'),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MobileScanner(onDetect: _onDetect),
                  ),
                  if (_processing)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: SpiralLoader(size: 56)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Наведите камеру на штрих-код упаковки',
                textAlign: TextAlign.center,
                style: AppFonts.roboto(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
