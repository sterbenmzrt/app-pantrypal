import 'package:flutter/material.dart';
import '../../data/models/inventory_item.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/utils/number_helpers.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

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

  const InventoryItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = DateHelpers.getStatusColor(item.expiryDate);
    final imagePath =
        _categoryImages[item.category] ?? _categoryImages['Other']!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Icon(Icons.kitchen, color: statusColor),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "${NumberHelpers.formatQuantity(item.quantity)} ${item.unit} • ${item.category}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              DateHelpers.getExpiryText(item.expiryDate),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
