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

  final List<Widget> _screens = [
    const DashboardScreen(),
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
      'My Pantry',
      'Recipes & Meal Plan',
      'Shopping List',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Show archive icon only on Shopping List tab (index 3)
          if (_currentIndex == 3)
            IconButton(
              onPressed: _navigateToArchive,
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'Archived Lists',
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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
            label: "Shopping",
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
