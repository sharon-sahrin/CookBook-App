import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'admin_dashboard_screen.dart';
import 'add_edit_recipe_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;

    // Actual screens to display (excluding the Add button which is an action)
    final List<Widget> screens = [
      const HomeScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    // Build items for BottomNavigationBar with Add Recipe at index 1
    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        activeIcon: Icon(Icons.add_circle),
        label: 'Add Recipe',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    // Helper to map BottomNavigationBar index to screen index
    int getScreenIndex(int navIndex) {
      if (navIndex == 0) return 0;
      if (navIndex == 1) {
        return _selectedIndex; // Add Recipe button doesn't have a screen
      }
      return navIndex - 1;
    }

    // Helper to map screen index to BottomNavigationBar index
    int getNavIndex(int screenIndex) {
      if (screenIndex == 0) return 0;
      return screenIndex + 1;
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF5EE,
      ), // Match the light cream background in image
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: getNavIndex(_selectedIndex),
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditRecipeScreen()),
              );
              return;
            }
            setState(() => _selectedIndex = getScreenIndex(index));
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFFDF5E6), // Old Lace / Cream color
          selectedItemColor: Colors.orange.shade800,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: navItems,
        ),
      ),
    );
  }
}
