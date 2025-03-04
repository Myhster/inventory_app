import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/services/inventory_manager.dart';

class ShoppingList {
  final InventoryManager _manager = InventoryManager();

  Future<List<Product>> getShoppingList() async {
    final products = await _manager.getProducts();
    return products.where((product) => product.quantity < 2).toList();
  }

  Future<void> moveToInventory(Product product, int newQuantity) async {
    final existing = await _manager.getProducts();
    final inventoryProduct = existing.firstWhere(
      (p) => p.name == product.name,
      orElse: () => product,
    );
    if (inventoryProduct.id != null) {
      final updatedQuantity =
          inventoryProduct.quantity + newQuantity; // Alte Menge + Neue Menge
      await _manager.updateProductQuantity(
        inventoryProduct.id!,
        updatedQuantity,
      );
    } else {
      await _manager.addProduct(
        Product(
          name: product.name,
          quantity: newQuantity,
          category: product.category,
        ),
      );
    }
  }
}
