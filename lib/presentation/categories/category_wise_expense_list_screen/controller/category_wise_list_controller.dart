import 'package:flutter/material.dart';
import 'dart:async';
import 'package:monaymanagment/repository/category/service/category_service.dart';
import 'package:monaymanagment/repository/transaction/service/expense_service.dart';
import 'package:monaymanagment/repository/transaction/model/transaction_model.dart'
    as transaction_repo;

class CategoryWiseListController extends ChangeNotifier {
  static final Map<String, CategoryWiseListController> _instances = {};
  bool _disposed = false;

  final String category;
  IconData? _categoryIcon;
  final CategoryService _categoryService = CategoryService();
  final ExpenseService _expenseService = ExpenseService();

  // Singleton pattern per category
  factory CategoryWiseListController({
    required String category,
    IconData? categoryIcon,
    bool autoLoad = true,
  }) {
    if (_instances[category] == null || _instances[category]!._disposed) {
      _instances[category] = CategoryWiseListController._internal(
        category: category,
      );
    }
    if (categoryIcon != null) {
      _instances[category]!._categoryIcon = categoryIcon;
    }
    return _instances[category]!;
  }

  CategoryWiseListController._internal({required this.category});

  final List<ExpenseItem> _items = <ExpenseItem>[];
  final StreamController<List<ExpenseItem>> _itemsController =
      StreamController<List<ExpenseItem>>.broadcast();
  List<transaction_repo.Transaction> _apiTransactions = [];
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String? _errorMessage;

  List<ExpenseItem> get items => List.unmodifiable(_items);
  Stream<List<ExpenseItem>> get itemsStream => _itemsController.stream;
  List<transaction_repo.Transaction> get apiTransactions => _apiTransactions;
  bool get isLoading => _isLoading;
  bool get isDataLoaded => _isDataLoaded;
  String? get errorMessage => _errorMessage;

  // expansion state for tiles (by index)
  final Set<int> _expanded = <int>{};

  bool isExpanded(int index) => _expanded.contains(index);

  void toggleExpanded(int index) {
    if (_disposed) return;
    if (_expanded.contains(index)) {
      _expanded.remove(index);
    } else {
      _expanded.add(index);
    }
    notifyListeners();
  }

  void addExpense(ExpenseItem item) {
    if (_disposed) return;
    _items.add(item);
    // Emit incremental update
    _itemsController.add(List.unmodifiable(_items));
    notifyListeners();
  }

  void removeItem(int index) {
    if (_disposed) return;
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      // Emit incremental update
      _itemsController.add(List.unmodifiable(_items));
      notifyListeners();
    }
  }

  // Force refresh the UI
  void forceRefresh() {
    if (_disposed) return;
    notifyListeners();
  }

  // Manual refresh method that can be called from UI
  Future<void> refreshData() async {
    print('Manual refresh triggered for category: $category');
    await loadCategoryTransactions(forceReload: true);
  }

  // Load category transactions from API
  Future<void> loadCategoryTransactions({bool forceReload = false}) async {
    if (_isLoading && !forceReload)
      return; // Prevent multiple simultaneous calls unless forced
    print('Loading category transactions for: $category');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Show shimmer immediately

    try {
      final response = await _categoryService.getCategoryTransactions(
        categoryName: category,
      );

      _apiTransactions = response.transactions;
      print('Loaded ${_apiTransactions.length} transactions from API');

      // Build new items list without notifying mid-way
      final List<ExpenseItem> newItems = <ExpenseItem>[];
      for (var transaction in _apiTransactions) {
        for (var subTransaction in transaction.subTransactions) {
          if (subTransaction.name.toLowerCase() == 'transaction') {
            continue;
          }
          final displayName = subTransaction.name.trim().isEmpty
              ? 'Untitled Transaction'
              : subTransaction.name;
          newItems.add(
            ExpenseItem(
              icon: _categoryIcon ?? _getIconForCategory(category),
              title: displayName,
              subtitle: '${subTransaction.date} - ${subTransaction.time}',
              amount: subTransaction.amount,
              dateTime: _parseDateTime(
                subTransaction.date,
                subTransaction.time,
              ),
              subCategory: subTransaction.description,
              isIncome: subTransaction.amount > 0,
            ),
          );
        }
      }

      if (newItems.isEmpty) {
        try {
          await _loadAutoTransactions();
        } catch (e) {
          print('Auto transactions not available: $e');
          // Continue with empty list - don't set error for 404
          if (!e.toString().contains('404')) {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          }
        }
      } else {
        _items
          ..clear()
          ..addAll(newItems);
        // Emit newly loaded list once
        _itemsController.add(List.unmodifiable(_items));
      }

      _isDataLoaded = true;
      print('Data processing completed. Total items: ${_items.length}');
    } catch (e) {
      print('Error loading category transactions: $e');
      // Don't set error message for 404 - category just doesn't exist
      if (!e.toString().contains('404') &&
          !e.toString().contains('Category not found')) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      try {
        await _loadAutoTransactions();
      } catch (autoError) {
        print('Auto transactions fallback also failed: $autoError');
        // Don't set error for 404 - just continue with empty list
        if (!autoError.toString().contains('404')) {
          if (_errorMessage == null) {
            _errorMessage = autoError.toString().replaceAll('Exception: ', '');
          }
        }
      }
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  // Load auto transactions as fallback
  Future<void> _loadAutoTransactions() async {
    try {
      final autoResponse = await _expenseService.getAutoTransactions();

      // Filter transactions for this category
      final categoryTransactions = autoResponse.data
          .where(
            (transaction) =>
                transaction.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();

      if (categoryTransactions.isNotEmpty) {
        _items.clear();
        for (var transaction in categoryTransactions) {
          _items.add(
            ExpenseItem(
              icon: _getIconForCategory(category),
              title: transaction.title,
              subtitle:
                  '${_formatDate(transaction.date)} - ${transaction.time}',
              amount: transaction.amount,
              dateTime: transaction.date,
              subCategory: transaction.description,
              isIncome: transaction.isIncome,
            ),
          );
        }
        // Emit newly loaded list
        _itemsController.add(List.unmodifiable(_items));
      }
    } catch (e) {
      print('Error loading auto transactions: $e');
      // Don't rethrow for 404 errors - just continue with empty list
      if (e.toString().contains('404')) {
        print(
          'Auto transactions API not available (404) - continuing with empty list',
        );
        return;
      }
      rethrow;
    }
  }

  // Helper methods
  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'medicine':
        return Icons.medication;
      case 'shopping':
        return Icons.shopping_bag;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'gift':
        return Icons.card_giftcard;
      case 'savings':
        return Icons.savings;
      case 'entertainment':
        return Icons.movie;
      case 'home':
        return Icons.home;
      case 'water':
        return Icons.water_drop;
      case 'car':
        return Icons.directions_car;
      case 'money':
        return Icons.attach_money;
      case 'cloud':
        return Icons.cloud;
      case 'time':
        return Icons.access_time;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.category;
    }
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      // Parse date like "September 25, 2025"
      final dateParts = dateStr.split(' ');
      final monthStr = dateParts[0];
      final dayStr = dateParts[1].replaceAll(',', '');
      final yearStr = dateParts[2];

      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final month = months.indexOf(monthStr) + 1;
      final day = int.parse(dayStr);
      final year = int.parse(yearStr);

      // Parse time like "10:35 AM"
      final timeParts = timeStr.split(' ');
      final timeStrParts = timeParts[0].split(':');
      var hour = int.parse(timeStrParts[0]);
      final minute = int.parse(timeStrParts[1]);
      final period = timeParts[1];

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}';
  }

  // Set loading state
  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
  }

  // Set error message
  void _setErrorMessage(String? message) {
    if (_disposed) return;
    _errorMessage = message;
  }

  // Update sub-transaction
  Future<bool> updateSubTransaction({
    required String transactionId,
    required int subTransactionIndex,
    required String name,
    required double amount,
    required DateTime date,
    required String time,
    required String description,
  }) async {
    if (_disposed) return false;

    _setLoading(true);
    _setErrorMessage(null);

    print(
      'Update sub-transaction - Transaction ID: $transactionId, Sub-transaction Index: $subTransactionIndex, Name: $name, Amount: $amount',
    );

    try {
      final response = await _categoryService.updateSubTransaction(
        transactionId: transactionId,
        subTransactionIndex: subTransactionIndex,
        name: name,
        amount: amount,
        date: date,
        time: time,
        description: description,
      );

      if (response['success'] == true) {
        print('Update successful, refreshing data...');
        await Future.delayed(Duration(milliseconds: 300));
        await loadCategoryTransactions(forceReload: true);
        _setLoading(false);
        if (!_disposed) notifyListeners();
        print('Data reload completed after update');
        return true;
      } else {
        _setErrorMessage(
          'Failed to update sub-transaction: ${response['message'] ?? 'Unknown error'}',
        );
        _setLoading(false);
        if (!_disposed) notifyListeners();
        return false;
      }
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      if (!_disposed) notifyListeners();
      return false;
    }
  }

  // Delete sub-transaction
  Future<bool> deleteSubTransaction({
    required String transactionId,
    required int subTransactionIndex,
  }) async {
    if (_disposed) return false;

    _setLoading(true);
    _setErrorMessage(null);

    print(
      'Delete sub-transaction - Transaction ID: $transactionId, Sub-transaction Index: $subTransactionIndex',
    );

    try {
      final response = await _categoryService.deleteSubTransaction(
        transactionId: transactionId,
        subTransactionIndex: subTransactionIndex,
      );

      if (response['success'] == true) {
        print('Delete successful, refreshing data...');

        // Wait a bit to ensure delete operation is fully complete
        await Future.delayed(Duration(milliseconds: 200));

        // Reload data first to get fresh data
        if (!_disposed) {
          await loadCategoryTransactions(forceReload: true);
        }

        _setLoading(false);
        if (!_disposed) notifyListeners();
        print('Data reload completed after delete');
        return true;
      } else {
        _setErrorMessage(
          'Failed to delete sub-transaction: ${response['message'] ?? 'Unknown error'}',
        );
        _setLoading(false);
        if (!_disposed) notifyListeners();
        return false;
      }
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      if (!_disposed) notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _itemsController.close();
    super.dispose();
  }

  // Reset singleton instance for category
  static void resetInstance(String category) {
    _instances[category]?.dispose();
    _instances.remove(category);
  }

  // Reset all instances
  static void resetAllInstances() {
    _instances.values.forEach((controller) => controller.dispose());
    _instances.clear();
  }
}

class ExpenseItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime dateTime;
  final String? subCategory;
  final bool isIncome;

  ExpenseItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateTime,
    this.subCategory,
    this.isIncome = false,
  });
}
