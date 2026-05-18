import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_search_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_header.dart';
import '../../widgets/spiral_loader.dart';
import 'barcode_scan_screen.dart';
import 'create_product_screen.dart';
import 'product_detail_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({
    super.key,
    required this.mealType,
    required this.selectedDate,
  });

  final String mealType;
  final DateTime selectedDate;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final ProductSearchService _searchService = ProductSearchService();
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;

  List<Product> _results = [];
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _lastQuery = '';
        _loading = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = trimmed;
    });

    try {
      final results = await _searchService.search(trimmed);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        if (results.isEmpty) {
          _error = 'Ничего не найдено. Попробуйте другое название или штрих-код.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Проверьте подключение к интернету';
        _loading = false;
      });
    }
  }

  Future<void> _openBarcode() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BarcodeScanScreen(
          mealType: widget.mealType,
          selectedDate: widget.selectedDate,
        ),
      ),
    );
    if (added == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _openProduct(Product product) async {
    final added = await Navigator.push<bool>(
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
    final userId = context.read<CustomAuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBackHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Что съели сегодня?',
                style: AppFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      focusNode: _searchFocus,
                      autofocus: true,
                      onChanged: _onQueryChanged,
                      onSubmitted: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Введите название продукта',
                        hintStyle: AppFonts.roboto(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, color: AppColors.borderLight),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _openBarcode,
                    icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                    tooltip: 'Сканировать штрих-код',
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  _error!,
                  style: AppFonts.roboto(fontSize: 13, color: Colors.orange.shade800),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final created = await Navigator.push<Product>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateProductScreen(userId: userId ?? ''),
                    ),
                  );
                  if (created != null) _openProduct(created);
                },
                child: Text(
                  '+ Свой продукт',
                  style: AppFonts.roboto(color: AppColors.primary),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: SpiralLoader(size: 48))
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _lastQuery.isEmpty
                                ? 'Начните вводить название продукта'
                                : 'Ничего не найдено',
                            style: AppFonts.roboto(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 0),
                          itemBuilder: (context, index) {
                            final product = _results[index];
                            return Material(
                              color: AppColors.white,
                              child: InkWell(
                                onTap: () => _openProduct(product),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppColors.border, width: 0.8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: AppFonts.roboto(
                                            fontSize: 15,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${product.calories.round()} ккал/100г',
                                        style: AppFonts.robotoMono(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
