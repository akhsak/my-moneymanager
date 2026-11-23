import 'package:flutter/material.dart';

class BottomNavigationController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Navigation method
  void navigateToScreen(BuildContext context, int index) {
    _currentIndex = index;
    notifyListeners();

    // You can add navigation logic here if needed
    // For now, just updating the selected index
  }

  // Navigation items data
  List<NavigationItem> get navigationItems => [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Analysis',
    ),
    NavigationItem(
      icon: Icons.swap_horiz,
      activeIcon: Icons.swap_horiz,
      label: 'Transaction',
    ),
    NavigationItem(
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers,
      label: 'Category',
    ),
    NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Loan',
    ),
    // NavigationItem(
    //   icon: Icons.person_outline,
    //   activeIcon: Icons.person,
    //   label: 'Profile',
    // ),
  ];
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
