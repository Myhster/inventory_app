import 'package:flutter/material.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/models/product.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  InventoryScreenState createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final InventoryManager _manager = InventoryManager();
  late Future<List<Product>> _productsFuture;
  MobileScannerController controller = MobileScannerController();
  String _barcode = "Not scanned yet";
  bool _hasScanned = false; // Flag für einmaligen Scan

  @override
  void initState() {
    super.initState();
    _productsFuture = _manager.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          "Qty: ${product.quantity} - ${product.category}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _manager.removeProduct(product.id!);
                            setState(() {
                              _productsFuture = _manager.getProducts();
                            });
                          },
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Barcode: $_barcode"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanAndAddProduct,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> _scanAndAddProduct() async {
    _hasScanned = false; // Reset Flag
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Scan Barcode"),
            content: SizedBox(
              width: 300,
              height: 400,
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  if (!_hasScanned) {
                    // Nur einmal scannen
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      _hasScanned = true;
                      final String barcode =
                          barcodes.first.rawValue ?? "Unknown";
                      final product = Product(
                        name: "Item $barcode",
                        quantity: 1,
                        category: "Misc",
                      );
                      _manager.addProduct(product).then((_) {
                        setState(() {
                          _productsFuture = _manager.getProducts();
                          _barcode = barcode;
                        });
                        controller.stop(); // Scanner stoppen
                        Navigator.pop(context); // Dialog schließen
                      });
                    }
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.stop(); // Scanner stoppen
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
