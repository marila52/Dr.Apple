import '../models/product_model.dart';
import 'database/product_dao.dart';
import 'open_food_facts_service.dart';

class ProductSearchService {
  final ProductDao _productDao = ProductDao();
  final OpenFoodFactsService _api = OpenFoodFactsService();

  Future<List<Product>> search(String query, {int limit = 25}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _productDao.getAllProducts().then((list) => list.take(limit).toList());
    }

    final local = await _productDao.searchProducts(trimmed);
    if (local.length >= limit) {
      return local.take(limit).toList();
    }

    try {
      final remote = await _api.searchProducts(trimmed, pageSize: limit);
      final merged = <String, Product>{};
      for (final p in [...local, ...remote]) {
        merged[p.id] = p;
      }
      return merged.values.take(limit).toList();
    } catch (_) {
      return local;
    }
  }
}
