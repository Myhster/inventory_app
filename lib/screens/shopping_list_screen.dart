import 'package:flutter/material.dart';
import 'package:inventory_app/services/shopping_list.dart';
import 'package:inventory_app/models/product.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ShoppingListScreenState createState() => ShoppingListScreenState();
}

class ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingList _shoppingList = ShoppingList();
  late Future<List<Product>> _shoppingFuture;

  @override
  void initState() {
    super.initState();
    _shoppingFuture = _shoppingList.getShoppingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List")),
      body: FutureBuilder<List<Product>>(
        future: _shoppingFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data!;
            if (products.isEmpty) {
              return const Center(child: Text("Nothing to buy yet!"));
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text("Qty: ${product.quantity}"),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
