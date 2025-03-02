import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/services/inventory_manager.dart';

class ShoppingList {
  final InventoryManager _manager = InventoryManager();

  Future<List<Product>> getShoppingList() async {
    final products = await _manager.getProducts();
    return products.where((product) => product.quantity < 2).toList();
  }
}
