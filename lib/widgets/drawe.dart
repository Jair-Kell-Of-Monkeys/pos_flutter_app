import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';

class MainDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();

  MainDrawer({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context); // cerrar drawer primero

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

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            child: Center(
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/dashboard'),
          ),

          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Productos'),
            onTap: () => Navigator.pushReplacementNamed(context, '/products'),
          ),

          ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: const Text('Nueva venta'),
            onTap: () => Navigator.pushReplacementNamed(context, '/sales/create'),
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Ventas'),
            onTap: () => Navigator.pushReplacementNamed(context, '/sales'),
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reportes'),
            onTap: () => Navigator.pushReplacementNamed(context, '/reports'),
          ),

          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scanner QR'),
            onTap: () => Navigator.pushReplacementNamed(context, '/scanner'),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
