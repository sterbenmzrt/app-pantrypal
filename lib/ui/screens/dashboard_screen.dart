import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_event.dart';
import '../../logic/inventory/inventory_state.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load inventory on init
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return InventoryItemCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailsScreen(item: item),
                      ),
                    );
                  },
                  onDelete: () {
                    context.read<InventoryBloc>().add(
                      DeleteInventoryItem(item.id),
                    );
                  },
                );
              },
            );
          } else if (state is InventoryError) {
            return Center(child: Text("Error: ${state.message}"));
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
        backgroundColor: Theme.of(context).primaryColor,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
