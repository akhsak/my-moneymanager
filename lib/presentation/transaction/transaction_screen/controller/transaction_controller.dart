import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/categories/category_wise_expense_list_screen/widgets/edit_sub_transaction_dialog.dart';
import 'package:monaymanagment/repository/category/service/category_service.dart';
import 'package:monaymanagment/repository/transaction/service/transaction_data_service.dart';


class TransactionController extends ChangeNotifier {
  static TransactionController? _instance;
  bool _disposed = false;

  // Singleton pattern
  factory TransactionController() {
    if (_instance == null || _instance!._disposed) {
      _instance = TransactionController._internal();
    }
    return _instance!;
  }

  TransactionController._internal();

  final TransactionDataService _transactionDataService =
      TransactionDataService();
  final CategoryService _categoryService = CategoryService();

  // Filter state
  String selectedFilter = 'all'; // 'all', 'income', 'expense'

  // Pagination state
  int _currentPage = 1;
  int _itemsPerPage = 15;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;

  // Getters for real financial data
  double get totalBalance => _transactionDataService.totalBalance;
  double get totalIncome => _transactionDataService.totalIncome;
  double get totalExpense => _transactionDataService.totalExpense;
  double get targetAmount => 20000.00; // Can be made configurable
  double get progressPercentage => targetAmount > 0
      ? (totalExpense / targetAmount * 100).clamp(0.0, 100.0)
      : 0.0;
  bool get isLoading => _transactionDataService.isLoading;
  bool get isDataLoaded => _transactionDataService.isDataLoaded;
  String? get errorMessage => _transactionDataService.errorMessage;

  // Pagination getters
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  bool get hasMoreItems => _hasMoreItems;
  bool get isLoadingMore => _isLoadingMore;

  // Transaction list data from new API
  List<TransactionGroup> get transactionGroups {
    final Map<String, List<Transaction>> groupedTransactions = {};

    for (var subTransaction in _transactionDataService.allSubTransactions) {
      final transactionDate = _parseTransactionDate(subTransaction.date);
      final monthKey =
          '${_getMonthName(transactionDate.month)} ${transactionDate.year}';

      if (!groupedTransactions.containsKey(monthKey)) {
        groupedTransactions[monthKey] = [];
      }

      groupedTransactions[monthKey]!.add(
        Transaction(
          id: subTransaction.id,
          icon: _getIconForCategory(
            subTransaction.categoryName,
            subTransaction.categoryIcon,
          ),
          title: subTransaction.name,
          time: '${subTransaction.time} - ${subTransaction.date}',
          category: subTransaction.categoryName,
          amount: subTransaction.amount.abs(),
          isExpense: subTransaction.amount < 0,
          date: transactionDate,
          timeOnly: subTransaction.time,
          description: subTransaction.description,
          parentTransactionId: subTransaction.parentTransactionId,
          originalAmount: subTransaction.amount,
        ),
      );
    }

    // Convert to TransactionGroup list and sort by date
    final groups = groupedTransactions.entries.map((entry) {
      final transactions = entry.value;
      transactions.sort(
        (a, b) => _parseTransactionDateTime(
          b.time,
        ).compareTo(_parseTransactionDateTime(a.time)),
      );
      return TransactionGroup(month: entry.key, transactions: transactions);
    }).toList();

    // Sort groups by month (most recent first)
    groups.sort(
      (a, b) => _parseMonthYear(b.month).compareTo(_parseMonthYear(a.month)),
    );

    return groups;
  }

  // Filter methods
  void setFilter(String filter) {
    if (_disposed) return;
    selectedFilter = filter;
    resetPagination(); // Reset pagination when filter changes
  }

  // Load transaction data - only if not already loaded
  Future<void> loadTransactionData() async {
    if (_transactionDataService.isDataLoaded ||
        _transactionDataService.isLoading)
      return;
    await _transactionDataService.loadAllTransactions();
    if (!_disposed) notifyListeners();
  }

  Future<void> refreshData() async {
    await _transactionDataService.loadAllTransactions();
    if (!_disposed) notifyListeners();
  }

  // Helper methods
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

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  DateTime _parseMonthYear(String monthYear) {
    final parts = monthYear.split(' ');
    if (parts.length >= 2) {
      final month = _getMonthNumber(parts[0]);
      final year = int.parse(parts[1]);
      return DateTime(year, month);
    }
    return DateTime.now();
  }

  IconData _getIconForCategory(String categoryName, String categoryIcon) {
    // First try to use the icon from API
    if (categoryIcon.isNotEmpty) {
      switch (categoryIcon.toLowerCase()) {
        case 'restaurant':
          return Icons.restaurant;
        case 'money':
          return Icons.attach_money;
        case 'medicine':
          return Icons.medication;
        case 'entertainment':
          return Icons.movie;
        case 'savings':
          return Icons.savings;
        case 'transport':
          return Icons.directions_bus;
        case 'home':
          return Icons.home;
        case 'gift':
          return Icons.card_giftcard;
        case 'phone':
          return Icons.phone;
        case 'health':
          return Icons.health_and_safety;
      }
    }

    // Fallback to category name
    switch (categoryName.toLowerCase()) {
      case 'food':
      case 'restaurant':
      case 'groceries':
        return Icons.restaurant;
      case 'transport':
      case 'fuel':
        return Icons.directions_bus;
      case 'medicine':
      case 'health':
        return Icons.medication;
      case 'loan':
      case 'salary':
      case 'income':
        return Icons.attach_money;
      case 'gift':
      case 'gifts':
        return Icons.card_giftcard;
      case 'savings':
        return Icons.savings;
      case 'entertainment':
      case 'movie':
        return Icons.movie;
      case 'home':
      case 'rent':
        return Icons.home;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.category;
    }
  }

  DateTime _parseTransactionDateTime(String timeString) {
    try {
      // Parse time string like "03:17 PM - September 27, 2025"
      final parts = timeString.split(' - ');
      if (parts.length >= 2) {
        final datePart = parts[1];
        final timePart = parts[0];

        final dateTime = _parseTransactionDate(datePart);
        final timeParts = timePart.split(' ');
        if (timeParts.length >= 2) {
          final timeOnly = timeParts[0].split(':');
          if (timeOnly.length >= 2) {
            var hour = int.parse(timeOnly[0]);
            final minute = int.parse(timeOnly[1]);
            final period = timeParts[1];

            if (period == 'PM' && hour != 12) hour += 12;
            if (period == 'AM' && hour == 12) hour = 0;

            return DateTime(
              dateTime.year,
              dateTime.month,
              dateTime.day,
              hour,
              minute,
            );
          }
        }
      }
    } catch (e) {
      print('Error parsing transaction date time: $timeString, $e');
    }
    return DateTime.now();
  }

  List<TransactionGroup> get filteredTransactionGroups {
    List<TransactionGroup> filteredGroups;

    if (selectedFilter == 'all') {
      filteredGroups = transactionGroups;
    } else {
      filteredGroups = transactionGroups
          .map((group) {
            final filteredTransactions = group.transactions.where((
              transaction,
            ) {
              if (selectedFilter == 'Balance' || selectedFilter == 'income') {
                return !transaction.isExpense;
              } else if (selectedFilter == 'expense') {
                return transaction.isExpense;
              }
              return true;
            }).toList();

            return TransactionGroup(
              month: group.month,
              transactions: filteredTransactions,
            );
          })
          .where((group) => group.transactions.isNotEmpty)
          .toList();
    }

    // Apply pagination
    final totalTransactions = filteredGroups.fold<int>(
      0,
      (sum, group) => sum + group.transactions.length,
    );
    final maxTransactions = _currentPage * _itemsPerPage;

    if (totalTransactions <= maxTransactions) {
      _hasMoreItems = false;
      return filteredGroups;
    }

    // Paginate the groups
    final paginatedGroups = <TransactionGroup>[];
    int currentTransactionCount = 0;

    for (final group in filteredGroups) {
      if (currentTransactionCount >= maxTransactions) break;

      final remainingSlots = maxTransactions - currentTransactionCount;
      final transactionsToTake = group.transactions.length > remainingSlots
          ? group.transactions.take(remainingSlots).toList()
          : group.transactions;

      if (transactionsToTake.isNotEmpty) {
        paginatedGroups.add(
          TransactionGroup(
            month: group.month,
            transactions: transactionsToTake,
          ),
        );
        currentTransactionCount += transactionsToTake.length;
      }
    }

    _hasMoreItems = currentTransactionCount < totalTransactions;
    return paginatedGroups;
  }

  // Pagination methods
  void loadMoreTransactions() {
    if (!_hasMoreItems || _isLoadingMore || _disposed) return;

    _isLoadingMore = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_disposed) {
        _currentPage++;
        _isLoadingMore = false;
        notifyListeners();
      }
    });
  }

  // Check if we should load more transactions automatically
  void checkAndLoadMore(int currentIndex, int totalItems) {
    // Load more when user scrolls to the last 3 items
    if (currentIndex >= totalItems - 3 &&
        _hasMoreItems &&
        !_isLoadingMore &&
        !_disposed) {
      loadMoreTransactions();
    }
  }

  void resetPagination() {
    if (_disposed) return;
    _currentPage = 1;
    _hasMoreItems = true;
    _isLoadingMore = false;
    notifyListeners();
  }

  // Methods for future functionality
  void addTransaction(Transaction transaction) {
    if (_disposed) return;
    // Implementation for adding new transaction
    notifyListeners();
  }

  void updateTargetAmount(double newTarget) {
    if (_disposed) return;
    // This can be used to update target amount if needed
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

  // Update sub-transaction using index-based API
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
        print('✅ Sub-transaction updated successfully, refreshing data...');
        await refreshData();
        return true;
      } else {
        print('❌ Failed to update sub-transaction');
        return false;
      }
    } catch (e) {
      print('Error updating sub-transaction: $e');
      return false;
    }
  }

  // Delete sub-transaction using index-based API
  Future<bool> deleteSubTransaction({
    required String transactionId,
    required int subTransactionIndex,
  }) async {
    if (_disposed) return false;

    try {
      final response = await _categoryService.deleteSubTransaction(
        transactionId: transactionId,
        subTransactionIndex: subTransactionIndex,
      );

      if (response['success'] == true) {
        print('✅ Sub-transaction deleted successfully, refreshing data...');
        await refreshData();
        return true;
      } else {
        print('❌ Failed to delete sub-transaction');
        return false;
      }
    } catch (e) {
      print('Error deleting sub-transaction: $e');
      return false;
    }
  }

  void deleteTransaction(String transactionId) {
    for (int i = 0; i < transactionGroups.length; i++) {
      transactionGroups[i].transactions.removeWhere(
        (transaction) => transaction.id == transactionId,
      );

      // Remove empty groups
      if (transactionGroups[i].transactions.isEmpty) {
        transactionGroups.removeAt(i);
        i--; // Adjust index after removal
      }
    }
    notifyListeners();
  }

  void showDeleteDialog(BuildContext context, Transaction transaction) {
    // Find the sub-transaction index
    int? subTransactionIndex = _findSubTransactionIndex(transaction);

    if (subTransactionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction index not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(25),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Delete Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${transaction.title}"?',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                // Delete Button (Red)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();

                      // Use the index-based delete API
                      final success = await deleteSubTransaction(
                        transactionId: transaction.parentTransactionId,
                        subTransactionIndex: subTransactionIndex,
                      );

                      if (success && context.mounted) {
                        _showDeletedSnackbar(context);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete transaction'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.5),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Cancel Button (Gray)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.5),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDeletedSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          const Text(
            'Item is deleted',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFB71C1C), // Dark red color
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(16),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showTransactionDetailDialog(
    BuildContext context,
    Transaction transaction,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(SizeConstants.width(4)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: SizeConstants.screenHeight * 0.5,
              maxWidth: SizeConstants.screenWidth * 0.85,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConstants.width(5)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ColorTheme.secondaryColor, ColorTheme.lightBlue],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section (Dark Blue)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConstants.width(5),
                        vertical: SizeConstants.height(2),
                      ),
                      decoration: BoxDecoration(
                        color: ColorTheme.secondaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(SizeConstants.width(5)),
                          topRight: Radius.circular(SizeConstants.width(5)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Action Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(dialogContext),
                                child: Container(
                                  padding: EdgeInsets.all(
                                    SizeConstants.width(1),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: SizeConstants.font(5),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(dialogContext);
                                      showDeleteDialog(context, transaction);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        SizeConstants.width(1),
                                      ),
                                      // child: Icon(
                                      //   Icons.delete_outline,
                                      //   color: Colors.white,
                                      //   size: SizeConstants.font(5),
                                      // ),
                                    ),
                                  ),
                                  SizedBox(width: SizeConstants.width(4)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(dialogContext);
                                      navigateToEditExpense(
                                        context,
                                        transaction,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        SizeConstants.width(1),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: SizeConstants.font(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: SizeConstants.height(1.5)),

                          // Transaction Type
                          Text(
                            transaction.isExpense ? 'Expense' : 'Income',
                            style: TextStyles.bodyText(
                              color: Colors.white,
                              size: SizeConstants.font(4.5),
                              weight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: SizeConstants.height(1.5)),

                          // Amount
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹${transaction.amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: TextStyles.bodyText(
                                color: Colors.white,
                                size: SizeConstants.font(5.5),
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: SizeConstants.height(1)),

                          // Time and Date - Positioned to the right
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              transaction.time,
                              style: TextStyles.bodyText(
                                color: Colors.white.withOpacity(0.8),
                                size: SizeConstants.font(3),
                                weight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details Section (Light Blue/Purple)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConstants.width(5),
                        vertical: SizeConstants.height(2),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorTheme.lightBlue.withOpacity(0.9),
                            ColorTheme.lightBlue.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(SizeConstants.width(5)),
                          bottomRight: Radius.circular(SizeConstants.width(5)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Account Row
                          Row(
                            children: [
                              Text(
                                'Account :',
                                style: TextStyles.bodyText(
                                  color: Colors.white,
                                  size: SizeConstants.font(3.5),
                                  weight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: SizeConstants.width(3)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConstants.width(4),
                                  vertical: SizeConstants.height(1.2),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(
                                    SizeConstants.width(6),
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.credit_card,
                                      color: Colors.white,
                                      size: SizeConstants.font(3.5),
                                    ),
                                    SizedBox(width: SizeConstants.width(2)),
                                    Text(
                                      'Card',
                                      style: TextStyles.bodyText(
                                        color: Colors.white,
                                        size: SizeConstants.font(3.5),
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: SizeConstants.height(1.5)),

                          // Category Row
                          Row(
                            children: [
                              Text(
                                'Category :',
                                style: TextStyles.bodyText(
                                  color: Colors.white,
                                  size: SizeConstants.font(3.5),
                                  weight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: SizeConstants.width(3)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConstants.width(4),
                                  vertical: SizeConstants.height(1.2),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(
                                    SizeConstants.width(6),
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      transaction.icon,
                                      color: Colors.white,
                                      size: SizeConstants.font(3.5),
                                    ),
                                    SizedBox(width: SizeConstants.width(2)),
                                    Flexible(
                                      child: Text(
                                        transaction.category,
                                        style: TextStyles.bodyText(
                                          color: Colors.white,
                                          size: SizeConstants.font(3.5),
                                          weight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: SizeConstants.height(1.5)),

                          // Description - Centered
                          Container(
                            width: double.infinity,
                            child: Text(
                              '${transaction.title} sent to ${transaction.category.toLowerCase()}',
                              style: TextStyles.bodyText(
                                color: Colors.white,
                                size: SizeConstants.font(3.5),
                                weight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: SizeConstants.height(1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TransactionGroup {
  final String month;
  final List<Transaction> transactions;

  TransactionGroup({required this.month, required this.transactions});
}

class Transaction {
  final String id;
  final IconData icon;
  final String title;
  final String time;
  final String category;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final String timeOnly;
  final String description;
  final String parentTransactionId;
  final double originalAmount;

  Transaction({
    required this.id,
    required this.icon,
    required this.title,
    required this.time,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.timeOnly,
    required this.description,
    required this.parentTransactionId,
    required this.originalAmount,
  });
}

// Add edit navigation method to controller
extension TransactionControllerExtension on TransactionController {
  void navigateToEditExpense(BuildContext context, Transaction transaction) {
    // Find the sub-transaction index from the parent transaction
    int? subTransactionIndex = _findSubTransactionIndex(transaction);

    if (subTransactionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction index not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => EditSubTransactionDialog(
        name: transaction.title,
        amount: transaction.originalAmount,
        date: transaction.date,
        time: transaction.timeOnly,
        description: transaction.description,
        onSave: (name, amount, date, time, description) async {
          final success = await updateSubTransaction(
            transactionId: transaction.parentTransactionId,
            subTransactionIndex: subTransactionIndex,
            name: name,
            amount: amount,
            date: date,
            time: time,
            description: description,
          );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transaction updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update transaction'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onDelete: () async {
          final success = await deleteSubTransaction(
            transactionId: transaction.parentTransactionId,
            subTransactionIndex: subTransactionIndex,
          );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transaction deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete transaction'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method to find sub-transaction index
  int? _findSubTransactionIndex(Transaction transaction) {
    print('=== FINDING SUB-TRANSACTION INDEX ===');
    print('Transaction ID: ${transaction.id}');
    print('Parent Transaction ID: ${transaction.parentTransactionId}');
    print('Transaction Title: ${transaction.title}');

    // Get the index directly from parent transaction
    final index = _getSubTransactionIndexFromParent(
      transaction.parentTransactionId,
      transaction.id,
    );

    print('Found index: $index');
    print('=====================================');

    return index;
  }

  // Get sub-transaction index from parent transaction
  int? _getSubTransactionIndexFromParent(
    String parentTransactionId,
    String subTransactionId,
  ) {
    // Find all sub-transactions with this parent ID and sort them consistently
    final subTransactionsWithSameParent = _transactionDataService
        .allSubTransactions
        .where((sub) => sub.parentTransactionId == parentTransactionId)
        .toList();

    print(
      'Found ${subTransactionsWithSameParent.length} sub-transactions with parent ID: $parentTransactionId',
    );

    // Find the index by matching the sub-transaction ID
    for (int i = 0; i < subTransactionsWithSameParent.length; i++) {
      print(
        '  [$i] ID: ${subTransactionsWithSameParent[i].id}, Name: ${subTransactionsWithSameParent[i].name}',
      );
      if (subTransactionsWithSameParent[i].id == subTransactionId) {
        print('✅ Match found at index $i');
        return i;
      }
    }

    print('❌ No match found for sub-transaction ID: $subTransactionId');
    return null;
  }
}
