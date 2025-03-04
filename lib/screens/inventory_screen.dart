import 'package:flutter/material.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/models/category.dart';
import 'barcode_scanner_dialog.dart';
import 'add_product_dialog.dart';
import 'shopping_list_screen.dart';
import 'product_list.dart';
import 'category_manager_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  InventoryScreenState createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final InventoryManager _manager = InventoryManager();
  List<Product> _products = [];
  List<Category> _categories = [];
  String _barcode = "Not scanned yet";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => _manageCategories(context),
          ),
        ],
      ),
      body: ProductList(
        products: _products,
        categories: _categories,
        isLoading: _isLoading,
        manager: _manager,
        onRefresh: _refreshData,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addManualProduct,
            tooltip: "Add Manually",
            child: const Icon(Icons.add),
            heroTag: "addManual",
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _scanAndAddProduct,
            tooltip: "Scan Barcode",
            child: const Icon(Icons.camera_alt),
            heroTag: "scanBarcode",
          ),
        ],
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShoppingListScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    print('Refreshing data...');
    setState(() => _isLoading = true);
    try {
      _products = await _manager.getProducts();
      _categories = await _manager.getCategories();
      if (_categories.isEmpty) {
        await _manager.addCategory(Category(name: 'Unsortiert')); // Fallback
        _categories = await _manager.getCategories();
      }
      print(
        'Loaded ${_products.length} products, ${_categories.length} categories',
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('Error refreshing data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanAndAddProduct() async {
    final scannedBarcode = await showDialog<String>(
      context: context,
      builder: (context) => const BarcodeScannerDialog(),
    );

    if (scannedBarcode != null && mounted) {
      final categoriesList =
          _categories.isNotEmpty
              ? _categories.map((c) => c.name).toList()
              : ['Unsortiert'];
      final productData = await showDialog<ProductData>(
        context: context,
        builder:
            (context) => AddProductDialog(
              initialName: "Item $scannedBarcode",
              categories: categoriesList,
            ),
      );
      if (productData != null) {
        await _manager.addProduct(
          Product(
            name: productData.name,
            quantity: productData.quantity,
            category: productData.category,
          ),
        );
        _barcode = scannedBarcode;
        await _refreshData();
      }
    }
  }

  Future<void> _addManualProduct() async {
    final productData = await showDialog<ProductData>(
      context: context,
      builder:
          (context) => AddProductDialog(
            categories: _categories.map((c) => c.name).toList(),
          ),
    );
    if (productData != null && mounted) {
      await _manager.addProduct(
        Product(
          name: productData.name,
          quantity: productData.quantity,
          category: productData.category,
        ),
      );
      await _refreshData();
    }
  }

  Future<void> _manageCategories(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) => CategoryManagerDialog(
            manager: _manager,
            categories: _categories,
            onRefresh: _refreshData,
          ),
    ).then((_) => _refreshData()); // Refresh nach Dialog-Schließen
  }
}
