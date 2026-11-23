import 'package:flutter/material.dart';

import 'package:monaymanagment/core/services/guest_storage_service.dart';

import 'package:monaymanagment/repository/analyse/model/analysis_model.dart';
import 'package:monaymanagment/repository/analyse/service/analysis_service.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';
import 'package:monaymanagment/repository/target/service/target_service.dart';
import 'package:monaymanagment/repository/transaction/model/transaction_model.dart';
import 'package:monaymanagment/repository/transaction/service/transaction_data_service.dart';

class AnalysisController extends ChangeNotifier {
  static AnalysisController? _instance;
  bool _disposed = false;

  // Singleton pattern
  factory AnalysisController() {
    if (_instance == null || _instance!._disposed) {
      _instance = AnalysisController._internal();
    }
    return _instance!;
  }

  AnalysisController._internal();

  final TransactionDataService _transactionDataService =
      TransactionDataService();
  final TargetService _targetService = TargetService();
  final AnalysisService _analysisService = AnalysisService();
  final GuestStorageService _guestStorage = GuestStorageService.instance;

  // Analysis type selection
  String selectedAnalysisType = 'Time Analysis';
  String selectedPeriod = 'Daily'; // Default for Time Analysis
  String selectedFilter = 'expense';
  int selectedYear = DateTime.now().year;

  // Target data
  List<Target> _targets = [];
  bool _targetsLoading = false;
  bool _isDataLoaded = false;

  // Analytics data
  CategoryAnalyticsResponse? _categoryAnalytics;
  CategoryAnalyticsResponse? _timeAnalytics;
  bool _analyticsLoading = false;
  String? _analyticsError;

  // Analysis type options
  List<String> analysisTypes = ['Time Analysis', 'Category Analysis'];
  List<String> filterTypes = ['expense', 'income', 'all'];

  // Time period options for different analysis types
  List<String> get timePeriods {
    if (selectedAnalysisType == 'Time Analysis') {
      return ['Daily', 'Weekly', 'Monthly', 'Year'];
    } else {
      return ['Today', 'Month', 'Year', 'All'];
    }
  }

  // Getters for real data
  double get totalBalance => _transactionDataService.totalBalance;
  double get totalExpense => _transactionDataService.totalExpense;
  double get totalIncome => _transactionDataService.totalIncome;
  double get totalExpenseAmount => _transactionDataService.totalExpense;
  double get progressPercentage => targetAmount > 0
      ? (totalExpense / targetAmount * 100).clamp(0.0, 100.0)
      : 0.0;
  bool get isLoading => _transactionDataService.isLoading;
  String? get errorMessage => _transactionDataService.errorMessage;

  // Filtered income and expense based on selected period and analysis type
  double get filteredIncome {
    double income;
    if (_isGuestMode) {
      income = _getGuestFilteredIncome();
    } else if (selectedAnalysisType == 'Category Analysis') {
      income = _getCategoryAnalyticsIncome();
    } else {
      income = _getTimeAnalyticsIncome();
    }
    print(
      'Filtered Income: $income (Type: $selectedAnalysisType, Filter: $selectedFilter, Period: $selectedPeriod)',
    );
    return income;
  }

  double get filteredExpense {
    double expense;
    if (_isGuestMode) {
      expense = _getGuestFilteredExpense();
    } else if (selectedAnalysisType == 'Category Analysis') {
      expense = _getCategoryAnalyticsExpense();
    } else {
      expense = _getTimeAnalyticsExpense();
    }
    print(
      'Filtered Expense: $expense (Type: $selectedAnalysisType, Filter: $selectedFilter, Period: $selectedPeriod)',
    );
    return expense;
  }

  // Target getters
  List<Target> get targets => _targets;
  bool get targetsLoading => _targetsLoading;
  bool get isDataLoaded => _isDataLoaded;
  double get targetAmount => _targets.isNotEmpty
      ? _targets.map((t) => t.amount).reduce((a, b) => a + b)
      : 20000.0;

  // Analytics getters
  CategoryAnalyticsResponse? get categoryAnalytics => _categoryAnalytics;
  CategoryAnalyticsResponse? get timeAnalytics => _timeAnalytics;
  bool get analyticsLoading => _analyticsLoading;
  String? get analyticsError => _analyticsError;
  bool get _isGuestMode => _guestStorage.isGuestMode;
  bool get isGuestMode => _isGuestMode;

  // Load data only if not already loaded
  Future<void> loadData() async {
    if (_isDataLoaded || isLoading) return;
    await _loadTransactionData();
    await _loadTargets();
    await _loadAnalytics();
    _isDataLoaded = true;
  }

  // Methods
  void selectAnalysisType(String analysisType) {
    if (_disposed) return;
    selectedAnalysisType = analysisType;

    // Reset to appropriate default period for the analysis type
    if (analysisType == 'Time Analysis') {
      selectedPeriod = 'Daily';
    } else {
      selectedPeriod = 'Today';
    }

    _loadAnalytics();
    notifyListeners();
  }

  void selectTimePeriod(String period) {
    if (_disposed) return;
    selectedPeriod = period;
    _loadAnalytics();
    notifyListeners();
  }

  void selectFilter(String filter) {
    if (_disposed) return;
    selectedFilter = filter;
    _loadAnalytics();
    notifyListeners();
  }

  void selectYear(int year) {
    if (_disposed) return;
    selectedYear = year;
    _loadAnalytics();
    notifyListeners();
  }

  Future<void> _loadTargets() async {
    if (_disposed) return;
    _targetsLoading = true;
    if (!_disposed) notifyListeners();

    try {
      final response = await _targetService.getTargets();
      if (_disposed) return;
      _targets = response.targets;
    } catch (e) {
      print('Error loading targets: $e');
    } finally {
      if (!_disposed) {
        _targetsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadTransactionData() async {
    await _transactionDataService.loadAllTransactions();
    if (!_disposed) notifyListeners();
  }

  Future<void> _loadAnalytics() async {
    if (_disposed) return;
    if (_isGuestMode) {
      _analyticsLoading = false;
      _analyticsError = null;
      notifyListeners();
      return;
    }
    _analyticsLoading = true;
    _analyticsError = null;
    if (!_disposed) notifyListeners();

    try {
      // Map UI period names to API period names
      String period;
      switch (selectedPeriod) {
        // Time Analysis periods
        case 'Daily':
          period = 'daily';
          break;
        case 'Weekly':
          period = 'weekly';
          break;
        case 'Monthly':
          period = 'monthly';
          break;
        case 'Year':
          period = 'yearly';
          break;
        // Category Analysis periods
        case 'Today':
          period = 'daily';
          break;
        case 'This Month':
          period = 'monthly';
          break;
        case 'This Year':
          period = 'yearly';
          break;
        case 'All':
          period = 'monthly'; // Use monthly as default for "All"
          break;
        default:
          period = selectedPeriod.toLowerCase();
      }

      print(
        'Loading analytics: Type=$selectedAnalysisType, Period=$period, Filter=$selectedFilter, Year=$selectedYear',
      );

      if (selectedAnalysisType == 'Category Analysis') {
        _categoryAnalytics = await _analysisService.getCategoryAnalytics(
          period: period,
          year: selectedYear,
          filter: selectedFilter,
        );
        print(
          'Category Analytics loaded: Income=${_categoryAnalytics?.data.summary.totalIncome}, Expense=${_categoryAnalytics?.data.summary.totalExpense}',
        );
        print(
          'Category Chart Data: ${_categoryAnalytics?.data.chartData.length} categories',
        );
      } else {
        _timeAnalytics = await _analysisService.getTimeAnalytics(
          period: period,
          year: selectedYear,
          filter: selectedFilter,
        );
        print(
          'Time Analytics loaded: Income=${_timeAnalytics?.data.summary.totalIncome}, Expense=${_timeAnalytics?.data.summary.totalExpense}',
        );
      }
    } catch (e) {
      print('Error loading analytics: $e');
      _analyticsError = e.toString();
    } finally {
      if (!_disposed) {
        _analyticsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshData() async {
    await _loadTransactionData();
    await _loadTargets();
    await _loadAnalytics();
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

  // Get current chart data based on selected period
  List<ChartData> get currentChartData {
    return _transactionDataService.getChartData(selectedPeriod);
  }

  // Get max value for chart scaling
  double get maxChartValue {
    final data = currentChartData;
    if (data.isEmpty) return 15000;

    // Filter out NaN values and get valid numbers
    final validIncomes = data
        .map((e) => e.income)
        .where((value) => !value.isNaN && value.isFinite)
        .toList();
    final validExpenses = data
        .map((e) => e.expense)
        .where((value) => !value.isNaN && value.isFinite)
        .toList();

    if (validIncomes.isEmpty && validExpenses.isEmpty) return 15000;

    double maxIncome = validIncomes.isEmpty
        ? 0.0
        : validIncomes.reduce((a, b) => a > b ? a : b);
    double maxExpense = validExpenses.isEmpty
        ? 0.0
        : validExpenses.reduce((a, b) => a > b ? a : b);
    double maxValue = maxIncome > maxExpense ? maxIncome : maxExpense;

    // Ensure maxValue is valid
    if (maxValue.isNaN || maxValue <= 0) return 15000;

    // Round up to nearest 5k for better scaling
    return ((maxValue / 5000).ceil() * 5000).toDouble();
  }

  // Get category pie chart data - dynamically from API based on user's categories
  List<CategoryPieData> get categoryPieData {
    if (_isGuestMode) {
      return _buildGuestCategoryPieData();
    }
    final analytics = categoryAnalytics?.data;
    if (analytics == null || analytics.chartData.isEmpty) return [];

    // Colors matching the reference image: red, yellow, green, light blue, dark blue
    final colors = [
      const Color(0xFFE53E3E), // Red
      const Color(0xFFF6E05E), // Yellow
      const Color(0xFF68D391), // Green
      const Color(0xFF63B3ED), // Light blue
      const Color(0xFF2B6CB0), // Dark blue
      const Color(0xFF805AD5), // Purple
      const Color(0xFFED8936), // Orange
      const Color(0xFF38B2AC), // Teal
      const Color(0xFF718096), // Gray
      const Color(0xFFF56565), // Light red
      const Color(0xFF48BB78), // Light green
      const Color(0xFF4299E1), // Blue
    ];

    // Filter and map data based on selected filter
    List<CategoryPieData> filteredData = [];

    for (int i = 0; i < analytics.chartData.length; i++) {
      final item = analytics.chartData[i];
      double value;
      double percentage;

      if (selectedFilter == 'income') {
        value = item.income;
        // Calculate percentage based on total income
        final totalIncome = analytics.summary.totalIncome;
        percentage = totalIncome > 0 ? (item.income / totalIncome * 100) : 0.0;
      } else if (selectedFilter == 'expense') {
        value = item.expense;
        // Calculate percentage based on total expense
        final totalExpense = analytics.summary.totalExpense;
        percentage = totalExpense > 0
            ? (item.expense / totalExpense * 100)
            : 0.0;
      } else {
        // 'all'
        value = item.income + item.expense;
        // Calculate percentage based on total amount
        final totalAmount =
            analytics.summary.totalIncome + analytics.summary.totalExpense;
        percentage = totalAmount > 0 ? (value / totalAmount * 100) : 0.0;
      }

      // Only include categories with value > 0
      if (value > 0) {
        filteredData.add(
          CategoryPieData(
            name: item.name,
            value: value,
            percentage: percentage,
            icon: item.icon,
            colorIndex: i % colors.length,
          ),
        );
      }
    }

    // Sort by percentage (largest first) for better pie chart display
    filteredData.sort((a, b) => b.percentage.compareTo(a.percentage));

    print(
      'Category Pie Data: ${filteredData.length} categories, Filter: $selectedFilter',
    );
    return filteredData;
  }

  List<CategoryPieData> _buildGuestCategoryPieData() {
    final transactions = _filterGuestTransactionsForCategoryPeriod();
    if (transactions.isEmpty) return [];

    final Map<String, double> totals = {};
    for (final txn in transactions) {
      if (selectedFilter == 'income' && txn.amount <= 0) continue;
      if (selectedFilter == 'expense' && txn.amount >= 0) continue;

      final value = txn.amount >= 0 ? txn.amount : txn.amount.abs();
      if (value <= 0) continue;
      totals[txn.categoryName] = (totals[txn.categoryName] ?? 0.0) + value;
    }

    if (totals.isEmpty) return [];

    final totalAmount = totals.values.fold(0.0, (sum, value) => sum + value);
    if (totalAmount <= 0) return [];

    final colors = [
      const Color(0xFFE53E3E),
      const Color(0xFFF6E05E),
      const Color(0xFF68D391),
      const Color(0xFF63B3ED),
      const Color(0xFF2B6CB0),
      const Color(0xFF805AD5),
      const Color(0xFFED8936),
      const Color(0xFF38B2AC),
      const Color(0xFF718096),
      const Color(0xFFF56565),
      const Color(0xFF48BB78),
      const Color(0xFF4299E1),
    ];

    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<CategoryPieData> pieData = [];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final percentage = (entry.value / totalAmount) * 100;
      pieData.add(
        CategoryPieData(
          name: entry.key,
          value: entry.value,
          percentage: percentage,
          icon: '',
          colorIndex: i % colors.length,
        ),
      );
    }

    return pieData;
  }

  // Get current analytics data
  CategoryAnalyticsResponse? get currentAnalytics {
    return selectedAnalysisType == 'Category Analysis'
        ? categoryAnalytics
        : timeAnalytics;
  }

  // Helper methods for filtered income and expense calculation
  double _getCategoryAnalyticsIncome() {
    final analytics = categoryAnalytics?.data;
    if (analytics == null) {
      print('No category analytics data available');
      return 0.0;
    }

    // For category analysis, show income based on filter
    if (selectedFilter == 'income') {
      return analytics.summary.totalIncome;
    } else if (selectedFilter == 'expense') {
      return 0.0; // No income when filtering expenses only
    } else {
      // 'all' - show both income and expense
      return analytics.summary.totalIncome;
    }
  }

  double _getCategoryAnalyticsExpense() {
    final analytics = categoryAnalytics?.data;
    if (analytics == null) {
      print('No category analytics data available');
      return 0.0;
    }

    // For category analysis, show expense based on filter
    if (selectedFilter == 'expense') {
      return analytics.summary.totalExpense;
    } else if (selectedFilter == 'income') {
      return 0.0; // No expense when filtering income only
    } else {
      // 'all' - show both income and expense
      return analytics.summary.totalExpense;
    }
  }

  double _getTimeAnalyticsIncome() {
    final analytics = timeAnalytics?.data;
    if (analytics == null) {
      print('No time analytics data available');
      return 0.0;
    }

    // Use summary data for accurate totals
    return analytics.summary.totalIncome;
  }

  double _getTimeAnalyticsExpense() {
    final analytics = timeAnalytics?.data;
    if (analytics == null) {
      print('No time analytics data available');
      return 0.0;
    }

    // Use summary data for accurate totals
    return analytics.summary.totalExpense;
  }

  double _getGuestFilteredIncome() {
    if (selectedAnalysisType == 'Time Analysis') {
      final data = currentChartData;
      return data.fold(0.0, (sum, chart) => sum + chart.income);
    }

    if (selectedFilter == 'expense') return 0.0;

    final transactions = _filterGuestTransactionsForCategoryPeriod();
    double total = 0.0;
    for (final txn in transactions) {
      if (txn.amount > 0) {
        total += txn.amount;
      }
    }
    return total;
  }

  double _getGuestFilteredExpense() {
    if (selectedAnalysisType == 'Time Analysis') {
      final data = currentChartData;
      return data.fold(0.0, (sum, chart) => sum + chart.expense);
    }

    if (selectedFilter == 'income') return 0.0;

    final transactions = _filterGuestTransactionsForCategoryPeriod();
    double total = 0.0;
    for (final txn in transactions) {
      if (txn.amount < 0) {
        total += txn.amount.abs();
      }
    }
    return total;
  }

  List<SubTransactionWithCategory> _filterGuestTransactionsForCategoryPeriod() {
    final transactions = _transactionDataService.allSubTransactions;
    if (transactions.isEmpty) return [];

    final range = _getCategoryDateRange();
    if (range == null) return transactions;

    return transactions.where((txn) {
      final txnDate = _parseGuestDateTime(txn.date, txn.time);
      return !txnDate.isBefore(range.start) && txnDate.isBefore(range.end);
    }).toList();
  }

  DateTimeRange? _getCategoryDateRange() {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (selectedPeriod) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;
      case 'Month':
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;
      case 'Year':
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year + 1, 1, 1);
        break;
      case 'All':
        start = DateTime(2000, 1, 1);
        end = now.add(const Duration(days: 1));
        break;
      default:
        return null;
    }

    return DateTimeRange(start: start, end: end);
  }

  DateTime _parseGuestDateTime(String dateStr, String timeStr) {
    try {
      final dateParts = dateStr.split(' ');
      final monthStr = dateParts[0];
      final dayStr = dateParts[1].replaceAll(',', '');
      final yearStr = dateParts[2];

      const months = [
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

      int hour = 0;
      int minute = 0;
      if (timeStr.isNotEmpty) {
        final timeParts = timeStr.split(' ');
        final numbers = timeParts[0].split(':');
        hour = int.parse(numbers[0]);
        minute = int.parse(numbers[1]);
        final period = timeParts.length > 1 ? timeParts[1] : 'AM';
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }
}
