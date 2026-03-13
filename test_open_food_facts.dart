import 'package:dr_apple/services/open_food_facts_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Инициализация SQLite для Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  print('🧪 ТЕСТИРУЕМ OPEN FOOD FACTS API\n');
  
  final service = OpenFoodFactsService();
  
  // Тест 1: Поиск по штрихкоду
  print('📱 ТЕСТ 1: Поиск по штрихкоду');
  print('----------------------------------------');
  final product = await service.getProductByBarcode('3017620422003');
  if (product != null) {
    print('✅ Название: ${product.name}');
    print('   Калории: ${product.calories} ккал');
    print('   Белки: ${product.proteins} г');
    print('   Жиры: ${product.fats} г');
    print('   Углеводы: ${product.carbs} г');
  } else {
    print('❌ Продукт не найден');
  }
  
  print('\n📱 ТЕСТ 2: Поиск по названию');
  print('----------------------------------------');
  final products = await service.searchProducts('milk', pageSize: 5);
  print('✅ Найдено ${products.length} продуктов');
  for (int i = 0; i < products.length; i++) {
    print('${i+1}. ${products[i].name}');
    print('   Бренд: ${products[i].brand ?? "не указан"}');
    print('   КБЖУ: ${products[i].calories}/${products[i].proteins}/${products[i].fats}/${products[i].carbs}');
  }
  
  print('\n📱 ТЕСТ 3: Поиск по категории');
  print('----------------------------------------');
  final categoryProducts = await service.getProductsByCategory('pizza', pageSize: 3);
  print('✅ Найдено ${categoryProducts.length} продуктов в категории pizza');
  for (var p in categoryProducts) {
    print('🍕 ${p.name}');
  }
  
  print('\n✅ ТЕСТИРОВАНИЕ ЗАВЕРШЕНО');
}