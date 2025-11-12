class ProductModel {
  final int id;
  final String name;
  final String category;
  final double price;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.inStock,
  });

  ProductModel copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    bool? inStock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      inStock: inStock ?? this.inStock,
    );
  }

  factory ProductModel.fromDummyJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['title'] ?? '',
      category: json['category']?.toString() ?? 'General',
      price: (json['price'] as num).toDouble(),
      inStock: (json['stock'] ?? 0) > 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': name,
    'category': category,
    'price': price,
    'stock': inStock ? 10 : 0,
  };
}
