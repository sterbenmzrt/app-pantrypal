import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/shopping/shopping_bloc.dart';
import '../../logic/shopping/shopping_event.dart';
import '../../logic/shopping/shopping_state.dart';
import '../../data/models/shopping_list.dart';
import 'create_shopping_list_screen.dart';
import 'shopping_list_detail_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  void _showDeleteConfirmation(BuildContext context, ShoppingList list) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Shopping List'),
            content: Text(
              'Are you sure you want to delete "${list.title}"? This will also delete all items in this list.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  context.read<ShoppingBloc>().add(DeleteShoppingList(list.id));
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showArchiveConfirmation(BuildContext context, ShoppingList list) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Move to History'),
            content: Text(
              'Move "${list.title}" to history? It will be available for reuse and deleted after 7 days.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  context.read<ShoppingBloc>().add(
                    ArchiveShoppingList(list.id),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Move to History'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<ShoppingBloc, ShoppingState>(
        builder: (context, state) {
          if (state.status == ShoppingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ShoppingStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          final lists = state.shoppingLists;

          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Shopping Lists',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first shopping list to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const CreateShoppingListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Shopping List'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ShoppingBloc>().add(LoadShoppingLists());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                final itemCount = state.itemCounts[list.id] ?? 0;
                final checkedCount = state.checkedCounts[list.id] ?? 0;
                final progress =
                    itemCount == 0 ? 0.0 : checkedCount / itemCount;
                final isCompleted = itemCount > 0 && checkedCount == itemCount;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ShoppingListDetailScreen(listId: list.id),
                          ),
                        ).then((_) {
                          // Refresh the list when returning from detail screen
                          context.read<ShoppingBloc>().add(LoadShoppingLists());
                        });
                      },
                      onLongPress: () => _showDeleteConfirmation(context, list),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isCompleted
                                            ? Colors.green.withOpacity(0.1)
                                            : colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_circle
                                        : Icons.shopping_cart_outlined,
                                    color:
                                        isCompleted
                                            ? Colors.green
                                            : colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        list.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat(
                                              'MMM d, y',
                                            ).format(list.shoppingDate),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      () =>
                                          isCompleted
                                              ? _showArchiveConfirmation(
                                                context,
                                                list,
                                              )
                                              : _showDeleteConfirmation(
                                                context,
                                                list,
                                              ),
                                  icon: Icon(
                                    isCompleted
                                        ? Icons.history
                                        : Icons.delete_outline,
                                    color:
                                        isCompleted
                                            ? colorScheme.primary
                                            : colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  itemCount == 0
                                      ? 'No items'
                                      : '$checkedCount / $itemCount items',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (itemCount > 0) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompleted
                                        ? Colors.green
                                        : colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateShoppingListScreen(),
            ),
          ).then((_) {
            context.read<ShoppingBloc>().add(LoadShoppingLists());
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('New List'),
      ),
    );
  }
}
