import 'product_model.dart';
import 'user_model.dart';
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

class SaleItem {
  final int id;
  final ProductBasic product;
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
      id: _parseInt(json['id']),
      product: ProductBasic.fromJson(json['product'] ?? {}),
      quantity: _parseInt(json['quantity']),
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

  @override
  String toString() => 'SaleItem(product: ${product.name}, qty: $quantity, subtotal: \$$subtotal)';
}

// ==========================================
// SALE
// ==========================================

class Sale {
  final int id;
  final DateTime date;
  final double totalPrice;
  final String paymentMethod;
  final UserBasic user;
  final List<SaleItem> items;
  final bool isCancelled;

  Sale({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.paymentMethod,
    required this.user,
    required this.items,
    this.isCancelled = false,
  });

  /// Cantidad total de items en la venta
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: _parseInt(json['id']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      totalPrice: _parseDouble(json['total_price']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      user: UserBasic.fromJson(json['user'] ?? {}),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      isCancelled: _parseBool(json['is_cancelled']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'user': user.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'is_cancelled': isCancelled,
    };
  }

  @override
  String toString() => 'Sale(id: $id, total: \$$totalPrice, items: ${items.length})';
}

// ==========================================
// REQUEST MODELS (para enviar datos al backend)
// ==========================================

class CreateSaleRequest {
  final List<SaleItemRequest> items;
  final String paymentMethod;
  final String? notes;

  CreateSaleRequest({
    required this.items,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'payment_method': paymentMethod,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class SaleItemRequest {
  final int productId;
  final int quantity;

  SaleItemRequest({
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