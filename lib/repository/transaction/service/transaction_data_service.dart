import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/category/service/category_service.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:monaymanagment/repository/transaction/model/transaction_model.dart';

class TransactionDataService extends ChangeNotifier {
  static TransactionDataService? _instance;
  bool _disposed = false;

  // Singleton pattern
  factory TransactionDataService() {
    if (_instance == null || _instance!._disposed) {
      _instance = TransactionDataService._internal();
    }
    return _instance!;
  }
  TransactionDataService._internal();

  // CategoryService kept for potential future use
  // ignore: unused_field
  final CategoryService _categoryService = CategoryService();
  final AuthService _authService = AuthService();
  final GuestStorageService _guestStorage = GuestStorageService.instance;

  // Real transaction data using new API
  List<SubTransactionWithCategory> _allSubTransactions = [];
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isDataLoaded => _isDataLoaded;
  String? get errorMessage => _errorMessage;
  List<SubTransactionWithCategory> get allSubTransactions =>
      _allSubTransactions;

  // Legacy getter for backward compatibility
  List<CategoryTransactionResponse> get allTransactions => [];

  // Calculated financial data using new API
  double get totalIncome {
    double total = 0.0;
    for (var subTransaction in _allSubTransactions) {
      if (subTransaction.amount > 0) {
        total += subTransaction.amount;
      }
    }
    return total;
  }

  double get totalExpense {
    double total = 0.0;
    for (var subTransaction in _allSubTransactions) {
      if (subTransaction.amount < 0) {
        total += subTransaction.amount.abs();
      }
    }
    return total;
  }

  double get totalBalance => totalIncome - totalExpense;

  // Get transactions for specific time period (deprecated - kept for compatibility)
  List<CategoryTransactionResponse> getTransactionsForPeriod(String period) {
    // Note: This method is deprecated as we now use _allSubTransactions
    // Keeping for backward compatibility but returns empty list
    return <CategoryTransactionResponse>[];
  }

  // Get chart data for analysis screen
  List<ChartData> getChartData(String period) {
    final now = DateTime.now();
    final chartData = <ChartData>[];

    switch (period.toLowerCase()) {
      case 'daily':
        // Show current week: Sunday to Saturday
        final currentWeekday = now.weekday;
        final daysFromSunday =
            currentWeekday % 7; // Sunday = 0, Monday = 1, etc.
        final weekStart = now.subtract(Duration(days: daysFromSunday));

        final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sa'];

        for (int i = 0; i < 7; i++) {
          final date = weekStart.add(Duration(days: i));
          final dayData = _getDayTransactionData(date);
          chartData.add(
            ChartData(
              day: dayNames[i],
              income: dayData['income'] ?? 0.0,
              expense: dayData['expense'] ?? 0.0,
            ),
          );
        }
        break;
      case 'weekly':
        // Show 4 weeks of current month
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final firstWeekdayOfMonth = firstDayOfMonth.weekday % 7;
        final firstSundayOfMonth = firstDayOfMonth.subtract(
          Duration(days: firstWeekdayOfMonth),
        );

        for (int i = 0; i < 4; i++) {
          final weekStart = firstSundayOfMonth.add(Duration(days: i * 7));
          final weekEnd = weekStart.add(Duration(days: 6));
          final weekData = _getWeekTransactionData(weekStart);

          // Format week range
          final weekLabel =
              '${weekStart.day}-${weekEnd.day} ${_getMonthName(weekStart.month)}';
          chartData.add(
            ChartData(
              day: weekLabel,
              income: weekData['income'] ?? 0.0,
              expense: weekData['expense'] ?? 0.0,
            ),
          );
        }
        break;
      case 'monthly':
        // Show all 12 months of current year
        for (int month = 1; month <= 12; month++) {
          final monthName = _getMonthName(month);
          final monthData = _getMonthTransactionData(
            DateTime(now.year, month, 1),
          );
          chartData.add(
            ChartData(
              day: monthName,
              income: monthData['income'] ?? 0.0,
              expense: monthData['expense'] ?? 0.0,
            ),
          );
        }
        break;
      case 'yearly':
        // Show current year only
        final yearData = _getYearTransactionData(now.year);
        chartData.add(
          ChartData(
            day: now.year.toString(),
            income: yearData['income'] ?? 0.0,
            expense: yearData['expense'] ?? 0.0,
          ),
        );
        break;
    }

    return chartData;
  }

  // Load all sub-transactions using new API endpoint
  Future<void> loadAllTransactions() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    _setLoading(true);
    _setErrorMessage(null);

    try {
      if (_guestStorage.isGuestMode) {
        _allSubTransactions = _guestStorage.guestSubTransactions;
        _isDataLoaded = true;
        return;
      }

      const String apiUrl =
          'https://money-manager-web.onrender.com/api/categories/all/sub-transactions?year=all';
      print('Fetching all sub-transactions: $apiUrl');

      // Get JWT token for authentication
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(
        'Get all sub-transactions response status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Get all sub-transactions response body: ${response.body}');

        final allSubTransactionsResponse = AllSubTransactionsResponse.fromJson(
          jsonData,
        );
        _allSubTransactions = allSubTransactionsResponse.subTransactions;
        _isDataLoaded = true;

        print('Loaded ${_allSubTransactions.length} sub-transactions');
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode >= 500) {
        // Server error - log but don't fail completely, just use empty data
        print(
          'Server error (${response.statusCode}) loading all sub-transactions. Using empty data.',
        );
        _allSubTransactions = [];
        _isDataLoaded = true; // Mark as loaded so we don't retry constantly
        print('Using empty transaction list due to server error');
      } else {
        throw Exception(
          'Failed to load sub-transactions: ${response.statusCode}',
        );
      }
    } catch (e) {
      _setErrorMessage('Failed to load transaction data: $e');
      print('Error loading all sub-transactions: $e');
      // Don't set as loaded on error to allow retry
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  DateTime _parseTransactionDate(String dateString) {
    try {
      // Parse date string like "September 25, 2025"
      final parts = dateString.split(' ');
      if (parts.length >= 3) {
        final month = _getMonthNumber(parts[0]);
        final day = int.parse(parts[1].replaceAll(',', ''));
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $dateString, $e');
    }
    return DateTime.now();
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return months[monthName] ?? 1;
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  Map<String, double> _getDayTransactionData(DateTime date) {
    double income = 0.0;
    double expense = 0.0;

    for (var subTransaction in _allSubTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      if (transactionDate.day == date.day &&
          transactionDate.month == date.month &&
          transactionDate.year == date.year) {
        if (subTransaction.amount > 0) {
          income += subTransaction.amount;
        } else {
          expense += subTransaction.amount.abs();
        }
      }
    }

    return {'income': income, 'expense': expense};
  }

  Map<String, double> _getWeekTransactionData(DateTime weekStart) {
    double income = 0.0;
    double expense = 0.0;
    final weekEnd = weekStart.add(Duration(days: 6));

    for (var subTransaction in _allSubTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      if (transactionDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
          transactionDate.isBefore(weekEnd.add(Duration(days: 1)))) {
        if (subTransaction.amount > 0) {
          income += subTransaction.amount;
        } else {
          expense += subTransaction.amount.abs();
        }
      }
    }

    return {'income': income, 'expense': expense};
  }

  Map<String, double> _getMonthTransactionData(DateTime month) {
    double income = 0.0;
    double expense = 0.0;

    for (var subTransaction in _allSubTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      if (transactionDate.month == month.month &&
          transactionDate.year == month.year) {
        if (subTransaction.amount > 0) {
          income += subTransaction.amount;
        } else {
          expense += subTransaction.amount.abs();
        }
      }
    }

    return {'income': income, 'expense': expense};
  }

  Map<String, double> _getYearTransactionData(int year) {
    double income = 0.0;
    double expense = 0.0;

    for (var subTransaction in _allSubTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      if (transactionDate.year == year) {
        if (subTransaction.amount > 0) {
          income += subTransaction.amount;
        } else {
          expense += subTransaction.amount.abs();
        }
      }
    }

    return {'income': income, 'expense': expense};
  }

  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    if (_disposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Reset singleton instance
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }
}

class ChartData {
  final String day;
  final double income;
  final double expense;

  ChartData({required this.day, required this.income, required this.expense});
}
