import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/models/category.dart';
import 'package:inventory_app/services/database_service.dart';

class InventoryManager {
  final DatabaseService _dbService = DatabaseService();

  Future<void> addProduct(Product product) async {
    final existing = await _dbService.getProductByName(product.name);
    if (existing != null) {
      if (existing.useFillLevel) {
        await _dbService.updateProductQuantity(existing.id!, 1);
      } else {
        await _dbService.updateProductQuantity(
          existing.id!,
          existing.quantity + product.quantity,
        );
      }
    } else {
      await _dbService.insertProduct(product);
    }
  }

  Future<List<Product>> getProducts() async {
    return await _dbService.getProducts();
  }

  Future<void> removeProduct(int id) async {
    await _dbService.removeProduct(id);
  }

  Future<void> updateProductQuantity(int id, int newQuantity) async {
    await _dbService.updateProductQuantity(id, newQuantity);
  }

  Future<void> updateProductOrder(int id, int newOrderIndex) async {
    await _dbService.updateProductOrder(id, newOrderIndex);
  }

  Future<void> updateProductFillLevel(int id, double fillLevel) async {
    await _dbService.update(
      'products',
      {'fillLevel': fillLevel},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProductSettings(
    int id,
    String category,
    double? threshold,
    bool useFillLevel,
    double? fillLevel,
  ) async {
    await _dbService.update(
      'products',
      {
        'category': category,
        'threshold': threshold,
        'useFillLevel': useFillLevel ? 1 : 0,
        'fillLevel': fillLevel,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Category>> getCategories() async {
    return await _dbService.getCategories();
  }

  Future<void> addCategory(Category category) async {
    await _dbService.insertCategory(category);
  }

  Future<void> removeCategory(int id) async {
    await _dbService.removeCategory(id);
  }

  Future<void> updateCategoryOrder(int id, int newOrderIndex) async {
    await _dbService.updateCategoryOrder(id, newOrderIndex);
  }
}
