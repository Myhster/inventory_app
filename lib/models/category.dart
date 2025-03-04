class Category {
  final int? id;
  final String name;
  final int orderIndex;

  Category({this.id, required this.name, this.orderIndex = 0});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'orderIndex': orderIndex,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    orderIndex: map['orderIndex'] ?? 0,
  );
}
