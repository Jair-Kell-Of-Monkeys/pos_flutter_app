import 'product_model.dart';
import 'user_model.dart';

class Sale {
  final int id;
  final DateTime date;
  final double totalPrice;
  final bool isCancelled;
  final DateTime? cancelledAt;
  final User? cancelledBy;
  final User user;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.isCancelled,
    this.cancelledAt,
    this.cancelledBy,
    required this.user,
    required this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      date: DateTime.parse(json['date']),
      totalPrice: _parseDouble(json['total_price']),
      isCancelled: json['is_cancelled'] ?? false,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancelledBy: json['cancelled_by'] != null
          ? User.fromJson(json['cancelled_by'])
          : null,
      user: User.fromJson(json['user']),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total_price': totalPrice,
      'is_cancelled': isCancelled,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancelled_by': cancelledBy?.toJson(),
      'user': user.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Helper para parsear precio
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Getters útiles
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusText => isCancelled ? 'Cancelada' : 'Completada';

  // Formateo de fecha
  String get formattedDate {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get formattedTime {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class SaleItem {
  final int id;
  final Product product;
  final int quantity;
  final double price;
  final double subtotal;

  SaleItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] ?? 0,
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      price: _parseDouble(json['price']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }

  // Helper para parsear precio
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Modelo simplificado para crear ventas
class CreateSaleItem {
  final int productId;
  final int quantity;

  CreateSaleItem({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}