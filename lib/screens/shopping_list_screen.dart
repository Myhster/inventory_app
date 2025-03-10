import 'package:flutter/material.dart';
import 'package:inventory_app/services/shopping_list.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/screens/inventory_screen.dart';
import 'add_product_dialog.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ShoppingListScreenState createState() => ShoppingListScreenState();
}

class ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingList _shoppingList = ShoppingList();
  List<Product> _shoppingProducts = [];

  @override
  void initState() {
    super.initState();
    _refreshShoppingList();
  }

  Future<void> _refreshShoppingList() async {
    final products = await _shoppingList.getShoppingList();
    setState(() {
      _shoppingProducts = products;
    });
  }

Future<void> _addShoppingProduct() async {
    final categories = await _shoppingList.getCategories();
    final productData = await showDialog<ProductData>(
      context: context,
      builder:
          (context) => AddProductDialog(
            categories: categories.map((c) => c.name).toList(),
          ),
    );
    if (productData != null && mounted) {
      final validatedQuantity =
          productData.quantity < 1 ? 1 : productData.quantity;
      await _shoppingList.addToShoppingList(
        productData.name,
        validatedQuantity,
        productData.category,
      );
      await _refreshShoppingList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshShoppingList,
          ),
        ],
      ),
      body:
          _shoppingProducts.isEmpty
              ? const Center(child: Text("Nothing to buy yet!"))
              : _buildShoppingList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _addShoppingProduct,
        tooltip: "Add Product",
        heroTag: "addShoppingProduct",
        child: const Icon(Icons.add),
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
    return FutureBuilder<List<Product>>(
      future: _shoppingList.getThresholdProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const ListTile(title: Text("Loading..."));
        final thresholdProducts = snapshot.data!;
        final isManual =
            product.id != null &&
            !thresholdProducts.any((p) => p.id == product.id);
        final toBuy =
            isManual
                ? product.quantity
                : product.useFillLevel
                ? 1
                : ((product.threshold?.toInt() ?? 1) - product.quantity + 1)
                    .clamp(1, double.infinity)
                    .toInt();
        return ListTile(
          title: Text(product.name),
          subtitle: Text("To Buy: $toBuy"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isManual) // Nur für manuelle Produkte
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteShoppingProduct(product),
                ),
              Checkbox(
                value: false,
                onChanged: (value) => _handleCheckbox(product, value, context),
              ),
            ],
          ),
        );
      },
    );
  }

 Future<void> _handleCheckbox(
    Product product,
    bool? value,
    BuildContext context,
  ) async {
    if (value == true) {
      int newQuantity = 1;
      final inventoryProducts = await _shoppingList.getInventoryProducts();
      final isManual =
          product.id != null &&
          !inventoryProducts.any((p) => p.id == product.id);
      if (!product.useFillLevel || isManual) {
        final controller = TextEditingController(
          text: product.quantity.toString(),
        );
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
                        if (current > 1)
                          controller.text =
                              (current - 1).toString(); // Nicht unter 1
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
                          if (val.isEmpty || int.parse(val) < 1)
                            controller.text = "1"; // Mindestens 1
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
        newQuantity = result ?? 1; // Standardwert ist 1
      }
      if (mounted) {
        await _shoppingList.moveToInventory(product, newQuantity);
        await _refreshShoppingList();
      }
    }
  }

Future<void> _deleteShoppingProduct(Product product) async {
    final inventoryProducts = await _shoppingList.getInventoryProducts();
    final isManual =
        product.id != null && !inventoryProducts.any((p) => p.id == product.id);
    if (isManual && product.id != null) {
      await _shoppingList.removeFromShoppingList(product.id!);
      await _refreshShoppingList();
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
