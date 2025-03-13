import 'package:flutter/material.dart';

final Map<String, Map<String, Color>> categoryColors = {
  'Unsorted': {
    'light': const Color(0xFFB0BEC5),
    'dark': const Color(0xFF90A4AE),
  },
  'Fruits': {'light': const Color(0xFFFFCC80), 'dark': const Color(0xFFFFB300)},
  'Vegetables': {
    'light': const Color.fromARGB(255, 183, 208, 184),
    'dark': const Color.fromRGBO(139, 164, 140, 1),
  },
  'Bread': {'light': const Color(0xFFBCAAA4), 'dark': const Color(0xFFA1887F)},
  'Detergents': {
    'light': const Color(0xFF90CAF9),
    'dark': const Color(0xFF64B5F6),
  },
};

// Palette für neue Kategorien
final Map<String, Map<String, Color>> availableColors = {
  'Peach': {'light': const Color(0xFFFFE0B2), 'dark': const Color(0xFFFFB300)},
  'Mint': {'light': const Color(0xFFB2DFDB), 'dark': const Color(0xFF4DB6AC)},
  'Lavender': {
    'light': const Color(0xFFD1C4E9),
    'dark': const Color(0xFF9575CD),
  },
  'Rose': {'light': const Color(0xFFF8BBD0), 'dark': const Color(0xFFF06292)},
  'Sand': {'light': const Color(0xFFE6D7B9), 'dark': const Color(0xFFD4A373)},
};

Color getCategoryLightColor(String category) {
  return categoryColors[category]?['light'] ??
      availableColors.values.first['light']!;
}

Color getCategoryDarkColor(String category) {
  return categoryColors[category]?['dark'] ??
      availableColors.values.first['dark']!;
}

final List<String> colorOptions = availableColors.keys.toList();
