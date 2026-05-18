import 'product_model.dart'; // 👈 ВАЖНО: добавляем импорт Product

class DiaryEntry {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final double quantity;        // в граммах
  final DateTime dateTime;
  final String mealType;        // breakfast, lunch, dinner, snack
  
  // Рассчитанные значения (зависят от quantity)
  double get calories => _calculatePerGram(productCaloriesPer100g);
  double get proteins => _calculatePerGram(productProteinsPer100g);
  double get fats => _calculatePerGram(productFatsPer100g);
  double get carbs => _calculatePerGram(productCarbsPer100g);
  
  // Данные продукта на 100г (нужны для расчетов)
  final double productCaloriesPer100g;
  final double productProteinsPer100g;
  final double productFatsPer100g;
  final double productCarbsPer100g;
  
  // Опционально: копия данных продукта на момент записи
  final Map<String, dynamic>? productSnapshot;

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.dateTime,
    required this.mealType,
    required this.productCaloriesPer100g,
    required this.productProteinsPer100g,
    required this.productFatsPer100g,
    required this.productCarbsPer100g,
    this.productSnapshot,
  });

  double _calculatePerGram(double per100g) {
    return (per100g * quantity) / 100;
  }

  // Создание из JSON
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime'] as String),
      mealType: json['mealType'] as String,
      productCaloriesPer100g: (json['productCaloriesPer100g'] as num).toDouble(),
      productProteinsPer100g: (json['productProteinsPer100g'] as num).toDouble(),
      productFatsPer100g: (json['productFatsPer100g'] as num).toDouble(),
      productCarbsPer100g: (json['productCarbsPer100g'] as num).toDouble(),
      productSnapshot: json['productSnapshot'] as Map<String, dynamic>?,
    );
  }

  // Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'dateTime': dateTime.toIso8601String(),
      'mealType': mealType,
      'productCaloriesPer100g': productCaloriesPer100g,
      'productProteinsPer100g': productProteinsPer100g,
      'productFatsPer100g': productFatsPer100g,
      'productCarbsPer100g': productCarbsPer100g,
      'productSnapshot': productSnapshot,
    };
  }

  DiaryEntry copyWith({
    double? quantity,
    String? mealType,
    DateTime? dateTime,
    String? productName,
  }) {
    return DiaryEntry(
      id: id,
      userId: userId,
      productId: productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      dateTime: dateTime ?? this.dateTime,
      mealType: mealType ?? this.mealType,
      productCaloriesPer100g: productCaloriesPer100g,
      productProteinsPer100g: productProteinsPer100g,
      productFatsPer100g: productFatsPer100g,
      productCarbsPer100g: productCarbsPer100g,
      productSnapshot: productSnapshot,
    );
  }

  // Создание из продукта
  factory DiaryEntry.fromProduct({
    required String userId,
    required Product product,  // 👈 здесь используется Product
    required double quantity,
    required String mealType,
    DateTime? dateTime,
  }) {
    return DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      dateTime: dateTime ?? DateTime.now(),
      mealType: mealType,
      productCaloriesPer100g: product.calories,
      productProteinsPer100g: product.proteins,
      productFatsPer100g: product.fats,
      productCarbsPer100g: product.carbs,
      productSnapshot: product.toJson(),
    );
  }
}