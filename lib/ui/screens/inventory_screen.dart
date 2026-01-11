import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_event.dart';
import '../../logic/inventory/inventory_state.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Category filter options - all 9 categories plus "All"
  static const List<String> _categoryOptions = [
    'All',
    'Dairy',
    'Meat & Protein',
    'Vegetables',
    'Fruits',
    'Spices & Seasonings',
    'Pantry / Dry Goods',
    'Beverages',
    'Freezer',
    'Other',
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Load inventory on init
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState();
            }

            // Filter items based on selected category
            final filteredItems =
                _selectedCategory == 'All'
                    ? state.items
                    : state.items
                        .where((item) => item.category == _selectedCategory)
                        .toList();

            return Column(
              children: [
                // Storage Location Filter
                _buildFilterBar(theme),

                // Item List
                Expanded(
                  child:
                      filteredItems.isEmpty
                          ? _buildNoResultsState()
                          : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return InventoryItemCard(
                                item: item,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ItemDetailsScreen(item: item),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text('Delete Item'),
                                          content: Text(
                                            'Are you sure you want to delete "${item.name}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(ctx),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                context
                                                    .read<InventoryBloc>()
                                                    .add(
                                                      DeleteInventoryItem(
                                                        item.id,
                                                      ),
                                                    );
                                                Navigator.pop(ctx);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          } else if (state is InventoryError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Oops, we couldn't load your pantry.",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed:
                          () => context.read<InventoryBloc>().add(
                            LoadInventory(),
                          ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
        label: const Text("Add Item"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    final bool isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children:
              _categoryOptions.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? primaryColor
                                : (isDark
                                    ? Colors.grey[800]
                                    : const Color(0xFFF1F5F4)),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            isSelected
                                ? null
                                : Border.all(
                                  color:
                                      isDark
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!,
                                  width: 1,
                                ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items in $_selectedCategory',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to this category to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.kitchen, size: 80, color: Colors.green[300]),
          const SizedBox(height: 16),
          Text(
            "Your Smart Kitchen Assistant",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Reduce food waste, save money, and simplify your meal planning. Let's get your pantry organized.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddItemScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}
