import 'package:flutter/material.dart';
import 'package:inventory_app/screens/inventory_screen.dart';
import 'package:inventory_app/screens/shopping_list_screen.dart';
import 'package:inventory_app/services/database_service.dart';
import 'package:inventory_app/models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  Future<void> _refreshCategories() async {
    try {
      setState(() => _isLoading = true);
      final categories = await _dbService.getCategories();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory Home")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _categories.isEmpty
              ? const Center(child: Text("No categories yet."))
              : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(category),
                    ),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryScreen(),
                          ),
                        ),
                  );
                },
              ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addCategory,
            tooltip: "Add Category",
            heroTag: "addCategory",
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                ),
            tooltip: "Scan Product",
            heroTag: "scanProduct",
            child: const Icon(Icons.camera_alt),
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

  Future<void> _addCategory() async {
    String name = "";
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Category"),
            content: TextField(
              decoration: const InputDecoration(labelText: "Category Name"),
              onChanged: (value) => name = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await _dbService.insertCategory(Category(name: name));
                    await _refreshCategories();
                  }
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    await _dbService.removeCategory(category.id!);
    await _refreshCategories();
  }
}
