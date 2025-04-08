import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/services/api_service.dart';
import 'package:inventory_app/models/product.dart';

void main() {
  group('ApiService', () {
    late ApiService service;

    setUp(() {
      // Arrange
      service = ApiService();
    });

    test('fetchProducts returns list of products on success', () async {
      // Act
      final products = await service.fetchProducts();

      // Assert
      expect(products, isA<List<Product>>());
      expect(products.isNotEmpty, true);
      expect(products.first.id, isNotNull);
    });
  });
}
