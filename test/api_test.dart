import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('API fetch returns data', () async {
    // Arrange
    final url = Uri.parse('https://fakestoreapi.com/products');

    // Act
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    // Assert
    expect(response.statusCode, 200);
    expect(data, isA<List>());
    expect(data.isNotEmpty, true);
  });
}
