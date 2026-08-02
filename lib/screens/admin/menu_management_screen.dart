import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _store = AppDataStore();
  final _categories = MenuCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addItem(MenuCategory category) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Menu Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(category.label,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Paneer Tikka',
                  labelText: '${category.label.toUpperCase()} – NEW ITEM',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = ctrl.text.trim();
                        if (name.isNotEmpty) {
                          setState(() {
                            _store.menuItems[category]!.add(MenuItem(
                              id: 'm${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                            ));
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"$name" added to ${category.label}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editItem(MenuCategory category, MenuItem item) {
    final ctrl = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Menu Item'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Item Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                setState(() => item.name = name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(MenuCategory category, MenuItem item) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Item',
      message: 'Remove "${item.name}" from ${category.label}?',
      confirmLabel: 'Delete',
      confirmColor: AppTheme.error,
    );
    if (confirmed == true) {
      setState(() => _store.menuItems[category]!.remove(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Menu Manager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Configure catering menus', style: TextStyle(fontSize: 11, color: Colors.white60)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: _categories
              .map((c) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.label),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_store.menuItems[c]!.length}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final items = _store.menuItems[category]!;
          return Column(
            children: [
              // Add button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _addItem(category),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('Add Item to ${category.label}'),
                  ),
                ),
              ),
              // Items list
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.restaurant_menu_outlined,
                        title: 'No items yet',
                        message: 'Add your first menu item above.',
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: items.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = items.removeAt(oldIndex);
                            items.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _MenuItemTile(
                            key: ValueKey(item.id),
                            item: item,
                            index: index + 1,
                            onEdit: () => _editItem(category, item),
                            onDelete: () => _deleteItem(category, item),
                            onToggle: () => setState(() => item.isActive = !item.isActive),
                          );
                        },
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _MenuItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.isActive ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: item.isActive ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                  decoration: item.isActive ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
            // Toggle (eye icon)
            IconButton(
              icon: Icon(
                item.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: item.isActive ? AppTheme.accent : AppTheme.textSecondary,
              ),
              onPressed: onToggle,
              tooltip: item.isActive ? 'Deactivate' : 'Activate',
            ),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
            // Drag handle
            const Icon(Icons.drag_handle, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
