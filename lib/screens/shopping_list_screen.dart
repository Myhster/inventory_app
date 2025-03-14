import 'package:flutter/material.dart';
import 'package:inventory_app/services/shopping_list.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/screens/inventory_screen.dart';
import 'add_product_dialog.dart';
import 'package:inventory_app/utils/colors.dart';
import 'package:inventory_app/models/category.dart';
import 'package:inventory_app/screens/product_list.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ShoppingListScreenState createState() => ShoppingListScreenState();
}

class ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingList _shoppingList = ShoppingList();
  List<Product> _shoppingProducts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _refreshShoppingList();
  }

  Future<void> _refreshShoppingList() async {
    final products = await _shoppingList.getShoppingList();
    final categories = await _shoppingList.getCategories();
    setState(() {
      _shoppingProducts = products;
      _categories = categories;
      for (var product in products) {
        globalExpandedState.putIfAbsent(product.category, () => true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        automaticallyImplyLeading: false,
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
    final sortedCategories =
        groupedProducts.keys.toList()..sort((a, b) {
          final aIndex =
              _categories
                  .firstWhere(
                    (cat) => cat.name == a,
                    orElse: () => Category(name: a, orderIndex: 999),
                  )
                  .orderIndex;
          final bIndex =
              _categories
                  .firstWhere(
                    (cat) => cat.name == b,
                    orElse: () => Category(name: b, orderIndex: 999),
                  )
                  .orderIndex;
          return aIndex.compareTo(bIndex);
        });
    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryProducts = groupedProducts[category]!;
        final lightColor = getCategoryLightColor(category);
        final darkColor = getCategoryDarkColor(category);
        return Container(
          color: lightColor,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            title: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            backgroundColor: lightColor,
            collapsedBackgroundColor: lightColor,
            initiallyExpanded:
                globalExpandedState[category] ?? true, // Globale Map
            onExpansionChanged: (expanded) {
              setState(() {
                globalExpandedState[category] = expanded; // Globale Map
              });
            },
            children:
                categoryProducts
                    .map(
                      (product) => Container(
                        color: darkColor,
                        child: _buildShoppingTile(product, context),
                      ),
                    )
                    .toList(),
          ),
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
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editShoppingProductName(product),
            ),
            if (isManual)
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

  Future<void> _editShoppingProductName(Product product) async {
    final controller = TextEditingController(text: product.name);
    final newName = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Product Name"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text("Save"),
              ),
            ],
          ),
    );
    if (newName != null && newName.trim().isNotEmpty && mounted) {
      await _shoppingList.updateShoppingProductName(product.id!, newName);
      await _refreshShoppingList();
    }
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
                              (current - 1).toString();
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
                            controller.text = "1";
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
