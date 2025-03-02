import 'package:flutter/material.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/models/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  InventoryScreenState createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final InventoryManager _manager = InventoryManager();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _manager.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: FutureBuilder<List<Product>>(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProduct() async {
    final product = Product(name: 'Test', quantity: 1, category: 'Misc');
    await _manager.addProduct(product);
    setState(() {
      _productsFuture = _manager.getProducts();
    });
  }
}
