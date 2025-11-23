import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/main_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();

  DashboardSummary? _dashboard;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dashboard = await _dashboardService.getDashboardSummary();

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error al cargar el dashboard: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    // 👇 PRIMERO cerrar el Drawer
    Navigator.pop(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();

      if (!mounted) return;

      // 👇 REGRESA AL LOGIN Y LIMPIA HISTORIAL
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
Widget build(BuildContext context) {
  return MainScaffold(
    title: 'Dashboard',
    currentIndex: 0, // tab activo
    body: _isLoading
        ? const LoadingWidget(message: 'Cargando dashboard...')
        : _errorMessage != null
            ? ErrorWidgetCustom(
                message: _errorMessage!,
                onRetry: _loadDashboard,
              )
            : RefreshIndicator(
                onRefresh: _loadDashboard,
                child: _buildDashboardContent(),
              ),
  );
}


  Widget _buildDashboardContent() {
    if (_dashboard == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUserGreeting(),
        const SizedBox(height: 24),

        _buildSalesCard(
          title: 'Ventas de Hoy',
          count: _dashboard!.todaySales.count,
          total: _dashboard!.todaySales.total,
          icon: Icons.today,
          color: AppTheme.successColor,
        ),

        _buildSalesCard(
          title: 'Ventas de la Semana',
          count: _dashboard!.weekSales.count,
          total: _dashboard!.weekSales.total,
          icon: Icons.calendar_today,
          color: AppTheme.primaryColor,
        ),

        _buildSalesCard(
          title: 'Ventas del Mes',
          count: _dashboard!.monthSales.count,
          total: _dashboard!.monthSales.total,
          icon: Icons.calendar_month,
          color: AppTheme.accentColor,
        ),

        const SizedBox(height: 24),

        if (_dashboard!.lowStock.count > 0) _buildLowStockAlert(),
        if (_dashboard!.topProducts.isNotEmpty) _buildTopProducts(),
        if (_dashboard!.recentSales.isNotEmpty) _buildRecentSales(),
      ],
    );
  }

  Widget _buildUserGreeting() {
    return CustomCard(
      color: AppTheme.primaryColor,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _dashboard!.userInfo.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Hola!',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                Text(
                  _dashboard!.userInfo.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _dashboard!.userInfo.role.role == 'admin'
                      ? 'Administrador'
                      : 'Empleado',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesCard({
    required String title,
    required int count,
    required double total,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: AppTheme.heading2.copyWith(color: color),
                ),
                Text(
                  '$count ${count == 1 ? 'venta' : 'ventas'}',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert() {
    return CustomCard(
      color: AppTheme.warningColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: AppTheme.warningColor),
              SizedBox(width: 8),
              Text(
                'Stock Bajo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_dashboard!.lowStock.count} productos con stock bajo',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Top Productos', style: AppTheme.heading3),
        ),
        ..._dashboard!.topProducts
            .take(5)
            .map(
              (product) => CustomCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vendidos: ${product.quantitySold}',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${product.totalAmount.toStringAsFixed(2)}',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildRecentSales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Ventas Recientes', style: AppTheme.heading3),
        ),
        ..._dashboard!.recentSales.map(
          (sale) => CustomCard(
            onTap: () => Navigator.pushNamed(context, '/sales'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta #${sale.id}',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sale.itemsCount} productos - ${sale.user.username}',
                        style: AppTheme.caption,
                      ),
                      Text(_formatDate(sale.date), style: AppTheme.caption),
                    ],
                  ),
                ),
                Text(
                  '\$${sale.totalPrice.toStringAsFixed(2)}',
                  style: AppTheme.heading3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ErrorWidgetCustom extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidgetCustom({Key? key, required this.message, this.onRetry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
