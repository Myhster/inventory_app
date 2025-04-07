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
      title: Text(
        "Product Settings",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
          decoration: InputDecoration(
            labelText: "Name",
            hintText: "Enter product name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
              controller: TextEditingController(text: _name),
              onChanged: (value) => _name = value,
            ),
        SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
          decoration: InputDecoration(
            labelText: "Category",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: widget.categories
              .map((cat) => DropdownMenuItem(value: cat.name, child: Text(cat.name)))
                      .toList(),
              onChanged:
                  (value) => setState(() => _category = value ?? _category),
            ),
        SizedBox(height: 16),
            if (!_useFillLevel)
          Text("Current Quantity: ${widget.product.quantity}", style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
            SwitchListTile(
          title: Text("Use Fill Level", style: TextStyle(fontSize: 16)),
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
          activeColor: Colors.teal,
            ),
        if (!_useFillLevel) ...[
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
                            labelText: "Quantity Threshold",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _threshold == null,
                        onChanged:
                            (value) => setState(
                              () => _threshold = value! ? null : 1.0,
                            ),
                      ),
              Text("No Shopping List", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
        if (_useFillLevel) ...[
          SizedBox(height: 8),
          Text("Fill Level:", style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _fillLevel ?? 1.0,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _fillLevel?.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _fillLevel = value),
            activeColor: Colors.teal,
                  ),
          Text("Threshold:", style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _threshold ?? 0.2,
                    min: 0.2,
                    max: _useFillLevel ? 0.8 : 1.0,
                    divisions: _useFillLevel ? 3 : 4,
                    label: _threshold?.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _threshold = value),
            activeColor: Colors.teal,
                  ),
          SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Fill: ${_fillLevel?.toStringAsFixed(1) ?? '1.0'}, Threshold: ${_threshold?.toStringAsFixed(1) ?? '0.2'}",
                  style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Checkbox(
                        value: _threshold == null,
                onChanged: (value) => setState(() => _threshold = value! ? null : (_useFillLevel ? 0.2 : 1.0)),
                activeColor: Colors.teal,
                      ),
              Text("No Shopping List", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
      child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
        ),
    ElevatedButton(
      onPressed: _name.trim().isEmpty
          ? null
          : () async {
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
      child: Text("Save"),
        ),
      ],
    );
  }
}
