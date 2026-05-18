import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database/favorites_dao.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_header.dart';
import '../../widgets/spiral_loader.dart';
import '../products/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesDao _dao = FavoritesDao();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<CustomAuthProvider>().user?.uid;
    if (userId == null) return;
    final list = await _dao.getFavoriteProducts(userId);
    if (mounted) {
      setState(() {
        _products = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBackHeader(title: 'Избранное'),
            Expanded(
              child: _loading
                  ? const Center(child: SpiralLoader(size: 56))
                  : _products.isEmpty
                      ? Center(
                          child: Text(
                            'Добавляйте продукты в избранное\nна экране продукта',
                            textAlign: TextAlign.center,
                            style: AppFonts.roboto(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final p = _products[index];
                            return Material(
                              color: AppColors.cardFill,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        product: p,
                                        mealType: 'snack',
                                        selectedDate: DateTime.now(),
                                      ),
                                    ),
                                  ).then((_) => _load());
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite, color: AppColors.spiralPink, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          style: AppFonts.roboto(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${p.calories.round()} ккал',
                                        style: AppFonts.robotoMono(fontSize: 12),
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
