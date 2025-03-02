import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/services/shopping_list.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/models/product.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('should return products with quantity less than 2', () async {
    final manager = InventoryManager();
    final shoppingList = ShoppingList();

    await manager.addProduct(
      Product(name: 'Milk', quantity: 1, category: 'Dairy'),
    );
    await manager.addProduct(
      Product(name: 'Bread', quantity: 3, category: 'Bakery'),
    );

    final list = await shoppingList.getShoppingList();

    expect(list.length, 1);
    expect(list.first.name, 'Milk');
  });
}
