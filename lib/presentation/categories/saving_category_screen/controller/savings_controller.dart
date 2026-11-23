import 'package:flutter/material.dart';

class SavingsController extends ChangeNotifier {
  // Balance and expense data
  double totalBalance = 7783.00;
  double totalExpense = 1187.40;
  
  // Savings goal data
  double savingsTarget = 20000.00;
  double currentSavings = 6000.00; // 30% of target
  
  // Selection state
  int selectedCategoryIndex = -1;
  
  // Savings categories
  final List<SavingsCategory> categories = [
    SavingsCategory(
      icon: Icons.flight,
      title: 'Travel',
      amount: 1500.00,
      target: 5000.00,
    ),
    SavingsCategory(
      icon: Icons.home,
      title: 'New House',
      amount: 2500.00,
      target: 10000.00,
    ),
    SavingsCategory(
      icon: Icons.directions_car,
      title: 'Car',
      amount: 1200.00,
      target: 8000.00,
    ),
    SavingsCategory(
      icon: Icons.favorite,
      title: 'Wedding',
      amount: 800.00,
      target: 15000.00,
    ),
  ];
  
  double get savingsProgress => (currentSavings / savingsTarget) * 100;
  
  String get progressMessage {
    if (savingsProgress >= 50) {
      return "Great progress! You're halfway there.";
    } else if (savingsProgress >= 30) {
      return "30% Of Your Expenses, Looks Good.";
    } else {
      return "Keep saving! Every bit counts.";
    }
  }
  
  void selectCategory(int index) {
    selectedCategoryIndex = index;
    notifyListeners();
  }
  
  bool isSelected(int index) {
    return selectedCategoryIndex == index;
  }
}

class SavingsCategory {
  final IconData icon;
  final String title;
  final double amount;
  final double target;
  
  SavingsCategory({
    required this.icon,
    required this.title,
    required this.amount,
    required this.target,
  });
  
  double get progress => (amount / target) * 100;
}
