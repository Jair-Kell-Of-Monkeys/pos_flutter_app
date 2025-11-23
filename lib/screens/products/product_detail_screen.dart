import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/loading_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await _productService.getProductById(widget.productId);
      
      if (!mounted) return;
      
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Error al cargar producto: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
      ),
       body: _isLoading
          ? const LoadingWidget(message: 'Cargando producto...')
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: AppTheme.bodyLarge),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadProduct,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildProductDetail(),
    );
  }

  Widget _buildProductDetail() {
    if (_product == null) {
      return const Center(child: Text('Producto no encontrado'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del producto
          Text(
            _product!.name,
            style: AppTheme.heading1,
          ),
          const SizedBox(height: 8),
          
          // Código
          Text(
            'Código: ${_product!.code}',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Precio y Stock
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Precio',
                  '\${_product!.price.toStringAsFixed(2)}',
                  Icons.attach_money,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Stock',
                  '${_product!.stock}',
                  Icons.inventory_2,
                  _getStockColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Descripción
          if (_product!.description != null) ...[
            const Text('Descripción', style: AppTheme.heading3),
            const SizedBox(height: 8),
            Text(
              _product!.description!,
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
          
          // Categoría
          if (_product!.category != null) ...[
            const Text('Categoría', style: AppTheme.heading3),
            const SizedBox(height: 8),
            Chip(
              label: Text(_product!.category!),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.caption,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.heading2.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Color _getStockColor() {
    if (_product!.isOutOfStock) return AppTheme.errorColor;
    if (_product!.isLowStock) return AppTheme.warningColor;
    return AppTheme.successColor;
  }
}