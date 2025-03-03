import 'package:flutter/material.dart';
import 'package:inventory_app/screens/home_screen.dart';
import 'package:inventory_app/screens/barcode_test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const BarcodeTestScreen());
  }
}
