import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/services/database_service.dart';
import 'package:inventory_app/models/product.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

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
