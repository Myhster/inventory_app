class Category {
  final int? id;
  final String name;
  final int orderIndex;
  final String? color; // Neues Feld

  Category({this.id, required this.name, this.orderIndex = 0, this.color});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'orderIndex': orderIndex,
    'color': color,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    orderIndex: map['orderIndex'] ?? 0,
    color: map['color'],
  );
}
