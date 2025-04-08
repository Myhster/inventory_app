import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/models/product.dart';

void main() {
  test('Product parses Fake Store API JSON correctly', () {
    // Arrange
    final json = {
      "id": 1,
      "title": "Fjallraven Backpack",
      "price": 109.95,
      'category': "men\'s clothing",
    };

    // Act
    final product = Product.fromJson(json);

    // Assert
    expect(product.id, 1);
    expect(product.name, "Fjallraven Backpack");
    expect(product.price, 109.95);
    expect(product.category, 'men\'s clothing');
    expect(product.quantity, 1);
  });
}
