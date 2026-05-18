import '../models/product_model.dart';
import 'database/product_dao.dart';

class ProductSearchService {
  final ProductDao _productDao = ProductDao();

  Future<List<Product>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _productDao.getAllProducts();
    }
    return _productDao.searchProducts(trimmed);
  }
}