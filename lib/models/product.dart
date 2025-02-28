class Product {
  final int? id;
  final String name;
  final int quantity;
  final String category;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'quantity': quantity, 'category': category};
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      category: map['category'],
    );
  }
}
