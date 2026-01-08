import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_state.dart';
import '../../logic/user/user_bloc.dart';
import '../../logic/user/user_state.dart';
import '../../data/models/inventory_item.dart';
import '../../core/utils/number_helpers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          int totalItems = 0;
          int lowStock = 0;
          int expiringSoon = 0;
          List<InventoryItem> recentItems = [];

          if (state is InventoryLoaded) {
            totalItems = state.items.length;
            lowStock =
                state.items
                    .where((i) => i.quantity <= 2)
                    .length; // Threshold example
            final now = DateTime.now();
            expiringSoon =
                state.items.where((i) {
                  // Expiring within 3 days
                  return i.expiryDate.difference(now).inDays <= 3 &&
                      i.expiryDate.isAfter(now);
                }).length;
            recentItems = state.items.take(3).toList();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  final userName =
                      userState.profile.name.isNotEmpty
                          ? userState.profile.name
                          : 'User';
                  return Text(
                    'Hi, $userName',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Here is your pantry summary',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Items',
                      value: '$totalItems',
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Low Stock',
                      value: '$lowStock',
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Expiring',
                      value: '$expiringSoon',
                      icon: Icons.timer,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Recipes',
                      value: '0',
                      icon: Icons.menu_book,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (recentItems.isEmpty)
                const Text('No recent items added.')
              else
                ...recentItems.map(
                  (item) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(item.name[0].toUpperCase()),
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        'Exp: ${item.expiryDate.toString().split(' ')[0]}',
                      ),
                      trailing: Text(
                        '${NumberHelpers.formatQuantity(item.quantity)} ${item.unit}',
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
