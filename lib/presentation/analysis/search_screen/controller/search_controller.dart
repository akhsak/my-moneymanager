import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:monaymanagment/repository/auth/services/shared_data_service.dart';
import 'package:monaymanagment/repository/transaction/model/transaction_model.dart';

class SearchController extends ChangeNotifier {
  final SharedDataService _sharedDataService = SharedDataService.instance;

  // Search and filter data
  String searchQuery = '';
  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();
  String selectedReportType = 'Expense'; // 'Income' or 'Expense'

  // Search results
  List<SearchResult> searchResults = [];
  bool isSearching = false;
  bool hasSearched = false;

  bool _isInitializing = false;
  String? _loadError;

  // Available categories - empty, will be loaded from actual data
  List<String> categories = [];

  // Transaction data for search - empty, will be loaded from actual data
  List<TransactionData> allTransactions = [];

  bool get isInitializing => _isInitializing;
  String? get loadError => _loadError;

  SearchController() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isInitializing = true;
    _loadError = null;
    notifyListeners();

    try {
      await Future.wait([_loadCategories(), _loadTransactions()]);
    } catch (e) {
      _loadError = e.toString();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // Methods
  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void selectReportType(String type) {
    selectedReportType = type;
    notifyListeners();
  }

  void performSearch() {
    if (_isInitializing) return;
    isSearching = true;
    hasSearched = true;
    notifyListeners();

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      searchResults = _filterTransactions();
      isSearching = false;
      notifyListeners();
    });
  }

  List<SearchResult> _filterTransactions() {
    List<TransactionData> filtered = allTransactions.where((transaction) {
      // Search query filter
      bool matchesQuery =
          searchQuery.isEmpty ||
          transaction.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          transaction.category.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      // Category filter
      bool matchesCategory =
          selectedCategory.isEmpty || transaction.category == selectedCategory;

      // Date filter (same day)
      bool matchesDate =
          transaction.date.year == selectedDate.year &&
          transaction.date.month == selectedDate.month &&
          transaction.date.day == selectedDate.day;

      // Report type filter
      bool matchesReportType =
          (selectedReportType == 'Income' && !transaction.isExpense) ||
          (selectedReportType == 'Expense' && transaction.isExpense);

      return matchesQuery &&
          matchesCategory &&
          matchesDate &&
          matchesReportType;
    }).toList();

    return filtered
        .map(
          (transaction) => SearchResult(
            title: transaction.title,
            time: transaction.time,
            category: transaction.category,
            amount: transaction.amount,
            isExpense: transaction.isExpense,
          ),
        )
        .toList();
  }

  void clearSearch() {
    searchQuery = '';
    selectedCategory = '';
    selectedDate = DateTime.now();
    selectedReportType = 'Expense';
    searchResults = [];
    hasSearched = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadInitialData();
  }

  Future<void> _loadCategories() async {
    final categoryModels = await _sharedDataService.getCategories();
    final uniqueNames = LinkedHashSet<String>();

    for (final category in categoryModels) {
      final name = category.name.trim();
      if (name.isNotEmpty) {
        uniqueNames.add(name);
      }
    }

    categories = uniqueNames.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  Future<void> _loadTransactions() async {
    await _sharedDataService.loadTransactions();
    final subTransactions =
        _sharedDataService.transactionService.allSubTransactions;

    allTransactions = subTransactions
        .map(_mapSubTransaction)
        .where((tx) => tx != null)
        .cast<TransactionData>()
        .toList();
  }

  TransactionData? _mapSubTransaction(SubTransactionWithCategory sub) {
    try {
      final parsedDate = _parseTransactionDate(sub.date);
      final title = sub.name.trim().isNotEmpty ? sub.name : sub.categoryName;
      return TransactionData(
        title: title,
        time: '${sub.time} - ${sub.date}',
        category: sub.categoryName,
        amount: sub.amount.abs(),
        isExpense: sub.amount < 0,
        date: parsedDate,
      );
    } catch (e) {
      print('Error mapping sub-transaction: $e');
      return null;
    }
  }

  DateTime _parseTransactionDate(String dateString) {
    try {
      final cleaned = dateString.replaceAll(',', '');
      final parts = cleaned.split(' ');
      if (parts.length >= 3) {
        final month = _monthIndex(parts[0]);
        final day = int.tryParse(parts[1]) ?? DateTime.now().day;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime.now();
  }

  int _monthIndex(String monthName) {
    const months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    final index = months.indexOf(monthName.toLowerCase());
    return index >= 0 ? index + 1 : DateTime.now().month;
  }
}

class TransactionData {
  final String title;
  final String time;
  final String category;
  final double amount;
  final bool isExpense;
  final DateTime date;

  TransactionData({
    required this.title,
    required this.time,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.date,
  });
}

class SearchResult {
  final String title;
  final String time;
  final String category;
  final double amount;
  final bool isExpense;

  SearchResult({
    required this.title,
    required this.time,
    required this.category,
    required this.amount,
    required this.isExpense,
  });
}
