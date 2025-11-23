import 'package:flutter/material.dart';
import 'package:pos_flutter_app/widgets/main_scaffold.dart';

import '../../config/theme.dart';
import '../../models/sale_model.dart';
import '../../services/sale_service.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_display_widget.dart';
import '../../widgets/loading_widget.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({Key? key}) : super(key: key);

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final SaleService _saleService = SaleService();
  List<Sale> _sales = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usar getMySalesList() que retorna List<Sale>
      final sales = await _saleService.getMySalesList();

      if (!mounted) return;

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error al cargar ventas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Mis Ventas',
      currentIndex: 0, // tab activo
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadSales,
          tooltip: 'Actualizar',
        ),
      ],
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando ventas...')
          : _errorMessage != null
          ? ErrorDisplayWidget(message: _errorMessage!, onRetry: _loadSales)
          : _sales.isEmpty
          ? const EmptyWidget(
              message: 'No tienes ventas registradas aún',
              icon: Icons.receipt_long,
            )
          : RefreshIndicator(onRefresh: _loadSales, child: _buildSalesList()),
    );
  }

  Widget _buildSalesList() {
    // Calcular total de todas las ventas
    final totalAmount = _sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalPrice,
    );
    final totalItems = _sales.fold<int>(
      0,
      (sum, sale) => sum + sale.itemsCount,
    );

    return Column(
      children: [
        // Resumen rápido
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Ventas',
                '${_sales.length}',
                Icons.shopping_cart,
              ),
              _buildSummaryItem('Productos', '$totalItems', Icons.inventory),
              _buildSummaryItem(
                'Total',
                '\$${totalAmount.toStringAsFixed(2)}',
                Icons.attach_money,
              ),
            ],
          ),
        ),

        // Lista de ventas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _sales.length,
            itemBuilder: (context, index) {
              final sale = _sales[index];
              return _buildSaleCard(sale);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showSaleDetail(sale),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Venta #${sale.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDate(sale.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${sale.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getPaymentMethodText(sale.paymentMethod),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${sale.itemsCount} ${sale.itemsCount == 1 ? 'producto' : 'productos'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(sale.date),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'efectivo':
        return 'EFECTIVO';
      case 'tarjeta':
        return 'TARJETA';
      case 'transferencia':
        return 'TRANSFER';
      default:
        return method.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSaleDetail(Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle visual
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Venta #${sale.id}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                '${_formatDate(sale.date)} a las ${_formatTime(sale.date)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const Divider(height: 30),

              // Detalles
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow(
                      'Total',
                      '\$${sale.totalPrice.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                    _buildDetailRow(
                      'Método de pago',
                      _getPaymentMethodText(sale.paymentMethod),
                    ),
                    _buildDetailRow('Productos', '${sale.itemsCount}'),

                    const SizedBox(height: 20),

                    // Botón para ver más detalles
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navegar a detalle completo cuando esté implementado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Detalle completo - Próximamente'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver detalle completo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 20 : 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppTheme.successColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
