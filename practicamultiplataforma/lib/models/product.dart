// lib/models/product.dart

class ProductFields {
  static const List<String> values = [
    id,
    name,
    description,
    price,
    stock,
    category,
    imageIcon,
    size,
    color,
    isFavorite,
    createdTime,
  ];

  static const String tableName = 'products';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String realType = 'REAL NOT NULL';
  
  static const String id = '_id';
  static const String name = 'name';
  static const String description = 'description';
  static const String price = 'price';
  static const String stock = 'stock';
  static const String category = 'category';
  static const String imageIcon = 'image_icon';
  static const String size = 'size';
  static const String color = 'color';
  static const String isFavorite = 'is_favorite';
  static const String createdTime = 'created_time';
}

class Product {
  int? id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageIcon;
  final String size;
  final String color;
  final bool isFavorite;
  final DateTime? createdTime;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageIcon = '👕',
    this.size = 'M',
    this.color = 'Black',
    this.isFavorite = false,
    this.createdTime,
  });

  Map<String, Object?> toJson() => {
        ProductFields.id: id,
        ProductFields.name: name,
        ProductFields.description: description,
        ProductFields.price: price,
        ProductFields.stock: stock,
        ProductFields.category: category,
        ProductFields.imageIcon: imageIcon,
        ProductFields.size: size,
        ProductFields.color: color,
        ProductFields.isFavorite: isFavorite ? 1 : 0,
        ProductFields.createdTime: createdTime?.toIso8601String(),
      };

  factory Product.fromJson(Map<String, Object?> json) => Product(
        id: json[ProductFields.id] as int?,
        name: json[ProductFields.name] as String,
        description: json[ProductFields.description] as String,
        price: json[ProductFields.price] as double,
        stock: json[ProductFields.stock] as int,
        category: json[ProductFields.category] as String,
        imageIcon: json[ProductFields.imageIcon] as String? ?? '👕',
        size: json[ProductFields.size] as String? ?? 'M',
        color: json[ProductFields.color] as String? ?? 'Black',
        isFavorite: json[ProductFields.isFavorite] == 1,
        createdTime: DateTime.tryParse(
            json[ProductFields.createdTime] as String? ?? ''),
      );

  Product copy({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imageIcon,
    String? size,
    String? color,
    bool? isFavorite,
    DateTime? createdTime,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        stock: stock ?? this.stock,
        category: category ?? this.category,
        imageIcon: imageIcon ?? this.imageIcon,
        size: size ?? this.size,
        color: color ?? this.color,
        isFavorite: isFavorite ?? this.isFavorite,
        createdTime: createdTime ?? this.createdTime,
      );
}