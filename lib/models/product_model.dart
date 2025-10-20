class Product {
  final int id;
  final String code;
  final String name;
  final String? category;
  final double price;
  final int stock;
  final String stockStatus;
  final bool available;
  final String? qrCodeUrl;
  final String? barcodeUrl;
  final String? qrCodePath;
  final String? barcodePath;
  final int userId;
  final ProductOwner? owner;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.code,
    required this.name,
    this.category,
    required this.price,
    required this.stock,
    required this.stockStatus,
    required this.available,
    this.qrCodeUrl,
    this.barcodeUrl,
    this.qrCodePath,
    this.barcodePath,
    required this.userId,
    this.owner,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'],
      category: json['category'],
      price: _parseDouble(json['price']),
      stock: json['stock'] ?? 0,
      stockStatus: json['stock_status'] ?? 'available',
      available: json['available'] ?? true,
      qrCodeUrl: json['qr_code_url'],
      barcodeUrl: json['barcode_url'],
      qrCodePath: json['qr_code_path'],
      barcodePath: json['barcode_path'],
      userId: json['user_id'] ?? json['user']?['id'] ?? 0,
      owner: json['user'] != null ? ProductOwner.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'stock_status': stockStatus,
      'available': available,
      'qr_code_url': qrCodeUrl,
      'barcode_url': barcodeUrl,
      'qr_code_path': qrCodePath,
      'barcode_path': barcodePath,
      'user_id': userId,
      'owner': owner?.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper para parsear precio (puede venir como string o double)
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Getters útiles
  bool get isCriticalStock => stock <= 5;
  bool get isLowStock => stock > 5 && stock <= 10;
  bool get isAvailable => stock > 0;

  String get stockStatusText {
    switch (stockStatus) {
      case 'available':
        return 'Disponible';
      case 'low':
        return 'Stock Bajo';
      case 'out_of_stock':
        return 'Agotado';
      default:
        return 'Desconocido';
    }
  }

  // Copiar con modificaciones
  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? stockStatus,
    bool? available,
    String? qrCodeUrl,
    String? barcodeUrl,
    String? qrCodePath,
    String? barcodePath,
    int? userId,
    ProductOwner? owner,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      stockStatus: stockStatus ?? this.stockStatus,
      available: available ?? this.available,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      barcodeUrl: barcodeUrl ?? this.barcodeUrl,
      qrCodePath: qrCodePath ?? this.qrCodePath,
      barcodePath: barcodePath ?? this.barcodePath,
      userId: userId ?? this.userId,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProductOwner {
  final int id;
  final String username;

  ProductOwner({
    required this.id,
    required this.username,
  });

  factory ProductOwner.fromJson(Map<String, dynamic> json) {
    return ProductOwner(
      id: json['id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}