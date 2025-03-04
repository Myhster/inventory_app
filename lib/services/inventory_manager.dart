import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/services/database_service.dart';

class InventoryManager {
  final DatabaseService _dbService = DatabaseService();

  Future<void> addProduct(Product product) async {
    final existing = await _dbService.getProductByName(product.name); // Neu
    if (existing != null) {
      await _dbService.updateProductQuantity(
        existing.id!,
        existing.quantity + product.quantity,
      );
    } else {
      await _dbService.insertProduct(product);
    }
  }

  Future<void> removeProduct(int id) async {
    await _dbService.initDatabase();
    await _dbService.database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getProducts() async {
    await _dbService.initDatabase();
    final maps = await _dbService.database.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }
}
