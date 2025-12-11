import 'package:flutter/material.dart';
import '../../data/models/inventory_item.dart';

class ItemDetailsScreen extends StatelessWidget {
  final InventoryItem item;
  const ItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int daysRemaining = item.expiryDate.difference(DateTime.now()).inDays;
    final String status = _statusFromDays(daysRemaining);
    final Color statusColor = _statusColor(status);

    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image placeholder (no imageUrl in model)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://via.placeholder.com/600x400?text=${Uri.encodeComponent(item.name)}',
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          // Title & status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(_statusText(status, daysRemaining)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Category: ${item.category}'),
          const SizedBox(height: 8),
          Text('Quantity: ${item.quantity} ${item.unit}'),
          const SizedBox(height: 8),
          Text('Purchased: ${_formatDate(item.purchaseDate)}'),
          const SizedBox(height: 8),
          Text('Added: ${_formatDate(item.addedDate)}'),
          const SizedBox(height: 8),
          Text('Expires: ${_formatDate(item.expiryDate)}'),
          if (item.notes != null) ...[
            const SizedBox(height: 8),
            Text('Notes: ${item.notes}')
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Use Some'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add More'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Suggestions section
          Text('Use-Up-Soon Suggestions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const _SuggestionTile(title: 'Vibrant Garden Salad'),
          const _SuggestionTile(title: 'Classic Tomato Pasta'),
          const _SuggestionTile(title: 'Fluffy Berry Pancakes'),
        ],
      ),
    );
  }

  String _statusFromDays(int daysRemaining) {
    if (daysRemaining < 0) return 'expired';
    if (daysRemaining <= 3) return 'soon';
    return 'good';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'good':
        return const Color(0xFF28A745);
      case 'soon':
        return const Color(0xFFFFC107);
      case 'expired':
        return const Color(0xFFDC3545);
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status, int daysRemaining) {
    switch (status) {
      case 'good':
      case 'soon':
        return 'Expires in $daysRemaining days';
      case 'expired':
        return 'Expired ${daysRemaining.abs()} days ago';
      default:
        return '';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _SuggestionTile extends StatelessWidget {
  final String title;
  const _SuggestionTile({required this.title});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(title),
      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
    );
  }
}
