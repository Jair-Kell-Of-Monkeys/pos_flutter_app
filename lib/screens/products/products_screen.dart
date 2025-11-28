// lib/screens/products/products_screen.dart
import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  static const Color azulClaro = Color(0xFF5DA9E9);
  static const Color azulFuerte = Color(0xFF003F91);
  static const Color verdeSuave = Color(0xFFE5F4E3);
  static const Color blanco = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blanco,
      appBar: AppBar(
        backgroundColor: azulFuerte,
        title: const Text('Productos'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search
              _searchField(),

              const SizedBox(height: 12),

              // Stats pills row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _StatPill(label: 'Total', value: '128', color: azulClaro),
                  _StatPill(label: 'Stock', value: '1,254', color: azulFuerte),
                  _StatPill(label: 'Activos', value: '118', color: verdeSuave),
                ],
              ),

              const SizedBox(height: 14),

              // Scan / button area
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: azulClaro, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        // aquí puedes abrir pantalla scanner
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrir escáner (no implementado)')));
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Escanear producto'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Catalogo productos (scrollable)
              Expanded(child: _productCatalog()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar productos...', border: InputBorder.none),
      ),
    );
  }

  Widget _productCatalog() {
    final products = [
      {'name': 'Camiseta Playa', 'code': 'PR-0001', 'stock': 25},
      {'name': 'Gorro Verano', 'code': 'PR-0002', 'stock': 64},
      {'name': 'Protector Solar', 'code': 'PR-0003', 'stock': 10},
      {'name': 'Sandalias', 'code': 'PR-0004', 'stock': 8},
      {'name': 'Toalla Playera', 'code': 'PR-0005', 'stock': 30},
    ];

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = products[index];
        return ProductCard(
          name: p['name']!.toString(),
          code: p['code']!.toString(),
          stock: int.parse(p['stock'].toString()),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abrir producto: ${p['name']}')));
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String code;
  final int stock;
  final VoidCallback onTap;
  const ProductCard({Key? key, required this.name, required this.code, required this.stock, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF5DA9E9).withOpacity(0.18), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Color(0xFF003F91))),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(code),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Stock'), Text(stock.toString(), style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}

// ---------- StatPill ----------
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill({Key? key, required this.label, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.8))),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
