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
  late String _name;
  late String _category;
  late double? _threshold;
  late bool _useFillLevel;
  late double? _fillLevel;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _category = widget.product.category;
    _threshold = widget.product.threshold;
    _useFillLevel = widget.product.useFillLevel;
    _fillLevel = widget.product.fillLevel ?? 1.0;
    if (_useFillLevel && (_threshold == null || _threshold! > 0.8)) {
      _threshold = 0.8;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Product Settings"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Name"),
              controller: TextEditingController(text: _name),
              onChanged: (value) => _name = value,
            ),
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
            if (!_useFillLevel)
              Text("Current Quantity: ${widget.product.quantity}"),
            SwitchListTile(
              title: const Text("Use Fill Level"),
              value: _useFillLevel,
              onChanged:
                  (value) => setState(() {
                    _useFillLevel = value;
                    if (!value && _threshold != null && _threshold! < 1.0) {
                      _threshold = 1.0;
                    } else if (value &&
                        (_threshold == null || _threshold! > 0.8)) {
                      _threshold = 0.2;
                    }
                  }),
            ),
            if (!_useFillLevel)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "Quantity Threshold",
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          controller: TextEditingController(
                            text: _threshold?.toInt().toString() ?? "",
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null) _threshold = parsed.toDouble();
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _threshold == null,
                        onChanged:
                            (value) => setState(
                              () => _threshold = value! ? null : 1.0,
                            ),
                      ),
                      const Text("No Shopping List"),
                    ],
                  ),
                ],
              ),

            if (_useFillLevel)
              Column(
                children: [
                  const Text("Fill Level:"),
                  Slider(
                    value: _fillLevel ?? 1.0,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _fillLevel?.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _fillLevel = value),
                  ),
                  const Text("Threshold:"),
                  Slider(
                    value: _threshold ?? 0.2,
                    min: 0.2,
                    max: _useFillLevel ? 0.8 : 1.0,
                    divisions: _useFillLevel ? 3 : 4,
                    label: _threshold?.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _threshold = value),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Fill: ${_fillLevel?.toStringAsFixed(1) ?? '1.0'}, Threshold: ${_threshold?.toStringAsFixed(1) ?? '0.2'}",
                        ),
                      ),
                      Checkbox(
                        value: _threshold == null,
                        onChanged:
                            (value) => setState(
                              () =>
                                  _threshold =
                                      value!
                                          ? null
                                          : (_useFillLevel ? 0.2 : 1.0),
                            ),
                      ),
                      const Text("No Shopping List"),
                    ],
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
            if (_name.trim().isEmpty) return;
            await widget.manager.updateProductSettings(
              widget.product.id!,
              _category,
              _threshold,
              _useFillLevel,
              _useFillLevel ? _fillLevel : null,
            );
            await widget.manager.updateProduct(widget.product.id!, name: _name);
            widget.onRefresh();
            if (mounted) Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
