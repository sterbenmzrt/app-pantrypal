import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/shopping/shopping_bloc.dart';
import '../../logic/shopping/shopping_event.dart';
import '../../logic/shopping/shopping_state.dart';
import '../../data/models/shopping_list.dart';

class ArchivedShoppingListsScreen extends StatefulWidget {
  const ArchivedShoppingListsScreen({Key? key}) : super(key: key);

  @override
  State<ArchivedShoppingListsScreen> createState() =>
      _ArchivedShoppingListsScreenState();
}

class _ArchivedShoppingListsScreenState
    extends State<ArchivedShoppingListsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShoppingBloc>().add(LoadArchivedLists());
  }

  void _showRestoreConfirmation(ShoppingList list) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Reuse Shopping List'),
            content: Text(
              'Reuse "${list.title}" by moving it back to your active lists?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  context.read<ShoppingBloc>().add(
                    RestoreShoppingList(list.id),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Reuse'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(ShoppingList list) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Permanently'),
            content: Text(
              'Permanently delete "${list.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  context.read<ShoppingBloc>().add(DeleteArchivedList(list.id));
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

  String _getDaysRemaining(DateTime? archivedAt) {
    if (archivedAt == null) return '';
    final expiryDate = archivedAt.add(const Duration(days: 7));
    final remaining = expiryDate.difference(DateTime.now()).inDays;
    if (remaining <= 0) return 'Expires today';
    if (remaining == 1) return '1 day remaining';
    return '$remaining days remaining';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping History'), elevation: 0),
      body: BlocBuilder<ShoppingBloc, ShoppingState>(
        builder: (context, state) {
          if (state.archiveStatus == ArchiveStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final archivedLists = state.archivedLists;

          if (archivedLists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 80,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No History Yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed shopping lists will appear here for reuse',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: archivedLists.length,
            itemBuilder: (context, index) {
              final list = archivedLists[index];
              final daysRemaining = _getDaysRemaining(list.archivedAt);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.archive_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    list.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                daysRemaining,
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showRestoreConfirmation(list),
                              icon: const Icon(Icons.replay, size: 18),
                              label: const Text('Reuse'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _showDeleteConfirmation(list),
                              icon: Icon(
                                Icons.delete_forever,
                                size: 18,
                                color: colorScheme.error,
                              ),
                              label: Text(
                                'Delete',
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
