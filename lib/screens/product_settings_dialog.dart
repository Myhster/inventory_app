import 'package:flutter/material.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/models/category.dart';
import 'package:inventory_app/services/inventory_manager.dart';

class ProductSettingsDialog extends StatefulWidget {
  final Product product;
  final List<Category> categories;
  final InventoryManager manager;
  final VoidCallback onRefresh;

  const ProductSettingsDialog({
    super.key,
    required this.product,
    required this.categories,
    required this.manager,
    required this.onRefresh,
  });

  @override
  ProductSettingsDialogState createState() => ProductSettingsDialogState();
}

class ProductSettingsDialogState extends State<ProductSettingsDialog> {
  late String _category;
  late int? _threshold;
  late bool _useFillLevel;
  late double? _fillLevel;

  @override
  void initState() {
    super.initState();
    _category = widget.product.category;
    _threshold = widget.product.threshold;
    _useFillLevel = widget.product.useFillLevel;
    _fillLevel = widget.product.fillLevel ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Settings for ${widget.product.name}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: "Category"),
              items:
                  widget.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.name,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
              onChanged:
                  (value) => setState(() => _category = value ?? _category),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: "Threshold"),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _threshold?.toString() ?? "",
                    ),
                    onChanged: (value) => _threshold = int.tryParse(value),
                  ),
                ),
                Checkbox(
                  value: _threshold == null,
                  onChanged:
                      (value) => setState(() => _threshold = value! ? null : 1),
                ),
                const Text("No Shopping List"),
              ],
            ),
            SwitchListTile(
              title: const Text("Use Fill Level"),
              value: _useFillLevel,
              onChanged: (value) => setState(() => _useFillLevel = value),
            ),
            if (_useFillLevel)
              Column(
                children: [
                  Slider(
                    value: _fillLevel ?? 1.0,
                    min: 0.2,
                    max: 1.0,
                    divisions: 4,
                    label: _fillLevel?.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _fillLevel = value),
                  ),
                  Text(
                    "Fill Level: ${_fillLevel?.toStringAsFixed(1) ?? '1.0'}",
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            await widget.manager.updateProductSettings(
              widget.product.id!,
              _category,
              _threshold,
              _useFillLevel,
              _useFillLevel ? _fillLevel : null,
            );
            widget.onRefresh();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
