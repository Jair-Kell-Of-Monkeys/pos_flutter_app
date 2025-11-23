import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/cart_item.dart';
import '../services/sale_service.dart';

class CartController extends ChangeNotifier {
  final SaleService _saleService;

  CartController(this._saleService);

  // Estado interno
  final List<CartItem> _items = [];
  bool _isValidating = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastValidationResult;

  // Método de pago y notas
  String _paymentMethod = 'efectivo';
  String? _notes;

  // ========= Getters públicos =========

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isValidating => _isValidating;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastValidationResult => _lastValidationResult;

  String get paymentMethod => _paymentMethod;
  String? get notes => _notes;

  bool get isEmpty => _items.isEmpty;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(
        0.0,
        (sum, item) => sum + item.subtotal,
      );

  // ========= Setters / helpers =========

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotes(String? value) {
    _notes = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearValidationResult() {
    _lastValidationResult = null;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _errorMessage = null;
    _lastValidationResult = null;
    _paymentMethod = 'efectivo';
    _notes = null;
    notifyListeners();
  }

  // ========= Gestión del carrito =========

  void addProduct(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
        ),
      );
    }

    _lastValidationResult = null; // invalidamos validación previa
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.removeWhere((i) => i.product.id == item.product.id);
    _lastValidationResult = null;
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeItem(item);
      return;
    }

    final index = _items.indexWhere((i) => i.product.id == item.product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _lastValidationResult = null;
      notifyListeners();
    }
  }

  // ========= Helpers internos =========

  List<Map<String, dynamic>> _toBackendItems() {
    return _items
        .map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            })
        .toList();
  }

  // ========= Validación (opcional) =========

  Future<Map<String, dynamic>> validateCart() async {
    if (_items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    _isValidating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final itemsPayload = _toBackendItems();
      // aquí podrías usar SaleService.validateProducts o ProductService.validateProducts,
      // pero como ya lo tienes duplicado en SaleService, usamos ese.
      final result = await _saleService.validateProducts(itemsPayload);

      _lastValidationResult = result;
      _isValidating = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isValidating = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ========= Checkout (crear venta) =========

  Future<Sale> checkout({bool validateBefore = true}) async {
    if (_items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (validateBefore) {
        await validateCart();
      }

      final itemsPayload = _toBackendItems();

      final sale = await _saleService.createFromScan(
        items: itemsPayload,
        paymentMethod: _paymentMethod,
        notes: _notes,
      );

      clearCart();
      _isSubmitting = false;
      notifyListeners();

      return sale;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
