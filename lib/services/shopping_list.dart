import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/services/inventory_manager.dart';

class ShoppingList {
  final InventoryManager _manager = InventoryManager();

  Future<List<Product>> getShoppingList() async {
    final products = await _manager.getProducts();
    return products.where((product) {
      if (product.useFillLevel) {
        // Workaround: Subtrahiere 0.1, um sicherzustellen, dass fillLevel <= threshold
        // auch bei Gleitkommawerten korrekt triggert (z. B. 0.6 <= 0.6).
        // TODO: Ursache (Floating-Point oder Refresh) später untersuchen.
        return (product.fillLevel ?? 1.0) - 0.1 <= (product.threshold ?? 0.2);
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
