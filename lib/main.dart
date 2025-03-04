import 'package:flutter/material.dart';
import 'package:inventory_app/screens/inventory_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(elevation: 2, centerTitle: true),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent,
        ),
      ),
      home: const InventoryScreen(),
    );
  }
}
