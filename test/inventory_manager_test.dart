import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/models/product.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('should add and retrieve a product', () async {
    final manager = InventoryManager();
    final product = Product(name: 'Milk', quantity: 2, category: 'Dairy');

    await manager.addProduct(product);
    final products = await manager.getProducts();

    expect(products.isNotEmpty, true);
    expect(products.first.name, 'Milk');
  });
}
