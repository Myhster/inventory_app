import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:flutter/foundation.dart';

import 'dart:math';

double roundToPrecision(double value, int precision) {
  final factor = pow(10, precision);
  return (value * factor).roundToDouble() / factor;
}

class ShoppingList {
  final InventoryManager _manager = InventoryManager();

  Future<List<Product>> getShoppingList() async {
    final products = await _manager.getProducts();
    return products.where((product) {
      if (product.useFillLevel) {
        final fillLevel = roundToPrecision(product.fillLevel ?? 1.0, 1);
        final threshold = roundToPrecision(product.threshold ?? 0.2, 1);
        debugPrint(
          "Product: ${product.name}, fillLevel: $fillLevel, threshold: $threshold, <=: ${fillLevel <= threshold}",
        );
        return fillLevel <= threshold;
      } else {
        return product.quantity <= (product.threshold?.toInt() ?? 1);
      }
    }).toList();
  }

  Future<void> moveToInventory(Product product, int newQuantity) async {
    final existing = await _manager.getProducts();
    final inventoryProduct = existing.firstWhere(
      (p) => p.name == product.name,
      orElse: () => product,
    );
    if (inventoryProduct.id != null) {
      if (inventoryProduct.useFillLevel) {
        await _manager.updateProductFillLevel(inventoryProduct.id!, 1.0);
        await _manager.updateProductQuantity(inventoryProduct.id!, 1);
      } else {
        final updatedQuantity = inventoryProduct.quantity + newQuantity;
        await _manager.updateProductQuantity(
          inventoryProduct.id!,
          updatedQuantity,
        );
      }
    } else {
      await _manager.addProduct(
        Product(
          name: product.name,
          quantity: product.useFillLevel ? 1 : newQuantity,
          category: product.category,
          useFillLevel: product.useFillLevel,
          fillLevel: product.useFillLevel ? 1.0 : null,
        ),
      );
    }
  }
}
