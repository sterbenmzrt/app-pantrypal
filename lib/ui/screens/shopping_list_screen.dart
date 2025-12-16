import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../logic/shopping/shopping_bloc.dart';
import '../../logic/shopping/shopping_event.dart';
import '../../logic/shopping/shopping_state.dart';
import '../../data/models/shopping_item.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Shopping Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Item Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final newItem = ShoppingItem(
                    id: const Uuid().v4(),
                    name: text,
                    category: 'Uncategorized',
                  );
                  context.read<ShoppingBloc>().add(AddShoppingItem(newItem));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ShoppingBloc, ShoppingState>(
        builder: (context, state) {
          if (state.status == ShoppingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ShoppingStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          // Segregate items (example logic, simplified)
          // For now, we'll keep the "Suggested" static as a mockup/placeholder
          // and use "Your List" for the actual database items.
          final yourList = state.items;

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              const _SectionTitle('Your List'),
              if (yourList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Your list is empty. Add items!'),
                )
              else
                _CategoryCard(
                  title: 'My Items',
                  items:
                      yourList.map((item) => _CheckItem(item: item)).toList(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _CategoryCard({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              for (final item in items) ...[const Divider(height: 1), item],
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final ShoppingItem item;

  const _CheckItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (_) {
              context.read<ShoppingBloc>().add(ToggleShoppingItem(item));
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    decoration:
                        item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked ? Colors.grey : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Delete Item'),
                      content: Text(
                        'Remove "${item.name}" from your shopping list?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ShoppingBloc>().add(
                              DeleteShoppingItem(item.id),
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
          ),
        ],
      ),
    );
  }
}
