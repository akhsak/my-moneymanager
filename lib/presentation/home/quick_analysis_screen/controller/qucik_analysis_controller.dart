import 'package:flutter/material.dart';

class QuickAnalysisController extends ChangeNotifier {
  // Savings Goal Data
  double _savingsProgress = 0.25; // 25% progress
  double get savingsProgress => _savingsProgress;

  // Weekly Summary Data
  double _revenueLastWeek = 4000.00;
  double _foodLastWeek = 100.00;
  
  double get revenueLastWeek => _revenueLastWeek;
  double get foodLastWeek => _foodLastWeek;

  // Expense Chart Data
  List<WeeklyExpense> _weeklyExpenses = [
    WeeklyExpense(week: '1st Week', amount: 2000.0),
    WeeklyExpense(week: '2nd Week', amount: 3500.0),
    WeeklyExpense(week: '3rd Week', amount: 12000.0), // Highest
    WeeklyExpense(week: '4th Week', amount: 8000.0),
  ];

  List<WeeklyExpense> get weeklyExpenses => _weeklyExpenses;

  // Transaction Data
  List<Transaction> _transactions = [
    Transaction(
      title: 'Salary',
      time: '18:27 - April 30',
      category: 'Monthly',
      amount: 4000.00,
      icon: Icons.attach_money,
      isIncome: true,
    ),
    Transaction(
      title: 'Groceries',
      time: '17:00 - April 24',
      category: 'Pantry',
      amount: 100.00,
      icon: Icons.shopping_bag,
      isIncome: false,
    ),
    Transaction(
      title: 'Rent',
      time: '8:30 - April 15',
      category: 'Rent',
      amount: 674.40,
      icon: Icons.key,
      isIncome: false,
    ),
  ];

  List<Transaction> get transactions => _transactions;

  // Chart Y-axis values
  List<double> get chartYAxisValues => [1000, 5000, 10000, 15000];
  
  // Get maximum expense for chart scaling
  double get maxExpense {
    if (_weeklyExpenses.isEmpty) return 15000;
    return _weeklyExpenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  // Get normalized height for chart bars (0.0 to 1.0)
  double getNormalizedHeight(double amount) {
    return amount / maxExpense;
  }
}

class WeeklyExpense {
  final String week;
  final double amount;

  WeeklyExpense({
    required this.week,
    required this.amount,
  });
}

class Transaction {
  final String title;
  final String time;
  final String category;
  final double amount;
  final IconData icon;
  final bool isIncome;

  Transaction({
    required this.title,
    required this.time,
    required this.category,
    required this.amount,
    required this.icon,
    required this.isIncome,
  });
}
