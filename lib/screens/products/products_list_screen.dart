import 'package:flutter/material.dart';
import 'package:pos_flutter_app/widgets/main_scaffold.dart';

import '../../config/theme.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_display_widget.dart';
import '../../widgets/loading_widget.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error al cargar productos: $e';
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredProducts = _products
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.code.toLowerCase().contains(query.toLowerCase()) ||
                (product.category?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    });
  }

  Future<void> _performQuickSearch(String query) async {
    if (query.length < 2) {
      _filterProducts(query);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _productService.quickSearch(query);

      if (!mounted) return;

      setState(() {
        _filteredProducts = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
      });

      // Fallback a búsqueda local
      _filterProducts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Productos',
      currentIndex: 0, // tab activo
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () {
            // TODO: Implementar escáner cuando esté listo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Escáner - Próximamente')),
            );
          },
          tooltip: 'Escanear producto',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadProducts,
          tooltip: 'Actualizar',
        ),
      ],
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, código o categoría...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterProducts,
            ),
          ),

          // Resumen rápido
          if (!_isLoading && _errorMessage == null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSearching || _searchController.text.isNotEmpty
                        ? '${_filteredProducts.length} ${_filteredProducts.length == 1 ? 'resultado' : 'resultados'}'
                        : '${_products.length} ${_products.length == 1 ? 'producto' : 'productos'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_products.isNotEmpty) ...[
                    Row(children: [_buildStockIndicator()]),
                  ],
                ],
              ),
            ),
          ],

          // Lista de productos
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Cargando productos...')
                : _errorMessage != null
                ? ErrorDisplayWidget(
                    message: _errorMessage!,
                    onRetry: _loadProducts,
                  )
                : _filteredProducts.isEmpty
                ? EmptyWidget(
                    message: _searchController.text.isNotEmpty
                        ? 'No se encontraron productos con "${_searchController.text}"'
                        : 'No hay productos disponibles',
                    icon: Icons.inventory_2_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator() {
    final lowStock = _products.where((p) => p.isLowStock).length;
    final outOfStock = _products.where((p) => p.isOutOfStock).length;

    if (lowStock == 0 && outOfStock == 0) {
      return const Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
          SizedBox(width: 4),
          Text(
            'Stock OK',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.successColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (outOfStock > 0) ...[
          const Icon(Icons.warning, size: 16, color: AppTheme.errorColor),
          const SizedBox(width: 4),
          Text(
            '$outOfStock sin stock',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (lowStock > 0 && outOfStock > 0) ...[
          const SizedBox(width: 8),
          Text('•', style: TextStyle(color: Colors.grey[400])),
          const SizedBox(width: 8),
        ],
        if (lowStock > 0) ...[
          const Icon(Icons.warning, size: 16, color: AppTheme.warningColor),
          const SizedBox(width: 4),
          Text(
            '$lowStock stock bajo',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.warningColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.pushNamed(context, '/products/detail', arguments: product.id);
      },
      child: Row(
        children: [
          // Indicador de stock con color
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
              color: _getStockColor(product),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Código: ${product.code}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStockColor(product).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 14,
                            color: _getStockColor(product),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStockColor(product),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (product.category != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Precio
          const SizedBox(width: 12),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(Product product) {
    if (product.isOutOfStock) return AppTheme.errorColor;
    if (product.isLowStock) return AppTheme.warningColor;
    return AppTheme.successColor;
  }
}
