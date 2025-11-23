import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos_flutter_app/widgets/main_scaffold.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "Escáner QR",
      currentIndex: 0, // tab activo
      body: Stack(
        children: [
          // Cámara del escáner
          MobileScanner(
            onDetect: (capture) {
              if (_isScanned) return; // evitar múltiples lecturas

              final List<Barcode> barcodes = capture.barcodes;
              final String? value = barcodes.first.rawValue;

              setState(() {
                _isScanned = true;
              });

              if (value != null) {
                Navigator.pop(
                  context,
                  value,
                ); // Regresa el valor a la pantalla anterior
              }
            },
          ),

          // Texto centrado arriba
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Apunta la cámara al código QR",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
