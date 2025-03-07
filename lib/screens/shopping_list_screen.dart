import 'package:flutter/material.dart';
import 'package:inventory_app/services/shopping_list.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/screens/inventory_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ShoppingListScreenState createState() => ShoppingListScreenState();
}

class ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingList _shoppingList = ShoppingList();
  List<Product> _shoppingProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshShoppingList();
  }

  Future<void> _refreshShoppingList() async {
    setState(() => _isLoading = true);
    _shoppingProducts = await _shoppingList.getShoppingList();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshShoppingList, // Manuelles Refresh hinzufügen
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _shoppingList.getShoppingList(), // Immer aktuelle Liste
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading shopping list"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nothing to buy yet!"));
          }
          _shoppingProducts = snapshot.data!;
          return _buildShoppingList(context);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const InventoryScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context) {
    final groupedProducts = _groupByCategory(_shoppingProducts);
    final sortedCategories = groupedProducts.keys.toList()..sort();
    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryProducts = groupedProducts[category]!;
        return ExpansionTile(
          title: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          initiallyExpanded: true,
          children:
              categoryProducts
                  .map((product) => _buildShoppingTile(product, context))
                  .toList(),
        );
      },
    );
  }

  Widget _buildShoppingTile(Product product, BuildContext context) {
    final toBuy =
        product.useFillLevel
            ? 1
            : ((product.threshold?.toInt() ?? 1) - product.quantity + 1)
                .clamp(1, double.infinity)
                .toInt(); // Fix: Berechnung
    return ListTile(
      title: Text(product.name),
      subtitle: Text("To Buy: $toBuy"), // Fix: Neue Anzeige
      trailing: Checkbox(
        value: false,
        onChanged: (value) => _handleCheckbox(product, value, context),
      ),
    );
  }

  Future<void> _handleCheckbox(
    Product product,
    bool? value,
    BuildContext context,
  ) async {
    if (value == true) {
      int newQuantity = 1;
      if (!product.useFillLevel) {
        // Nur bei Nicht-Fill-Level Menge anpassen
        final controller = TextEditingController(text: "1");
        final result = await showDialog<int>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Add to Inventory"),
                content: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int current = int.tryParse(controller.text) ?? 1;
                        if (current > 1) {
                          controller.text = (current - 1).toString();
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Quantity",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          if (val.isEmpty || int.parse(val) < 1) {
                            controller.text = "1";
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int current = int.tryParse(controller.text) ?? 1;
                        controller.text = (current + 1).toString();
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed:
                        () =>
                            Navigator.pop(context, int.parse(controller.text)),
                    child: const Text("Confirm"),
                  ),
                ],
              ),
        );
        newQuantity = result ?? 1;
      }
      if (mounted) {
        await _shoppingList.moveToInventory(product, newQuantity);
        await _refreshShoppingList();
      }
    }
  }

  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    final Map<String, List<Product>> grouped = {};
    for (var product in products) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }
    return grouped;
  }
}
