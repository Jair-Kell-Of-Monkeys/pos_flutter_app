import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registro_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/products_list_screen.dart';
// import '../screens/products/product_detail_screen.dart';
import '../screens/sales/sales_list_screen.dart';
import '../screens/sales/create_sale_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/scanner/scanner_screen.dart';

class AppRoutes {
  // Nombres de rutas
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String sales = '/sales';
  static const String createSale = '/create-sale';
  static const String reports = '/reports';
  static const String scanner = '/scanner';

  // Mapa de rutas
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    dashboard: (context) => const DashboardScreen(),
    products: (context) => const ProductsListScreen(),
    sales: (context) => const SalesListScreen(),
    createSale: (context) => const QuickSaleScreen(),
    reports: (context) => const ReportsScreen(),
    scanner: (context) => const ScannerScreen(),
  
  };

  // Ruta inicial
  static String get initialRoute => login;

  // Generador de rutas con argumentos
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Ruta no encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${settings.name}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
