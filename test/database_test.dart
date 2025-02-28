import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/services/database_services.dart';
import 'package:inventory_app/models/products.dart';

void main() {
  group('DatabaseService', () {
    test('should save a product to the database', () async {
      final dbService = DatabaseService();
      final product = Product(name: 'Milk', quantity: 2, category: 'Dairy');

      await dbService.initDatabase();
      final id = await dbService.insertProduct(product);
      final saveProduct = await dbService.getProduct(id);

      expect(id, isNotNull);
      expect(saveProduct.name, product.name);
      expect(saveProduct.quantity, product.quantity);
      expect(saveProduct.category, product.category);
    });
  });
}
