import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/repository/category/model/category_model.dart';
import 'package:monaymanagment/repository/category/service/category_service.dart';
import 'package:monaymanagment/repository/transaction/service/transaction_data_service.dart';


class SharedDataService {
  static SharedDataService? _instance;
  static SharedDataService get instance {
    _instance ??= SharedDataService._internal();
    return _instance!;
  }

  SharedDataService._internal();

  final TransactionDataService _transactionService = TransactionDataService();
  final CategoryService _categoryService = CategoryService();

  // Cached data
  List<CategoryModel>? _cachedCategories;
  bool _isLoadingCategories = false;
  bool _isLoadingTransactions = false;
  DateTime? _lastCategoryFetch;
  DateTime? _lastTransactionFetch;

  // Get cached categories or load if needed
  Future<List<CategoryModel>> getCategories() async {
    // CategoryService will handle token/guest mode logic internally
    // We just need to call it and cache the result

    if (_cachedCategories != null && _lastCategoryFetch != null) {
      final timeDiff = DateTime.now().difference(_lastCategoryFetch!);
      if (timeDiff.inMinutes < 5) {
        // Cache for 5 minutes
        return _cachedCategories!;
      }
    }

    if (_isLoadingCategories) {
      // Wait for current loading to complete
      while (_isLoadingCategories) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedCategories ?? [];
    }

    _isLoadingCategories = true;
    try {
      final response = await _categoryService.getCategories();
      _cachedCategories = response.data;
      _lastCategoryFetch = DateTime.now();
      return _cachedCategories!;
    } finally {
      _isLoadingCategories = false;
    }
  }

  // Get transaction data
  Future<void> loadTransactions() async {
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      await _transactionService.loadAllTransactions();
      _lastTransactionFetch = DateTime.now();
      return;
    }

    if (_lastTransactionFetch != null) {
      final timeDiff = DateTime.now().difference(_lastTransactionFetch!);
      if (timeDiff.inMinutes < 2) {
        // Cache for 2 minutes
        return;
      }
    }

    if (_isLoadingTransactions) {
      return; // Already loading
    }

    _isLoadingTransactions = true;
    try {
      await _transactionService.loadAllTransactions();
      _lastTransactionFetch = DateTime.now();
    } finally {
      _isLoadingTransactions = false;
    }
  }

  // Get transaction data service (for direct access to cached data)
  TransactionDataService get transactionService => _transactionService;

  // Load all data at once
  Future<void> loadAllData() async {
    await Future.wait([getCategories(), loadTransactions()]);
  }

  // Clear all cache
  void clearCache() {
    _cachedCategories = null;
    _lastCategoryFetch = null;
    _lastTransactionFetch = null;
  }

  // Check if data is fresh
  bool get hasFreshData {
    final now = DateTime.now();
    final categoryFresh =
        _lastCategoryFetch != null &&
        now.difference(_lastCategoryFetch!).inMinutes < 5;
    final transactionFresh =
        _lastTransactionFetch != null &&
        now.difference(_lastTransactionFetch!).inMinutes < 2;
    return categoryFresh && transactionFresh;
  }
}
