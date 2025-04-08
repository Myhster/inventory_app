import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inventory_app/models/product.dart';

class ApiService {
  static const baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }
  }
}
