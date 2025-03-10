class Product {
  final int? id;
  final String name;
  final int quantity;
  final String category;
  final int orderIndex;
  final double? threshold;
  final bool useFillLevel;
  final double? fillLevel;

  Product({
    this.id,
    required this.name,
    int? quantity,
    required this.category,
    this.orderIndex = 0,
    this.threshold,
    this.useFillLevel = false,
    this.fillLevel,
  }) : quantity = useFillLevel ? 1 : (quantity ?? 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'orderIndex': orderIndex,
      'threshold': threshold,
      'useFillLevel': useFillLevel ? 1 : 0,
      'fillLevel': fillLevel,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      category: map['category'],
      orderIndex: map['orderIndex'] ?? 0,
      threshold: map['threshold'],
      useFillLevel: map['useFillLevel'] == 1 ? true : false,
      fillLevel: map['fillLevel'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    int? quantity,
    String? category,
    int? orderIndex,
    double? threshold,
    bool? useFillLevel,
    double? fillLevel,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      orderIndex: orderIndex ?? this.orderIndex,
      threshold: threshold ?? this.threshold,
      useFillLevel: useFillLevel ?? this.useFillLevel,
      fillLevel: fillLevel ?? this.fillLevel,
    );
  }

  
  bool isBelowThreshold() {
    if (useFillLevel) {
      return (fillLevel ?? 1.0) <= (threshold ?? 0.2);
    }
    return quantity <= (threshold?.toInt() ?? 1);
  }
}
