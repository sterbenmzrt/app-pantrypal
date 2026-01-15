import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/inventory_item.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_event.dart';
import '../../core/utils/number_helpers.dart';
import 'edit_item_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final InventoryItem item;
  const ItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late InventoryItem _item;

  // Map categories to asset images
  static const Map<String, String> _categoryImages = {
    'Dairy': 'assets/images/categories/dairy.png',
    'Meat & Protein': 'assets/images/categories/meat_protein.png',
    'Vegetables': 'assets/images/categories/vegetables.png',
    'Fruits': 'assets/images/categories/fruits.png',
    'Spices & Seasonings': 'assets/images/categories/spices_seasonings.png',
    'Pantry / Dry Goods': 'assets/images/categories/pantry_dry_goods.png',
    'Beverages': 'assets/images/categories/beverages.png',
    'Freezer': 'assets/images/categories/freezer.png',
    'Other': 'assets/images/categories/other.png',
  };

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditItemScreen(item: _item)),
    );
    if (result == true) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int daysRemaining =
        _item.expiryDate.difference(DateTime.now()).inDays;
    final String status = _statusFromDays(daysRemaining);
    final Color statusColor = _statusColor(status);
    final String imagePath =
        _categoryImages[_item.category] ?? _categoryImages['Other']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _navigateToEdit,
            tooltip: 'Edit Item',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Image Header - Full 1:1 Aspect Ratio
            AspectRatio(
              aspectRatio: 1, // 1:1 ratio
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _item.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _statusText(status, daysRemaining),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info Cards
                  _buildInfoCard(
                    context,
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: _item.category,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Quantity',
                    value:
                        '${NumberHelpers.formatQuantity(_item.quantity)} ${_item.unit}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Expiry Date',
                    value: _formatDate(_item.expiryDate),
                    valueColor: statusColor,
                  ),
                  if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.notes_outlined,
                      label: 'Notes',
                      value: _item.notes!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Item'),
            content: Text('Are you sure you want to delete "${_item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<InventoryBloc>().add(
                    DeleteInventoryItem(_item.id),
                  );
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Go back to inventory
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
        return daysRemaining == 1
            ? 'Expires tomorrow'
            : 'Expires in $daysRemaining days';
      case 'expired':
        return daysRemaining == -1
            ? 'Expired yesterday'
            : 'Expired ${daysRemaining.abs()} days ago';
      default:
        return '';
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
