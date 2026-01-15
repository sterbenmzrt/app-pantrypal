import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_state.dart';
import '../../logic/user/user_bloc.dart';
import '../../logic/user/user_state.dart';
import '../../data/models/inventory_item.dart';
import '../../core/utils/number_helpers.dart';
import '../../core/utils/date_helpers.dart';
import 'item_details_screen.dart';
import 'add_item_screen.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({Key? key, this.onNavigateToTab}) : super(key: key);

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          int totalItems = 0;
          int lowStock = 0;
          int expiringSoon = 0;
          int freshItems = 0;
          List<InventoryItem> recentItems = [];
          List<InventoryItem> expiringItems = [];

          if (state is InventoryLoaded) {
            totalItems = state.items.length;
            lowStock = state.items.where((i) => i.quantity <= 2).length;
            final now = DateTime.now();

            expiringItems =
                state.items.where((i) {
                  return i.expiryDate.difference(now).inDays <= 3 &&
                      i.expiryDate.isAfter(now);
                }).toList();
            expiringSoon = expiringItems.length;

            freshItems =
                state.items.where((i) {
                  return i.expiryDate.difference(now).inDays > 7;
                }).length;

            recentItems = state.items.take(5).toList();
          }

          return CustomScrollView(
            slivers: [
              // Header with greeting - simplified (no gradients)
              SliverToBoxAdapter(child: _buildHeader(context, isDark)),

              // Quick Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pantry Overview',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatsGrid(
                        context,
                        totalItems: totalItems,
                        lowStock: lowStock,
                        expiringSoon: expiringSoon,
                        freshItems: freshItems,
                        isDark: isDark,
                        onNavigateToTab: onNavigateToTab,
                      ),
                    ],
                  ),
                ),
              ),

              // Expiring Soon Alert Section
              if (expiringItems.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildExpiringSection(context, expiringItems, isDark),
                ),

              // Quick Actions
              SliverToBoxAdapter(child: _buildQuickActions(context, isDark)),

              // Recent Items Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expiring Soon',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (recentItems.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            if (onNavigateToTab != null) {
                              onNavigateToTab!(1);
                            }
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Recent Items List
              if (recentItems.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptyRecentItems(context, isDark),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= recentItems.length) return null;
                      return _buildRecentItemCard(
                        context,
                        recentItems[index],
                        isDark,
                      );
                    }, childCount: recentItems.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final userName =
              userState.profile.name.isNotEmpty
                  ? userState.profile.name.split(' ').first
                  : 'User';

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(greetingIcon, color: theme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          greeting,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your pantry efficiently',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.kitchen_rounded,
                  color: theme.primaryColor,
                  size: 28,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalItems,
    required int lowStock,
    required int expiringSoon,
    required int freshItems,
    required bool isDark,
    void Function(int)? onNavigateToTab,
  }) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Items',
          value: '$totalItems',
          icon: Icons.inventory_2_rounded,
          color: theme.colorScheme.primary,
          isDark: isDark,
          onTap: onNavigateToTab != null ? () => onNavigateToTab!(1) : null,
        ),
        _StatCard(
          title: 'Low Stock',
          value: '$lowStock',
          icon: Icons.trending_down_rounded,
          color: Colors.orange,
          isDark: isDark,
          onTap: onNavigateToTab != null ? () => onNavigateToTab!(1) : null,
        ),
        _StatCard(
          title: 'Expiring Soon',
          value: '$expiringSoon',
          icon: Icons.alarm_rounded,
          color: Colors.red,
          isDark: isDark,
          onTap: onNavigateToTab != null ? () => onNavigateToTab!(1) : null,
        ),
        _StatCard(
          title: 'Fresh Items',
          value: '$freshItems',
          icon: Icons.eco_rounded,
          color: Colors.green,
          isDark: isDark,
          onTap: onNavigateToTab != null ? () => onNavigateToTab!(1) : null,
        ),
      ],
    );
  }

  Widget _buildExpiringSection(
    BuildContext context,
    List<InventoryItem> expiringItems,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.red.withOpacity(0.15)
                : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expiring Soon Alert',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.red[300] : Colors.red[700],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${expiringItems.length} item${expiringItems.length > 1 ? 's' : ''} expiring within 3 days',
                      style: TextStyle(
                        color: isDark ? Colors.red[200] : Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                expiringItems.take(5).map((item) {
                  final imagePath =
                      _categoryImages[item.category] ??
                      _categoryImages['Other']!;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailsScreen(item: item),
                        ),
                      );
                    },
                    child: Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        child: ClipOval(
                          child: Image.asset(
                            imagePath,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.kitchen,
                                  color: Colors.red,
                                  size: 14,
                                ),
                          ),
                        ),
                      ),
                      label: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.red[200] : Colors.red[700],
                        ),
                      ),
                      backgroundColor:
                          isDark
                              ? Colors.red.withOpacity(0.1)
                              : Colors.red.withOpacity(0.05),
                      side: BorderSide(color: Colors.red.withOpacity(0.2)),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Add Item',
                  color: theme.primaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddItemScreen()),
                    );
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Find Recipe',
                  color: const Color(0xFFFF6B6B),
                  onTap: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(2);
                    }
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Grocery List',
                  color: const Color(0xFF7C4DFF),
                  onTap: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(3);
                    }
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentItems(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No items in your pantry',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start adding items to track your inventory',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemCard(
    BuildContext context,
    InventoryItem item,
    bool isDark,
  ) {
    final statusColor = DateHelpers.getStatusColor(item.expiryDate);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  isDark
                      ? Border.all(color: Colors.grey[700]!, width: 1)
                      : null,
            ),
            child: Row(
              children: [
                // Category image with status indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _categoryImages[item.category] ??
                          _categoryImages['Other']!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.kitchen, color: statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${NumberHelpers.formatQuantity(item.quantity)} ${item.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Expiry status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateHelpers.getExpiryText(item.expiryDate),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return Material(
      color: isDark ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                isDark ? Border.all(color: Colors.grey[700]!, width: 1) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                isDark ? Border.all(color: Colors.grey[700]!, width: 1) : null,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
