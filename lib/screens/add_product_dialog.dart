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
    _category = widget.selectedCategory ??
        (widget.categories.isNotEmpty ? widget.categories.first : "Unsorted");
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions = widget.categories.isNotEmpty ? widget.categories : ['Unsorted'];
    return AlertDialog(
      title: Text(
        widget.selectedCategory != null
            ? "Add Product to '${widget.selectedCategory}'"
            : "Add Product Manually",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Name"),
            controller: _nameController,
            onChanged: (value) => setState(() {}),
          ),
          if (!_useFillLevel)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    int current = int.tryParse(_qtyController.text) ?? 1;
                    if (current > 0) _qtyController.text = (current - 1).toString();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: "Quantity"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isEmpty || int.parse(value) < 0) _qtyController.text = "0";
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _qtyController.text = (int.parse(_qtyController.text) + 1).toString(),
                ),
              ],
            ),
          if (widget.selectedCategory == null)
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: "Category"),
              items: categoryOptions
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
              onChanged: (value) => setState(() => _category = value ?? categoryOptions.first),
          ),
          CheckboxListTile(
            title: const Text("Use Fill Level"),
            value: _useFillLevel,
            onChanged: (value) => setState(() => _useFillLevel = value ?? false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _nameController.text.trim().isEmpty
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
          child: const Text("Confirm"),
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
