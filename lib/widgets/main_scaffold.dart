import 'package:flutter/material.dart';
import 'package:pos_flutter_app/config/routes.dart';

import 'drawe.dart';

class MainScaffold extends StatelessWidget {
  final String title;
  final int currentIndex; // índice activo del bottom nav
  final Widget body;
  final List<Widget>? actions;

  const MainScaffold({
    Key? key,
    required this.title,
    required this.currentIndex,
    required this.body,
    this.actions,
  }) : super(key: key);

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.products);
        break;
      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.createSale,
        ); // venta rápida
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.sales); // historial
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onNavTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Nueva Venta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Ventas',
          ),
        ],
      ),
    );
  }
}
