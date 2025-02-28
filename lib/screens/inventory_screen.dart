import "package:flutter/material.dart";
import "package:inventory_app/services/database_service.dart";
import 'package:inventory_app/models/product.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    dbService.insertProduct(
      Product(name: "Milk", quantity: 2, category: "Dairy"),
    );
    return Scaffold(
      appBar: AppBar(title: Text("Inventory")),
      body: Center(child: Text("Coming soon")),
    );
  }
}
