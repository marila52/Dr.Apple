// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/product_model.dart';
// import 'database/product_dao.dart';

// class OpenFoodFactsService {
//   // Используем UK регион (иногда он работает лучше)
//   static const String _apiV2 = 'https://uk.openfoodfacts.org/api/v2';
//   static const String _searchUrl = 'https://uk.openfoodfacts.org/cgi/search.pl';

//   final ProductDao _productDao = ProductDao();

//   Future<Product?> getProductByBarcode(String barcode) async {
//     for (int attempt = 0; attempt < 3; attempt++) {
//       try {
//         final response = await http.get(
//           Uri.parse('$_apiV2/product/$barcode.json'),
//         ).timeout(const Duration(seconds: 30));

//         if (response.statusCode != 200) return null;

//         final data = json.decode(response.body) as Map<String, dynamic>;
//         if (data['status'] != 1) return null;

//         final product = Product.fromOpenFoodFacts(data);
//         await _productDao.insertProduct(product);
//         return product;
//       } catch (e) {
//         print('⚠️ Попытка ${attempt + 1}: $e');
//         if (attempt == 2) rethrow;
//         await Future.delayed(Duration(seconds: 3 + attempt * 2));
//       }
//     }
//     return null;
//   }

//   Future<List<Product>> searchProducts(String query, {int pageSize = 25}) async {
//     final trimmed = query.trim();
//     if (trimmed.isEmpty) return [];

//     for (int attempt = 0; attempt < 3; attempt++) {
//       try {
//         final uri = Uri.parse(_searchUrl).replace(
//           queryParameters: {
//             'search_terms': trimmed,
//             'search_simple': '1',
//             'action': 'process',
//             'json': '1',
//             'page_size': pageSize.toString(),
//             'fields': 'code,product_name,product_name_ru,generic_name,brands,'
//                 'energy-kcal_100g,proteins_100g,fat_100g,carbohydrates_100g,'
//                 'fiber_100g,image_url,nutriments',
//           },
//         );

//         final response = await http.get(uri).timeout(const Duration(seconds: 30));

//         if (response.statusCode != 200) return [];

//         final data = json.decode(response.body) as Map<String, dynamic>;
//         final productsJson = data['products'] as List<dynamic>? ?? [];

//         final products = <Product>[];
//         for (final item in productsJson) {
//           if (item is! Map<String, dynamic>) continue;
//           final product = Product.fromOpenFoodFacts({'product': item});
//           if (product.name.trim().isEmpty || product.name == 'Без названия') {
//             continue;
//           }
//           products.add(product);
//         }
//         return products;
//       } catch (e) {
//         print('⚠️ Попытка ${attempt + 1}: $e');
//         if (attempt == 2) rethrow;
//         await Future.delayed(Duration(seconds: 3 + attempt * 2));
//       }
//     }
//     return [];
//   }
// }