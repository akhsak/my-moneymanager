import 'package:flutter/material.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/auth/services/shared_data_service.dart';
import 'package:monaymanagment/repository/transaction/service/transaction_data_service.dart';

class HomeController extends ChangeNotifier {
  final TransactionDataService _transactionDataService =
      TransactionDataService();
  final AuthService _authService = AuthService();
  final SharedDataService _sharedDataService = SharedDataService.instance;

  bool _disposed = false;

  // Filter State
  String _selectedFilter = 'Daily';

  // Pagination State
  int _currentPage = 1;
  int _itemsPerPage = 10;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;

  // Expense limit (can be set by user)
  double _expenseLimit = 20000.00;

  // User data
  String? _userName;
  String? _userProfileImage;
  bool _isLoadingUserData = false;

  // Cached calculations to prevent lag (initialized with defaults for instant display)
  double? _cachedTotalBalance = 0.0;
  double? _cachedTotalExpense = 0.0;
  double? _cachedRevenueLastWeek = 0.0;
  double? _cachedLoanBalanceToPay = 0.0;
  List<CategorySummary>? _cachedTopCategories;
  String? _lastFilter;

  // Initialize controller
  HomeController() {
    // Load data in background without blocking UI
    Future.microtask(() {
      _loadAllData();
      _loadUserData();
      _preloadCategoryData();
    });
  }

  // Preload category data for instant navigation
  void _preloadCategoryData() {
    SharedDataService.instance.loadAllData().catchError((e) {
      print('Preload error: $e');
    });
  }

  // Getters for real data with caching (instant return, no recalculation during access)
  double get totalBalance => _cachedTotalBalance ?? 0.0;
  double get totalExpense => _cachedTotalExpense ?? 0.0;
  double get revenueLastWeek => _cachedRevenueLastWeek ?? 0.0;
  double get loanBalanceToPay => _cachedLoanBalanceToPay ?? 0.0;

  double get expenseProgress =>
      _expenseLimit > 0 ? (totalExpense / _expenseLimit).clamp(0.0, 1.0) : 0.0;

  double get expenseProgressPercentage {
    final percentage = _expenseLimit > 0
        ? (totalExpense / _expenseLimit * 100).clamp(0.0, 100.0)
        : 0.0;
    return percentage;
  }

  double get expenseLimit => _expenseLimit;
  double get foodLastWeek => _getWeeklyFoodExpense();
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _transactionDataService.isLoading || _isLoadingUserData;
  String? get errorMessage => _transactionDataService.errorMessage;
  String? get userName => _userName;
  String? get userProfileImage => _userProfileImage;

  // Pagination getters
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  bool get hasMoreItems => _hasMoreItems;
  bool get isLoadingMore => _isLoadingMore;

  // Top Categories getter with caching
  List<CategorySummary> get topCategories {
    if (_cachedTopCategories == null || _lastFilter != _selectedFilter) {
      _cachedTopCategories = _getTopCategories();
      _lastFilter = _selectedFilter;
    }
    return _cachedTopCategories!;
  }

  // Filter options
  List<String> get filterOptions => ['Daily', 'Weekly', 'Monthly'];

  // Method to clear cache when data changes
  void _clearCache() {
    _cachedTotalBalance = 0.0;
    _cachedTotalExpense = 0.0;
    _cachedRevenueLastWeek = 0.0;
    _cachedLoanBalanceToPay = 0.0;
    _cachedTopCategories = null;
  }

  // Get top categories based on current filter
  List<CategorySummary> _getTopCategories() {
    final Map<String, CategorySummary> categoryMap = {};
    final now = DateTime.now();

    for (var subTransaction in _transactionDataService.allSubTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      bool shouldInclude = false;

      // Apply the same filter logic as transactions
      switch (_selectedFilter.toLowerCase()) {
        case 'daily':
          shouldInclude =
              transactionDate.day == now.day &&
              transactionDate.month == now.month &&
              transactionDate.year == now.year;
          break;
        case 'weekly':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(Duration(days: 6));
          shouldInclude =
              transactionDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
              transactionDate.isBefore(weekEnd.add(Duration(days: 1)));
          break;
        case 'monthly':
          shouldInclude =
              transactionDate.month == now.month &&
              transactionDate.year == now.year;
          break;
        default:
          shouldInclude = false;
          break;
      }

      if (shouldInclude) {
        final categoryName = subTransaction.categoryName;
        if (!categoryMap.containsKey(categoryName)) {
          categoryMap[categoryName] = CategorySummary(
            name: categoryName,
            icon: _getIconForCategory(categoryName),
            totalAmount: 0.0,
            transactionCount: 0,
          );
        }

        categoryMap[categoryName]!.totalAmount += subTransaction.amount.abs();
        categoryMap[categoryName]!.transactionCount++;
      }
    }

    // Sort by total amount and take top 5
    final sortedCategories = categoryMap.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return sortedCategories.take(5).toList();
  }

  // Transaction data from real API
  List<Transaction> get transactions {
    final allTransactions = <Transaction>[];
    final now = DateTime.now();

    // Get top 5 category names
    final topCategoryNames = topCategories.map((cat) => cat.name).toSet();

    print(
      'HomeController: Processing ${_transactionDataService.allSubTransactions.length} sub-transactions',
    );
    print('HomeController: Selected filter: $_selectedFilter');
    print('HomeController: Top categories: $topCategoryNames');

    // Use sub-transactions from the new API
    for (var subTransaction in _transactionDataService.allSubTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      bool shouldInclude = false;

      switch (_selectedFilter.toLowerCase()) {
        case 'daily':
          shouldInclude =
              transactionDate.day == now.day &&
              transactionDate.month == now.month &&
              transactionDate.year == now.year;
          break;
        case 'weekly':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(Duration(days: 6));
          shouldInclude =
              transactionDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
              transactionDate.isBefore(weekEnd.add(Duration(days: 1)));
          break;
        case 'monthly':
          shouldInclude =
              transactionDate.month == now.month &&
              transactionDate.year == now.year;
          break;
        default:
          shouldInclude = false;
          break;
      }

      // Only include transactions from top 5 categories
      if (shouldInclude &&
          topCategoryNames.contains(subTransaction.categoryName)) {
        allTransactions.add(
          Transaction(
            icon: _getIconForCategory(subTransaction.categoryName),
            title: subTransaction.name,
            time: '${subTransaction.time} - ${subTransaction.date}',
            category: subTransaction.categoryName,
            amount: subTransaction.amount.abs(),
            isIncome: subTransaction.amount > 0,
          ),
        );
      }
    }

    // Sort by date (most recent first)
    allTransactions.sort((a, b) => b.time.compareTo(a.time));

    // Apply pagination
    final startIndex = 0;
    final endIndex = (_currentPage * _itemsPerPage).clamp(
      0,
      allTransactions.length,
    );
    final paginatedTransactions = allTransactions.sublist(startIndex, endIndex);

    // Update hasMoreItems
    _hasMoreItems = endIndex < allTransactions.length;

    print(
      'HomeController: Filtered transactions count: ${allTransactions.length}',
    );
    print(
      'HomeController: Paginated transactions count: ${paginatedTransactions.length}',
    );
    print('HomeController: Has more items: $_hasMoreItems');

    return paginatedTransactions;
  }

  // Methods
  void changeFilter(String filter) {
    if (_disposed) return;
    _selectedFilter = filter;
    _currentPage = 1; // Reset to first page when filter changes
    _hasMoreItems = true;
    // Don't clear the main financial data cache - only clear top categories
    _cachedTopCategories = null;
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Pagination methods
  void loadMoreTransactions() {
    if (_disposed || !_hasMoreItems || _isLoadingMore) return;

    _isLoadingMore = true;
    if (!_disposed) {
      notifyListeners();
    }

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_disposed) return;
      _currentPage++;
      _isLoadingMore = false;
      if (!_disposed) {
        notifyListeners();
      }
    });
  }

  // Check if we should load more transactions automatically
  void checkAndLoadMore(int currentIndex, int totalItems) {
    // Load more when user scrolls to the last 3 items
    if (currentIndex >= totalItems - 3 && _hasMoreItems && !_isLoadingMore) {
      loadMoreTransactions();
    }
  }

  void resetPagination() {
    if (_disposed) return;
    _currentPage = 1;
    _hasMoreItems = true;
    _isLoadingMore = false;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void updateExpenseLimit(double limit) {
    if (_disposed) return;
    _expenseLimit = limit;
    _clearCache(); // Clear cache when limit changes
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      final guestService = GuestStorageService.instance;
      if (guestService.isGuestMode) {
        await _transactionDataService.loadAllTransactions();
        _cachedTotalBalance = _transactionDataService.totalBalance;
        _cachedTotalExpense = _transactionDataService.totalExpense;
        _cachedRevenueLastWeek = _getWeeklyRevenue();
        _cachedLoanBalanceToPay = _getLoanBalanceToPay();
        if (!_disposed) {
          notifyListeners();
        }
        return;
      }

      // Use shared data service to avoid duplicate loading
      if (!_sharedDataService.hasFreshData) {
        await _sharedDataService.loadAllData();
      }

      // Update cached values with fresh data
      _cachedTotalBalance = _transactionDataService.totalBalance;
      _cachedTotalExpense = _transactionDataService.totalExpense;
      _cachedRevenueLastWeek = _getWeeklyRevenue();
      _cachedLoanBalanceToPay = _getLoanBalanceToPay();

      // Notify listeners to update UI with fresh data
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error loading data: $e');
      // Keep showing cached data even if loading fails
    }
  }

  Future<void> refreshData() async {
    await _loadAllData();
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_disposed) return;
    _isLoadingUserData = true;
    if (!_disposed) {
      notifyListeners();
    }

    try {
      final guestService = GuestStorageService.instance;
      if (guestService.isGuestMode) {
        final profile = guestService.guestProfile;
        _userName = profile['name'] as String? ?? 'Guest User';
        _userProfileImage = profile['avatar'] as String?;
        return;
      }

      final user = await _authService.getCurrentUser();
      _userName = user.name;
      // Add profile image URL when available
      _userProfileImage = null; // user.profileImageUrl when implemented
    } catch (e) {
      print('Error loading user data: $e');
      _userName = 'User';
    } finally {
      _isLoadingUserData = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Helper methods
  double _getWeeklyRevenue() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    double revenue = 0.0;

    final subTransactions = _transactionDataService.allSubTransactions;
    if (subTransactions.isEmpty) return 0.0;

    // Use sub-transactions from the new API
    for (var subTransaction in subTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      if (transactionDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
          transactionDate.isBefore(weekEnd.add(Duration(days: 1)))) {
        // Only count positive amounts as revenue (income)
        if (subTransaction.amount > 0) {
          revenue += subTransaction.amount;
        }
      }
    }

    return revenue;
  }

  double _getWeeklyFoodExpense() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    double foodExpense = 0.0;

    final subTransactions = _transactionDataService.allSubTransactions;
    if (subTransactions.isEmpty) return 0.0;

    // Use sub-transactions from the new API
    for (var subTransaction in subTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      if (transactionDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
          transactionDate.isBefore(weekEnd.add(Duration(days: 1)))) {
        // Look for food-related categories
        if (subTransaction.categoryName.toLowerCase().contains('food') ||
            subTransaction.categoryName.toLowerCase().contains('restaurant') ||
            subTransaction.categoryName.toLowerCase().contains('groceries')) {
          if (subTransaction.amount < 0) {
            foodExpense += subTransaction.amount.abs();
          }
        }
      }
    }

    return foodExpense;
  }

  double _getLoanBalanceToPay() {
    double loanBalance = 0.0;

    final subTransactions = _transactionDataService.allSubTransactions;
    if (subTransactions.isEmpty) return 0.0;

    // Calculate total loan expenses (negative amounts for loan category)
    for (var subTransaction in subTransactions) {
      if (subTransaction.categoryName.toLowerCase() == 'loan') {
        // Only count negative amounts as loan payments/expenses
        if (subTransaction.amount < 0) {
          loanBalance += subTransaction.amount.abs();
        }
      }
    }

    return loanBalance;
  }

  DateTime _parseTransactionDate(String dateString) {
    try {
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

  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'drink':
        return Icons.local_drink;
      case 'bus':
        return Icons.directions_bus;
      case 'food':
        return Icons.restaurant;
      case 'home':
        return Icons.home;
      case 'watch':
        return Icons.watch;
      case 'milk':
        return Icons.local_drink; // Using drink icon for milk
      case 'cloud':
        return Icons.cloud;
      case 'shopping':
        return Icons.shopping_bag;
      case 'gift':
        return Icons.card_giftcard;
      case 'movie':
        return Icons.local_movies;
      case 'medicine':
        return Icons.local_pharmacy;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'money':
        return Icons.account_balance;
      case 'health':
        return Icons.local_pharmacy;
      case 'travel':
        return Icons.directions_bus;
      case 'loan':
        return Icons.account_balance_wallet;
      case 'phone':
        return Icons.phone;
      case 'education':
        return Icons.school;
      case 'calicut':
        return Icons.location_city;
      default:
        return Icons.category;
    }
  }
}

// UI Transaction model for home screen
class Transaction {
  final IconData icon;
  final String title;
  final String time;
  final String category;
  final double amount;
  final bool isIncome;

  Transaction({
    required this.icon,
    required this.title,
    required this.time,
    required this.category,
    required this.amount,
    required this.isIncome,
  });
}

// Category Summary model for top categories
class CategorySummary {
  final String name;
  final IconData icon;
  double totalAmount;
  int transactionCount;

  CategorySummary({
    required this.name,
    required this.icon,
    required this.totalAmount,
    required this.transactionCount,
  });
}
