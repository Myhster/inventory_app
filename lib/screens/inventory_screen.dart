import 'package:flutter/material.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/models/product.dart';
import 'barcode_scanner_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  InventoryScreenState createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final InventoryManager _manager = InventoryManager();
  late Future<List<Product>> _productsFuture;
  String _barcode = "Not scanned yet";

  @override
  void initState() {
    super.initState();
    _productsFuture = _manager.getProducts();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => setState(() => _productsFuture = _manager.getProducts()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return const Center(child: Text("No items yet."));
                  }
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.inventory_2,
                            color: Colors.teal,
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Qty: ${product.quantity} - ${product.category}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _manager.removeProduct(product.id!);
                              if (mounted) {
                                setState(() {
                                  _productsFuture =
                                      _manager
                                          .getProducts(); // Sofort neuer Future
                                });
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink(); // Fallback
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Last Scanned: $_barcode",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addManualProduct,
            tooltip: "Add Manually",
            heroTag: "addManual",
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _scanAndAddProduct,
            tooltip: "Scan Barcode",
            heroTag: "scanBarcode",
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  Future<void> _scanAndAddProduct() async {
    final scannedBarcode = await showDialog<String>(
      context: context,
      builder: (context) => const BarcodeScannerDialog(),
    );

    if (scannedBarcode != null && mounted) {
      String name = "Item $scannedBarcode";
      String category = "Misc"; // Default
      await showDialog(
        context: context,
        builder: (context) {
          TextEditingController qtyController = TextEditingController(
            text: "1",
          );
          return AlertDialog(
            title: const Text("Confirm Product"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Barcode: $scannedBarcode"),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int current = int.tryParse(qtyController.text) ?? 1;
                        if (current > 1) {
                          qtyController.text = (current - 1).toString();
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        decoration: const InputDecoration(
                          labelText: "Quantity",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isEmpty || int.parse(value) < 1) {
                            qtyController.text = "1";
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed:
                          () =>
                              qtyController.text =
                                  (int.parse(qtyController.text) + 1)
                                      .toString(),
                    ),
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Category"),
                  onChanged:
                      (value) => category = value.isEmpty ? "Misc" : value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final product = Product(
                    name: name,
                    quantity: int.parse(qtyController.text),
                    category: category,
                  );
                  await _manager.addProduct(product);
                  if (mounted) {
                    setState(() {
                      _productsFuture = _manager.getProducts();
                      _barcode = scannedBarcode;
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _addManualProduct() async {
    String name = "";
    String category = "Misc";
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController qtyController = TextEditingController(text: "1");
        return AlertDialog(
          title: const Text("Add Product Manually"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      int current = int.tryParse(qtyController.text) ?? 1;
                      if (current > 1) {
                        qtyController.text = (current - 1).toString();
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: "Quantity"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isEmpty || int.parse(value) < 1) {
                          qtyController.text = "1";
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed:
                        () =>
                            qtyController.text =
                                (int.parse(qtyController.text) + 1).toString(),
                  ),
                ],
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Category"),
                onChanged: (value) => category = value.isEmpty ? "Misc" : value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final product = Product(
                  name: name,
                  quantity: int.parse(qtyController.text),
                  category: category,
                );
                await _manager.addProduct(
                  product,
                ); // Async außerhalb von setState
                if (mounted) {
                  setState(() {
                    _productsFuture = _manager.getProducts(); // Synchron
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
