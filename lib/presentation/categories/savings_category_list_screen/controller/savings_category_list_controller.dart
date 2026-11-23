import 'package:flutter/material.dart';

class SavingsCategoryListController extends ChangeNotifier {
  // Travel savings data
  double goal = 1962.93;
  double amountSaved = 653.31;
  String categoryName = 'Travel';
  IconData categoryIcon = Icons.flight;
  
  // Progress calculation
  double get progressPercentage => (amountSaved / goal) * 100;
  
  // Status message
  String get statusMessage {
    if (progressPercentage >= 50) {
      return "Great progress! You're halfway there.";
    } else if (progressPercentage >= 30) {
      return "30% Of Your Expenses, Looks Good.";
    } else {
      return "Keep saving! Every bit counts.";
    }
  }
  
  // Transaction history
  final List<SavingsTransaction> transactions = [
    SavingsTransaction(
      title: 'Travel Deposit',
      amount: 217.77,
      dateTime: DateTime(2024, 4, 30, 19, 56),
      isCancelled: false,
    ),
    SavingsTransaction(
      title: 'Travel Deposit',
      amount: 217.77,
      dateTime: DateTime(2024, 4, 14, 17, 42),
      isCancelled: true,
    ),
    SavingsTransaction(
      title: 'Travel Deposit',
      amount: 217.77,
      dateTime: DateTime(2024, 4, 2, 12, 30),
      isCancelled: false,
    ),
  ];
  
  // Add new savings
  void addSavings(double amount) {
    amountSaved += amount;
    notifyListeners();
  }
  
  // Get transactions by month
  Map<String, List<SavingsTransaction>> get transactionsByMonth {
    Map<String, List<SavingsTransaction>> grouped = {};
    for (var transaction in transactions) {
      String monthKey = _getMonthKey(transaction.dateTime);
      grouped.putIfAbsent(monthKey, () => []).add(transaction);
    }
    return grouped;
  }
  
  String _getMonthKey(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }
}

class SavingsTransaction {
  final String title;
  final double amount;
  final DateTime dateTime;
  final bool isCancelled;
  
  SavingsTransaction({
    required this.title,
    required this.amount,
    required this.dateTime,
    required this.isCancelled,
  });
  
  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day.toString().padLeft(2, '0')}';
  }
}
