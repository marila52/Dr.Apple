import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'database/product_dao.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  final ProductDao _productDao = ProductDao();

  // Поиск продукта по штрихкоду
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      print('🔍 Ищем продукт по штрихкоду: $barcode');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1) { // продукт найден
          print('✅ Продукт найден!');
          final product = Product.fromOpenFoodFacts(data);
          
          // Сохраняем в локальную БД
          await _productDao.insertProduct(product);
          print('💾 Продукт сохранен в БД: ${product.name}');
          
          return product;
        } else {
          print('❌ Продукт с таким штрихкодом не найден');
          return null;
        }
      } else {
        print('❌ Ошибка HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка при запросе: $e');
      return null;
    }
  }

  // Поиск продуктов по названию
  Future<List<Product>> searchProducts(String query, {int pageSize = 20}) async {
    try {
      print('🔍 Ищем продукты по названию: "$query"');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/search?search_terms=$query&page_size=$pageSize'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        
        print('✅ Найдено ${productsJson.length} продуктов');
        
        List<Product> products = [];
        for (var item in productsJson) {
          final product = Product.fromOpenFoodFacts({'product': item});
          products.add(product);
          
          // Сохраняем каждый найденный продукт в БД
          await _productDao.insertProduct(product);
        }
        
        print('💾 Сохранено ${products.length} продуктов в БД');
        return products;
      } else {
        print('❌ Ошибка HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Ошибка при запросе: $e');
      return [];
    }
  }

  // Получить популярные продукты (для примера)
  Future<List<Product>> getPopularProducts() async {
    return searchProducts('', pageSize: 10);
  }

  // Поиск по категории
  Future<List<Product>> getProductsByCategory(String category, {int pageSize = 20}) async {
    try {
      print('🔍 Ищем продукты в категории: $category');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/search?categories_tags=$category&page_size=$pageSize'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        
        print('✅ Найдено ${productsJson.length} продуктов в категории $category');
        
        List<Product> products = [];
        for (var item in productsJson) {
          products.add(Product.fromOpenFoodFacts({'product': item}));
        }
        
        return products;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Ошибка: $e');
      return [];
    }
  }
}