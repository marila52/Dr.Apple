import '../models/product_model.dart';
import 'database/product_dao.dart';
import 'open_food_facts_service.dart';

class ProductSearchService {
  final ProductDao _productDao = ProductDao();
  final OpenFoodFactsService _api = OpenFoodFactsService();

  Future<List<Product>> search(String query, {int limit = 25}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      // Если запрос пустой, возвращаем локальные продукты
      final local = await _productDao.getAllProducts();
      return local.take(limit).toList();
    }

    // Сначала ищем в OpenFoodFacts (API)
    try {
      final remote = await _api.searchProducts(trimmed, pageSize: limit);
      if (remote.isNotEmpty) {
        // Сохраняем найденные продукты в локальную БД
        for (final product in remote) {
          await _productDao.insertProduct(product);
        }
        return remote;
      }
    } catch (e) {
      print('Ошибка поиска в API: $e');
    }

    // Если API не вернул результаты, ищем в локальной БД
    final local = await _productDao.searchProducts(trimmed);
    return local.take(limit).toList();
  }
}