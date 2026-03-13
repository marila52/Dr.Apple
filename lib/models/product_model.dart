class Product {
  final String id;
  final String name;
  final String? brand;
  final double calories;      // на 100г
  final double proteins;      // на 100г
  final double fats;          // на 100г
  final double carbs;         // на 100г
  final double? fiber;        // на 100г (опционально)
  final String? barcode;      // штрихкод
  final String? imageUrl;
  final bool isCustom;        // свой продукт или из OpenFoodFacts
  final String? userId;       // для своих продуктов
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.brand,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.fiber,
    this.barcode,
    this.imageUrl,
    required this.isCustom,
    this.userId,
    required this.createdAt,
  });

  // Создание из JSON (из Firestore или SQLite)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
      barcode: json['barcode'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isCustom: json['isCustom'] == 1,  // ← int → bool
      userId: json['userId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Преобразование в JSON
  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'brand': brand,
    'calories': calories,
    'proteins': proteins,
    'fats': fats,
    'carbs': carbs,
    'fiber': fiber,
    'barcode': barcode,
    'imageUrl': imageUrl,
    'isCustom': isCustom ? 1 : 0,  // ← bool → int (1/0)
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
  };
}

  // Создание из данных Open Food Facts
  factory Product.fromOpenFoodFacts(Map<String, dynamic> json) {
    final productData = json['product'] ?? json;
    
    return Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: productData['product_name'] ?? 'Unknown',
      brand: productData['brands'],
      calories: _extractNutrient(productData, 'energy-kcal_100g') ?? 0,
      proteins: _extractNutrient(productData, 'proteins_100g') ?? 0,
      fats: _extractNutrient(productData, 'fat_100g') ?? 0,
      carbs: _extractNutrient(productData, 'carbohydrates_100g') ?? 0,
      fiber: _extractNutrient(productData, 'fiber_100g'),
      barcode: productData['code'],
      imageUrl: productData['image_url'],
      isCustom: false,
      userId: null,
      createdAt: DateTime.now(),
    );
  }

  static double? _extractNutrient(Map<String, dynamic> data, String key) {
    if (data[key] == null) return null;
    if (data[key] is int) return (data[key] as int).toDouble();
    if (data[key] is double) return data[key] as double;
    if (data[key] is String) return double.tryParse(data[key] as String);
    return null;
  }
}