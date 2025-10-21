/// Parse seguro de enteros desde cualquier tipo
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return int.tryParse(value.toString()) ?? 0;
}

/// Parse seguro de doubles desde cualquier tipo
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}

/// Parse seguro de booleanos
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return false;
}

class Product {
  final int id;
  final String code;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final String? qrCodeUrl;
  final String? barcodeUrl;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.category,
    this.qrCodeUrl,
    this.barcodeUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Estado del stock
  String get stockStatus {
    if (stock > 10) return 'available';
    if (stock > 0) return 'low';
    return 'out_of_stock';
  }

  bool get isAvailable => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 10;
  bool get isOutOfStock => stock == 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: _parseDouble(json['price']),
      stock: _parseInt(json['stock']),
      category: json['category']?.toString(),
      qrCodeUrl: json['qr_code_url']?.toString(),
      barcodeUrl: json['barcode_url']?.toString(),
      userId: _parseInt(json['user_id'] ?? json['user']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'qr_code_url': qrCodeUrl,
      'barcode_url': barcodeUrl,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convertir a ProductBasic para usar en ventas
  ProductBasic toBasic() {
    return ProductBasic(
      id: id,
      code: code,
      name: name,
    );
  }

  @override
  String toString() => 'Product(id: $id, code: $code, name: $name, stock: $stock)';
}

// ==========================================
// PRODUCT BASIC (para ventas)
// ==========================================

class ProductBasic {
  final int id;
  final String code;
  final String name;

  ProductBasic({
    required this.id,
    required this.code,
    required this.name,
  });

  factory ProductBasic.fromJson(Map<String, dynamic> json) {
    return ProductBasic(
      id: _parseInt(json['id']),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }

  @override
  String toString() => 'ProductBasic(id: $id, code: $code, name: $name)';
}