import 'package:flutter/material.dart';
import 'package:inventory_app/models/category.dart';
import 'package:inventory_app/services/inventory_manager.dart';
import 'package:inventory_app/utils/colors.dart';

class CategoryManagerDialog extends StatefulWidget {
  final InventoryManager manager;
  final List<Category> categories;
  final VoidCallback onRefresh;

  const CategoryManagerDialog({
    super.key,
    required this.manager,
    required this.categories,
    required this.onRefresh,
  });

  @override
  CategoryManagerDialogState createState() => CategoryManagerDialogState();
}

class CategoryManagerDialogState extends State<CategoryManagerDialog> {
  late List<Category> _localCategories;

  @override
  void initState() {
    super.initState();
    _localCategories = List.from(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Manage Categories"),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ReorderableListView(
          onReorder: _onReorder,
          children:
              _localCategories
                  .map((category) => _buildCategoryTile(category))
                  .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: () => _addCategory(context),
          child: const Text("Add Category"),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(Category category) {
    final lightColor = getCategoryLightColor(category.name);
    return ListTile(
      key: ValueKey(category.id),
      title: Text(category.name),
      tileColor: lightColor,
      trailing:
          category.name != 'Unsorted'
              ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await widget.manager.removeCategory(category.id!);
                  setState(() {
                    _localCategories.remove(category);
                  });
                  widget.onRefresh();
                },
              )
              : null,
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    String name = "";
    String selectedColor = colorOptions.first; 
    final added = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Category"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Category Name"),
                  onChanged: (value) => name = value,
                ),
                DropdownButtonFormField<String>(
                  value: selectedColor,
                  decoration: const InputDecoration(labelText: "Color"),
                  items:
                      colorOptions
                          .map(
                            (color) => DropdownMenuItem(
                              value: color,
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    color: availableColors[color]!['light'],
                                  ),
                                  const SizedBox(width: 10),
                                  Text(color),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => selectedColor = value ?? colorOptions.first,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await widget.manager.addCategory(Category(name: name));
                    if (!categoryColors.containsKey(name)) {
                      categoryColors[name] = availableColors[selectedColor]!;
                    }
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
    if (added == true && mounted) {
      final updatedCategories = await widget.manager.getCategories();
      setState(() => _localCategories = updatedCategories);
      widget.onRefresh();
      Navigator.pop(context);
    }
  }

  void _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final movedCategory = _localCategories.removeAt(oldIndex);
    _localCategories.insert(newIndex, movedCategory);
    for (int i = 0; i < _localCategories.length; i++) {
      await widget.manager.updateCategoryOrder(_localCategories[i].id!, i);
    }
    setState(() {});
    widget.onRefresh();
  }
}
