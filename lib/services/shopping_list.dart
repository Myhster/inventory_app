import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/services/inventory_manager.dart';
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
            final fillLevel = product.fillLevel ?? 1.0;
            final threshold = product.threshold ?? 0.2;
            return fillLevel <= threshold;
          } else {
            return product.quantity <= (product.threshold?.toInt() ?? 0);
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
      (p) => p.name == product.name && p.category == product.category,
      orElse:
          () => Product(
            name: product.name,
            quantity: newQuantity < 1 ? 1 : newQuantity,
            category: product.category,
            useFillLevel: false,
            fillLevel: null,
            threshold: 0.0,
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
          quantity: newQuantity < 1 ? 1 : newQuantity,
          category: product.category,
          useFillLevel: false,
          fillLevel: null,
          threshold: 0.0,
        ),
      );
    }

    if (product.id != null && !existing.any((p) => p.id == product.id)) {
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

  Future<void> updateProductFillLevel(int id, double fillLevel) async {
    await _manager.updateProductFillLevel(id, fillLevel);
  }

  Future<void> updateProductQuantity(int id, int newQuantity) async {
    await _manager.updateProductQuantity(id, newQuantity);
  }

  Future<void> updateShoppingProductName(int id, String newName) async {
    final inventoryProducts = await _manager.getProducts();
    final isInventoryItem = inventoryProducts.any((p) => p.id == id);

    if (isInventoryItem) {
      await _manager.updateProduct(id, name: newName);
    } else {
      await _manager.updateShoppingItemName(id, newName);
    }
  }
}
