class Product {
  final String id;
  final String name;
  final String? brand;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final double? fiber;
  final String? barcode;
  final String? imageUrl;
  final bool isCustom;
  final String? userId;
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
      isCustom: json['isCustom'] == 1 || json['isCustom'] == true,
      userId: json['userId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

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
      'isCustom': isCustom ? 1 : 0,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromOpenFoodFacts(Map<String, dynamic> json) {
    final productData = json['product'] ?? json;
    final nutriments = productData['nutriments'] as Map<String, dynamic>?;

    final name = _firstNonEmptyString([
      productData['product_name_ru'],
      productData['product_name'],
      productData['generic_name'],
      productData['abbreviated_product_name'],
    ]);

    final code = productData['code']?.toString() ??
        productData['_id']?.toString();

    return Product(
      id: code ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name ?? 'Без названия',
      brand: productData['brands']?.toString(),
      calories: _nutrient(productData, nutriments, 'energy-kcal_100g') ?? 0,
      proteins: _nutrient(productData, nutriments, 'proteins_100g') ?? 0,
      fats: _nutrient(productData, nutriments, 'fat_100g') ?? 0,
      carbs: _nutrient(productData, nutriments, 'carbohydrates_100g') ?? 0,
      fiber: _nutrient(productData, nutriments, 'fiber_100g'),
      barcode: code,
      imageUrl: productData['image_url']?.toString(),
      isCustom: false,
      userId: null,
      createdAt: DateTime.now(),
    );
  }

  static String? _firstNonEmptyString(List<dynamic> values) {
    for (final v in values) {
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static double? _nutrient(
    Map<String, dynamic> product,
    Map<String, dynamic>? nutriments,
    String key,
  ) {
    return _parseNum(product[key]) ?? _parseNum(nutriments?[key]);
  }

  static double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
