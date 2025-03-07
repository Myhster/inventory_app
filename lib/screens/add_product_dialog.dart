import 'package:flutter/material.dart';

class AddProductDialog extends StatefulWidget {
  final String? initialName;
  final List<String> categories;

  const AddProductDialog({
    super.key,
    this.initialName,
    required this.categories,
  });

  @override
  AddProductDialogState createState() => AddProductDialogState();
}

class AddProductDialogState extends State<AddProductDialog> {
  late TextEditingController _qtyController;
  late String _name;
  late String _category;
  bool _useFillLevel = false;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: "1");
    _name = widget.initialName ?? "";
    _category =
        widget.categories.isNotEmpty ? widget.categories.first : "Unsortiert";
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions =
        widget.categories.isNotEmpty ? widget.categories : ['Unsortiert'];
    return AlertDialog(
      title: Text(
        widget.initialName != null ? "Confirm Product" : "Add Product Manually",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.initialName != null)
            Text("Barcode: ${widget.initialName!.split(' ').last}"),
          TextField(
            decoration: const InputDecoration(labelText: "Name"),
            onChanged: (value) => setState(() => _name = value),
            controller:
                widget.initialName != null
                    ? TextEditingController(text: _name)
                    : null,
          ),
          if (!_useFillLevel) // Fix: Menge nur bei !useFillLevel
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    int current = int.tryParse(_qtyController.text) ?? 1;
                    if (current > 1)
                      _qtyController.text = (current - 1).toString();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: "Quantity"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isEmpty || int.parse(value) < 1)
                        _qtyController.text = "1";
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed:
                      () =>
                          _qtyController.text =
                              (int.parse(_qtyController.text) + 1).toString(),
                ),
              ],
            ),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: "Category"),
            items:
                categoryOptions
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
            onChanged:
                (value) =>
                    setState(() => _category = value ?? categoryOptions.first),
          ),
          CheckboxListTile(
            title: const Text("Use Fill Level"),
            value: _useFillLevel,
            onChanged:
                (value) => setState(() => _useFillLevel = value ?? false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed:
              _name.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                    context,
                    ProductData(
                      _name,
                      _useFillLevel
                          ? 1
                          : int.parse(
                            _qtyController.text,
                          ), // Fix: Menge 1 bei useFillLevel
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
