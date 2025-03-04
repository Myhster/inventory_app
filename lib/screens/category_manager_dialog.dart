import 'package:flutter/material.dart';
import 'package:inventory_app/models/category.dart';
import 'package:inventory_app/services/inventory_manager.dart';

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
        height: 400, // Feste Höhe für Scrollbarkeit
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
    return ListTile(
      key: ValueKey(category.id), // Wichtig für ReorderableListView
      title: Text(category.name),
      trailing:
          category.name != 'Unsortiert'
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
    final added = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Category"),
            content: TextField(
              decoration: const InputDecoration(labelText: "Category Name"),
              onChanged: (value) => name = value,
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
    if (newIndex > oldIndex) newIndex -= 1; // Anpassung für Flutter-Verhalten
    final movedCategory = _localCategories.removeAt(oldIndex);
    _localCategories.insert(newIndex, movedCategory);

    // Aktualisiere orderIndex in der Datenbank
    for (int i = 0; i < _localCategories.length; i++) {
      await widget.manager.updateCategoryOrder(_localCategories[i].id!, i);
    }
    setState(() {});
    widget.onRefresh(); // Aktualisiert InventoryScreen
  }
}
