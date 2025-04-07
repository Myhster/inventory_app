import 'package:flutter/material.dart';

class AddProductDialog extends StatefulWidget {
  final String? initialName;
  final List<String> categories;
  final String? selectedCategory;

  const AddProductDialog({
    super.key,
    this.initialName,
    required this.categories,
    this.selectedCategory,
  });

  static String? _lastSelectedCategory;

  @override
  AddProductDialogState createState() => AddProductDialogState();
}

class AddProductDialogState extends State<AddProductDialog> {
  late TextEditingController _qtyController;
  late TextEditingController _nameController;
  late String _category;
  bool _useFillLevel = false;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: "1");
    _nameController = TextEditingController(text: widget.initialName ?? "");

    if (widget.selectedCategory != null) {
      _category = widget.selectedCategory!;
    } else {
      _category =
          AddProductDialog._lastSelectedCategory ??
          (widget.categories.isNotEmpty ? widget.categories.first : "Unsorted");
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions =
        widget.categories.isNotEmpty ? widget.categories : ['Unsorted'];
    return AlertDialog(
      title: Text(
        widget.selectedCategory != null
            ? "Add Product to '${widget.selectedCategory}'"
            : "Add Product Manually",
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              controller: _nameController,
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 16),
            if (!_useFillLevel)
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red[400],
                    ),
                    onPressed: () {
                      int current = int.tryParse(_qtyController.text) ?? 1;
                      if (current > 0)
                        _qtyController.text = (current - 1).toString();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isEmpty || int.parse(value) < 0)
                          _qtyController.text = "0";
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.green[400],
                    ),
                    onPressed:
                        () =>
                            _qtyController.text =
                                (int.parse(_qtyController.text) + 1).toString(),
                  ),
                ],
              ),
            SizedBox(height: 16),
            if (widget.selectedCategory == null)
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items:
                    categoryOptions
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value ?? categoryOptions.first;
                    AddProductDialog._lastSelectedCategory = _category;
                  });
                },
              ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text("Use Fill Level", style: TextStyle(fontSize: 16)),
              value: _useFillLevel,
              onChanged:
                  (value) => setState(() => _useFillLevel = value ?? false),
              activeColor: Colors.teal,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed:
              _nameController.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                    context,
                    ProductData(
                      _nameController.text,
                      _useFillLevel ? 1 : int.parse(_qtyController.text),
                      _category,
                      _useFillLevel,
                    ),
                  ),
          child: Text("Confirm"),
        ),
      ],
    );
  }
}

class ProductData {
  final String name;
  final int quantity;
  final String category;
  final bool useFillLevel;

  ProductData(
    this.name,
    this.quantity,
    this.category, [
    this.useFillLevel = false,
  ]);
}
