import 'package:flutter/material.dart';
import 'package:inventory_app/screens/inventory_screen.dart';
import 'package:inventory_app/screens/shopping_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _screens = [const InventoryScreen(), const ShoppingListScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Inventory"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Shopping",
          ),
        ],
      ),
    );
  }
}
