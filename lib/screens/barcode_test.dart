import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeTestScreen extends StatefulWidget {
  const BarcodeTestScreen({super.key});

  @override
  BarcodeTestScreenState createState() => BarcodeTestScreenState();
}

class BarcodeTestScreenState extends State<BarcodeTestScreen> {
  String _barcode = "Not scanned yet";
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Barcode Test")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() {
                    _barcode = barcodes.first.rawValue ?? "Unknown";
                  });
                }
              },
            ),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: Text(_barcode)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.toggleTorch(),
        child: const Icon(Icons.flash_on),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
