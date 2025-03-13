import 'package:flutter/material.dart';

// Farben als eigenständige Optionen (aus deinem JSON)
final Map<String, Map<String, Color>> availableColors = {
  'Green': {
    'light': const Color.fromRGBO(149, 196, 144, 1),
    'dark': const Color.fromRGBO(118, 179, 112, 1),
  },
  'Brown': {
    'light': const Color.fromRGBO(211, 195, 190, 1),
    'dark': const Color.fromRGBO(191, 168, 161, 1),
  },
  'Blue': {
    'light': const Color.fromRGBO(182, 220, 252, 1),
    'dark': const Color.fromRGBO(133, 197, 250, 1),
  },
  'Orange': {
    'light': const Color.fromRGBO(254, 212, 174, 1),
    'dark': const Color.fromRGBO(253, 185, 124, 1),
  },
  'Mint': {
    'light': const Color.fromRGBO(200, 230, 227, 1),
    'dark': const Color.fromRGBO(164, 214, 209, 1),
  },
  'Purple': {
    'light': const Color.fromRGBO(231, 224, 243, 1),
    'dark': const Color.fromRGBO(204, 189, 229, 1),
  },
  'Red': {
    'light': const Color.fromRGBO(251, 221, 232, 1),
    'dark': const Color.fromRGBO(245, 173, 199, 1),
  },
  'Beige': {
    'light': const Color.fromRGBO(238, 235, 228, 1),
    'dark': const Color.fromRGBO(218, 211, 196, 1),
  },
  'Yellow': {
    'light': const Color.fromRGBO(255, 220, 167, 1),
    'dark': const Color.fromRGBO(255, 200, 117, 1),
  },
  'Gray': {
    'light': const Color.fromRGBO(176, 190, 197, 1),
    'dark': const Color.fromRGBO(146, 165, 175, 1),
  },
};

// Default-Zuweisungen für Kategorien (änderbar)
final Map<String, String> categoryColorAssignments = {
  'Unsorted': 'Gray',
  'Fruits': 'Orange',
  'Vegetables': 'Green',
  'Bread': 'Brown',
  'Detergents': 'Blue',
};

// Funktionen zur Farbabfrage
Color getCategoryLightColor(String category) {
  final colorName =
      categoryColorAssignments[category] ?? 'Gray'; // Fallback: Gray
  return availableColors[colorName]!['light']!;
}

Color getCategoryDarkColor(String category) {
  final colorName =
      categoryColorAssignments[category] ?? 'Gray'; // Fallback: Gray
  return availableColors[colorName]!['dark']!;
}

// Liste für Dropdown
final List<String> colorOptions = availableColors.keys.toList();
