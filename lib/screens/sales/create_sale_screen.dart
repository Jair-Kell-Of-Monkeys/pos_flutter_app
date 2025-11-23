import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/sale_service.dart';
import '../../config/theme.dart';
import '../../widgets/main_scaffold.dart';

class QuickSaleScreen extends StatelessWidget {
  const QuickSaleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartController(SaleService()),
      child: const _QuickSaleView(),
    );
  }
}

class _QuickSaleView extends StatefulWidget {
  const _QuickSaleView({Key? key}) : super(key: key);

  @override
  State<_QuickSaleView> createState() => _QuickSaleViewState();
}

class _QuickSaleViewState extends State<_QuickSaleView> {
  final _searchController = TextEditingController();
  final _productService = ProductService();

  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.length < 2) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final results = await _productService.quickSearch(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en búsqueda: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _handleScan(String code) async {
    final cart = context.read<CartController>();

    try {
      final product = await _productService.scanProduct(code);
      cart.addProduct(product);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} agregado al carrito'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al escanear producto: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleCheckout() async {
    final cart = context.read<CartController>();

    try {
      final sale = await cart.checkout();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Venta ${sale.id} creada. Total: \$${sale.totalPrice}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear venta: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return MainScaffold(
      title: 'Venta rápida',
      currentIndex: 2, // índice "Nueva Venta"
      body: _buildContent(context, cart),
    );
  }

  Widget _buildContent(BuildContext context, CartController cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppTheme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO
              Text('Crear venta', style: AppTheme.heading2),
              const SizedBox(height: 4),
              Text(
                'Escanea o busca productos para agregarlos al carrito',
                style: AppTheme.caption,
              ),
              const SizedBox(height: 16),

              // --- Búsqueda / escaneo ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar producto o código',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _handleSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Buscar',
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    onPressed: _isSearching ? null : _handleSearch,
                  ),
                  IconButton(
                    tooltip: 'Escanear código',
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.accentColor,
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      final code = _searchController.text.trim();
                      if (code.isNotEmpty) {
                        _handleScan(code);
                      }
                      // En producción, aquí llamarías al escáner real.
                    },
                  ),
                ],
              ),

              // --- Resultados de búsqueda ---
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Resultados', style: AppTheme.heading3),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final p = _searchResults[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(p.name, style: AppTheme.bodyMedium),
                          subtitle: Text(
                            'Stock: ${p.stock} • \$${p.price.toStringAsFixed(2)}',
                            style: AppTheme.caption,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            color: AppTheme.primaryColor,
                            onPressed: () {
                              cart.addProduct(p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${p.name} agregado al carrito',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 8),

              // --- Título carrito ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Carrito', style: AppTheme.heading3),
                  Text(
                    '${cart.totalItems} artículo(s)',
                    style: AppTheme.caption,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- Lista del carrito ---
              if (cart.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Aún no hay productos en el carrito',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      elevation: 0,
                      color: AppTheme.surfaceColor,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          item.product.name,
                          style: AppTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          'Cant: ${item.quantity} • \$${item.product.price.toStringAsFixed(2)} c/u',
                          style: AppTheme.caption,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => cart.removeItem(item),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Quitar'),
                            ),
                          ],
                        ),
                        onTap: () {
                          final controller = TextEditingController(
                            text: item.quantity.toString(),
                          );
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Cambiar cantidad'),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Cantidad',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final q =
                                        int.tryParse(controller.text) ??
                                            item.quantity;
                                    cart.updateQuantity(item, q);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Guardar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 8),

              // --- Total + botón confirmar ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: AppTheme.heading3),
                  Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: cart.isSubmitting || cart.isEmpty
                      ? null
                      : _handleCheckout,
                  icon: cart.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Confirmar venta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
