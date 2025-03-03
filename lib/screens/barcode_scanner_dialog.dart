import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  @override
  BarcodeScannerDialogState createState() => BarcodeScannerDialogState();
}

class BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  MobileScannerController controller = MobileScannerController();
  String? scannedBarcode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Scan Barcode"),
      content: SizedBox(
        width: 300,
        height: 400,
        child: MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              scannedBarcode = barcodes.first.rawValue ?? "Unknown";
              controller.stop();
              if (mounted) {
                Navigator.pop(context, scannedBarcode);
              }
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            controller.stop();
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
