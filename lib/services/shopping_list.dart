import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:inventory_app/models/category.dart';

import 'dart:math';

double roundToPrecision(double value, int precision) {
  final factor = pow(10, precision);
  return (value * factor).roundToDouble() / factor;
}

class ShoppingList {
  final InventoryManager _manager = InventoryManager();

  Future<List<Product>> getShoppingList() async {
    final inventoryProducts = await _manager.getProducts();
    final thresholdProducts =
        inventoryProducts.where((product) {
          if (product.useFillLevel) {
            final fillLevel = roundToPrecision(product.fillLevel ?? 1.0, 1);
            final threshold = roundToPrecision(product.threshold ?? 0.2, 1);
            foundation.debugPrint(
              "Product: ${product.name}, fillLevel: $fillLevel, threshold: $threshold, <=: ${fillLevel <= threshold}",
            );
            return fillLevel <= threshold;
          } else {
            return product.quantity <= (product.threshold?.toInt() ?? 1);
          }
        }).toList();

    final shoppingItems = await _manager.getShoppingItems();
    final manualProducts =
        shoppingItems
            .map(
              (item) => Product(
                id: item['id'],
                name: item['name'],
                quantity: item['quantity_to_buy'],
                category: item['category'],
              ),
            )
            .toList();

    return [...thresholdProducts, ...manualProducts];
  }

  Future<List<Product>> getInventoryProducts() async {
    return await _manager.getProducts();
  }

  Future<void> moveToInventory(Product product, int newQuantity) async {
    final existing = await _manager.getProducts();
    final inventoryProduct = existing.firstWhere(
      (p) => p.name == product.name,
      orElse:
          () => Product(
            name: product.name,
            quantity: newQuantity < 1 ? 1 : newQuantity, // Mindestens 1
            category: product.category,
            useFillLevel: false,
            fillLevel: null,
            threshold: 1.0,
          ),
    );

    if (inventoryProduct.id != null) {
      if (inventoryProduct.useFillLevel) {
        await _manager.updateProductFillLevel(inventoryProduct.id!, 1.0);
        await _manager.updateProductQuantity(inventoryProduct.id!, 1);
      } else {
        final updatedQuantity =
            inventoryProduct.quantity + (newQuantity < 1 ? 1 : newQuantity);
        await _manager.updateProductQuantity(
          inventoryProduct.id!,
          updatedQuantity,
        );
      }
    } else {
      await _manager.addProduct(
        Product(
          name: product.name,
          quantity: newQuantity < 1 ? 1 : newQuantity, // Mindestens 1
          category: product.category,
          useFillLevel: false,
          fillLevel: null,
          threshold: 1.0,
        ),
      );
    }

    final isManual = !existing.any((p) => p.id == product.id);
    if (isManual && product.id != null) {
      await _manager.removeShoppingItem(product.id!);
    }
  }

  Future<List<Category>> getCategories() async {
    return await _manager.getCategories();
  }

  Future<void> addToShoppingList(
    String name,
    int quantityToBuy,
    String category,
  ) async {
    await _manager.addShoppingItem(name, quantityToBuy, category);
  }

  Future<void> removeFromShoppingList(int id) async {
    await _manager.removeShoppingItem(id);
  }

  Future<List<Product>> getThresholdProducts() async {
    final inventoryProducts = await _manager.getProducts();
    return inventoryProducts.where((p) => p.isBelowThreshold()).toList();
  }
}
