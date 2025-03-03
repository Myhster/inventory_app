import 'package:flutter/material.dart';
import 'package:inventory_app/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomeScreen());
  }
}
