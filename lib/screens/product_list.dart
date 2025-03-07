import 'package:flutter/material.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/models/category.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/screens/product_settings_dialog.dart';
import 'dart:math';

double roundToPrecision(double value, int precision) {
  final factor = pow(10, precision);
  return (value * factor).roundToDouble() / factor;
}

class ProductList extends StatelessWidget {
  final List<Product> products;
  final List<Category> categories;
  final bool isLoading;
  final InventoryManager manager;
  final VoidCallback onRefresh;

  const ProductList({
    super.key,
    required this.products,
    required this.categories,
    required this.isLoading,
    required this.manager,
    required this.onRefresh,
  });

  @override
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (products.isEmpty) return const Center(child: Text("No items yet."));
    final groupedProducts = _groupByCategory(products);
    if (groupedProducts.isEmpty) {
      return const Center(child: Text("No categories yet."));
    }

    final sortedCategories =
        groupedProducts.keys.toList()..sort((a, b) {
          final aIndex =
              categories.firstWhere((cat) => cat.name == a).orderIndex;
          final bIndex =
              categories.firstWhere((cat) => cat.name == b).orderIndex;
          return aIndex.compareTo(bIndex);
        });

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryProducts = groupedProducts[category]!;
        return ExpansionTile(
          key: ValueKey(category), // Key für Kategorie
          title: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          initiallyExpanded: true,
          children: [
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder:
                  (oldIndex, newIndex) =>
                      _onReorder(categoryProducts, oldIndex, newIndex),
              children:
                  categoryProducts
                      .map((product) => _buildProductTile(product, context))
                      .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductTile(Product product, BuildContext context) {
    return ListTile(
      key: ValueKey(product.id), // Key für jedes Produkt
      leading: IconButton(
        icon: const Icon(Icons.drag_handle),
        onPressed: () {},
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        product.useFillLevel
            ? "Fill: ${product.fillLevel?.toStringAsFixed(1) ?? '1.0'}"
            : "Qty: ${product.quantity}",
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed:
                () =>
                    product.useFillLevel
                        ? _updateFillLevel(product, -0.2)
                        : _updateQuantity(product, -1),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed:
                () =>
                    product.useFillLevel
                        ? _updateFillLevel(product, 0.2)
                        : _updateQuantity(product, 1),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _openSettings(product, context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _deleteProduct(product, context),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings(Product product, BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) => ProductSettingsDialog(
            product: product,
            categories: categories,
            manager: manager,
            onRefresh: onRefresh,
          ),
    );
  }

  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    final Map<String, List<Product>> grouped = {};
    for (var product in products) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }
    return grouped;
  }

  Future<void> _updateQuantity(Product product, int change) async {
    final newQuantity = product.quantity + change;
    if (newQuantity >= 0) {
      await manager.updateProductQuantity(product.id!, newQuantity);
      onRefresh();
    }
  }

  Future<void> _updateFillLevel(Product product, double change) async {
    double newFillLevel = (product.fillLevel ?? 1.0) + change;
    newFillLevel = roundToPrecision(newFillLevel, 1);
    if (newFillLevel >= 0.2 && newFillLevel <= 1.0) {
      debugPrint("Updating ${product.name} to newFillLevel: $newFillLevel");
      await manager.updateProductFillLevel(product.id!, newFillLevel);
      onRefresh();
    }
  }

  Future<void> _deleteProduct(Product product, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Product"),
            content: Text("Are you sure you want to delete '${product.name}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await manager.removeProduct(product.id!);
      onRefresh();
    }
  }

  void _onReorder(
    List<Product> categoryProducts,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final movedProduct = categoryProducts.removeAt(oldIndex);
    categoryProducts.insert(newIndex, movedProduct);
    for (int i = 0; i < categoryProducts.length; i++) {
      await manager.updateProductOrder(categoryProducts[i].id!, i);
    }
    onRefresh();
  }
}
