import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Ensure this uses the new file
import 'inventory_screen.dart';
import 'profile_screen.dart';
import 'recipe_search_screen.dart';
import 'shopping_list_screen.dart';
import 'archived_shopping_lists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _setCurrentIndex(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _screens => [
    DashboardScreen(onNavigateToTab: _setCurrentIndex),
    const InventoryScreen(),
    const RecipeSearchScreen(),
    const ShoppingListScreen(),
    const ProfileScreen(),
  ];

  void _navigateToArchive() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArchivedShoppingListsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Dashboard',
      'Inventory',
      'Recipes & Meal Plan',
      'Grocery List',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Show notification icon on Dashboard tab (index 0)
          if (_currentIndex == 0)
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Notifications',
                ),
                // Notification badge (placeholder for future development)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          // Show archive icon only on Shopping List tab (index 3)
          if (_currentIndex == 3)
            IconButton(
              onPressed: _navigateToArchive,
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'History',
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _setCurrentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: "Inventory",
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: "Recipes",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "Grocery List",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
