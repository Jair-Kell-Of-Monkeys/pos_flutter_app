import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Paleta de colores
    const Color azulClaro = Color(0xFF5DA9E9);
    const Color azulFuerte = Color.fromARGB(255, 1, 96, 221);
    const Color verdeSuave = Color(0xFFE5F4E3);
    const Color blanco = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: blanco,
      appBar: AppBar(
        backgroundColor: azulFuerte,
        elevation: 0,
        title: const Text(
          "Reportes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Título principal
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Panel de Reportes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003F91),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta principal de Reportes
            _reportCard(
              title: "Ventas del Día",
              subtitle: "Resumen de ventas hoy",
              icon: Icons.calendar_today,
              color: azulClaro,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _reportCard(
              title: "Ventas del Mes",
              subtitle: "Resumen mensual",
              icon: Icons.bar_chart,
              color: azulFuerte,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _reportCard(
              title: "Inventario",
              subtitle: "Existencias actuales",
              icon: Icons.inventory,
              color: verdeSuave,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _reportCard(
              title: "Productos más vendidos",
              subtitle: "Ranking del día",
              icon: Icons.trending_up,
              color: azulClaro,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Widget para cada tarjeta
  Widget _reportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
