import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/repository/category/model/category_model.dart';
import 'package:monaymanagment/repository/category/service/category_service.dart';

import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/repository/transaction/service/transaction_data_service.dart';

class CategoryController extends ChangeNotifier {
  static CategoryController? _instance;
  bool _disposed = false;

  // Singleton pattern to ensure data persistence
  factory CategoryController() {
    if (_instance == null || _instance!._disposed) {
      _instance = CategoryController._internal();
    }
    return _instance!;
  }

  CategoryController._internal();

  final CategoryService _categoryService = CategoryService();
  final TransactionDataService _transactionDataService =
      TransactionDataService();
  final GuestStorageService _guestStorage = GuestStorageService.instance;

  // Target amount (can be set by user)
  double targetAmount = 20000.00;

  // Selected category index
  int selectedCategoryIndex = 0; // Food is selected by default

  // API Categories data
  List<CategoryModel> apiCategories = [];
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  bool _isDataLoaded = false;
  String? _errorMessage;
  bool? _lastGuestMode;

  // Cached financial data to prevent lag
  double? _cachedTotalBalance;
  double? _cachedTotalExpense;
  DateTime? _lastDataFetch;

  // Initialize controller (private constructor for singleton)
  // Don't auto-load in constructor to prevent setState during build

  // Getters for real financial data with caching
  double get totalBalance {
    if (_cachedTotalBalance == null || _shouldRefreshData()) {
      _cachedTotalBalance = _transactionDataService.totalBalance;
    }
    return _cachedTotalBalance!;
  }

  double get totalExpense {
    if (_cachedTotalExpense == null || _shouldRefreshData()) {
      _cachedTotalExpense = _transactionDataService.totalExpense;
    }
    return _cachedTotalExpense!;
  }

  double get progressPercentage => targetAmount > 0
      ? (totalExpense / targetAmount * 100).clamp(0.0, 100.0)
      : 0.0;

  // UI Categories data (for display with icons)
  List<Category> categories = [];

  // Methods for category selection
  void selectCategory(int index) {
    if (_disposed) return;
    selectedCategoryIndex = index;
    notifyListeners();
  }

  bool isSelected(int index) {
    return selectedCategoryIndex == index;
  }

  void updateTargetAmount(double newTarget) {
    if (_disposed) return;
    targetAmount = newTarget;
    notifyListeners();
  }

  // Helper method to check if data should be refreshed
  bool _shouldRefreshData() {
    if (_lastDataFetch == null) return true;
    final timeDiff = DateTime.now().difference(_lastDataFetch!);
    return timeDiff.inSeconds > 60; // Refresh every minute
  }

  // Clear cached data
  void _clearCache() {
    _cachedTotalBalance = null;
    _cachedTotalExpense = null;
    _lastDataFetch = null;
  }

  Future<void> _loadTransactionData() async {
    _setTransactionLoading(true);
    try {
      await _transactionDataService.loadAllTransactions();
      _lastDataFetch = DateTime.now();
      // Clear cache to force refresh
      _clearCache();
    } catch (e) {
      // Handle transaction loading errors silently or log them
      print('Transaction loading error: $e');
    } finally {
      _setTransactionLoading(false);
    }
  }

  Future<void> refreshData() async {
    await loadCategories(forceReload: true);
  }

  // Add new category
  void addCategory(String name, IconData icon) {
    if (_disposed) return;

    // Check if category already exists
    bool categoryExists = categories.any(
      (category) => category.label.toLowerCase() == name.toLowerCase(),
    );

    if (!categoryExists) {
      // Add new category before the "More" category
      final newCategory = Category(
        icon: icon,
        label: name,
        backgroundColor: Colors.white,
        iconColor: const Color(0xFF87CEEB),
        textColor: ColorTheme.mainColor,
      );

      // Insert before the last item (More)
      categories.insert(categories.length - 1, newCategory);
      notifyListeners();
    }
  }

  // Get all category names for dropdown
  List<String> getCategoryNames() {
    // Combine API categories with UI categories
    List<String> categoryNames = [];

    // Add API categories
    for (var apiCategory in apiCategories) {
      categoryNames.add(apiCategory.name);
    }

    // Add UI categories (excluding More)
    for (var category in categories) {
      if (category.label != 'More' && !categoryNames.contains(category.label)) {
        categoryNames.add(category.label);
      }
    }

    return categoryNames;
  }

  // Getters for loading and error states
  bool get isLoading => _isLoading || _isLoadingTransactions;
  bool get isLoadingCategories => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get isDataLoaded => _isDataLoaded;
  String? get errorMessage => _errorMessage;
  bool get isGuestMode => _guestStorage.isGuestMode;
  bool get needsModeReload =>
      _lastGuestMode == null || _lastGuestMode != _guestStorage.isGuestMode;
  IconData getIconForCategory(String categoryName) {
    final uiCategory = categories.firstWhere(
      (category) => category.label.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => Category(
        icon: _getIconFromString(categoryName.toLowerCase()),
        label: '',
        backgroundColor: Colors.white,
        iconColor: const Color(0xFF87CEEB),
        textColor: ColorTheme.mainColor,
      ),
    );
    if (uiCategory.label.isNotEmpty) {
      return uiCategory.icon;
    }

    final apiCategory = apiCategories.firstWhere(
      (apiCat) => apiCat.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => CategoryModel(
        id: '',
        name: categoryName,
        icon: categoryName.toLowerCase(),
        isActive: true,
        userId: '',
        createdAt: '',
        updatedAt: '',
      ),
    );
    if (apiCategory.id.isNotEmpty) {
      return _getIconFromString(apiCategory.icon);
    }

    return _getIconFromString(categoryName.toLowerCase());
  }

  // Load categories and transaction data
  Future<void> loadCategories({bool forceReload = false}) async {
    final currentGuestMode = _guestStorage.isGuestMode;
    if (_lastGuestMode == null || _lastGuestMode != currentGuestMode) {
      forceReload = true;
      _lastGuestMode = currentGuestMode;
    }
    if (_isLoading) return; // Prevent multiple simultaneous calls
    if (_isDataLoaded && !forceReload) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([_loadCategoriesFromAPI(), _loadTransactionData()]);
      _isDataLoaded = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load categories from API
  Future<void> _loadCategoriesFromAPI() async {
    final response = await _categoryService.getCategories();
    apiCategories = response.data;

    // Update UI categories with API data
    _updateUICategories();
  }

  // Create category via API
  Future<bool> createCategory(String name, IconData icon) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Optimistic UI update for instant feedback
      final optimisticCategory = Category(
        icon: icon,
        label: name,
        backgroundColor: Colors.white,
        iconColor: const Color(0xFF87CEEB),
        textColor: ColorTheme.mainColor,
      );
      // Insert before the last item (More) if present
      final insertIndex = categories.isNotEmpty ? (categories.length - 1) : 0;
      categories.insert(insertIndex, optimisticCategory);
      notifyListeners();

      final response = await _categoryService.createCategory(
        name: name,
        icon: _getIconString(icon),
      );

      // Add to API categories
      if (response.data != null) {
        apiCategories.add(response.data!);

        // Update UI categories
        _updateUICategories();

        return true;
      } else {
        _errorMessage = 'Failed to create category: No data returned';
        notifyListeners();
        // Rollback optimistic insert
        categories.removeWhere((c) => c.label == name);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      // Rollback optimistic insert
      categories.removeWhere((c) => c.label == name);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update category via API
  Future<bool> updateCategory(
    String categoryId,
    String name,
    String icon,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _categoryService.updateCategory(
        categoryId: categoryId,
        name: name,
        icon: icon,
      );

      if (response.success) {
        // Update the category in our local list
        final index = apiCategories.indexWhere((cat) => cat.id == categoryId);
        if (index != -1) {
          apiCategories[index] = response.data!;
          _updateUICategories();
        }
        return true;
      } else {
        _errorMessage = 'Failed to update category';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete category via API
  Future<bool> deleteCategory(String categoryName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _categoryService.deleteCategory(
        categoryName: categoryName,
      );

      if (response['success'] == true) {
        // Remove from API categories
        apiCategories.removeWhere((cat) => cat.name == categoryName);
        _updateUICategories();
        return true;
      } else {
        _errorMessage = 'Failed to delete category';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get category by name (case-insensitive)
  CategoryModel? getCategoryByName(String name) {
    print('Looking for category: $name');
    print(
      'Available categories: ${apiCategories.map((cat) => cat.name).toList()}',
    );
    try {
      final found = apiCategories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      );
      print('Found category: ${found.name}');
      return found;
    } catch (e) {
      print('Category not found: $name');
      return null;
    }
  }

  // Update UI categories with API data
  void _updateUICategories() {
    if (_disposed) return;

    List<Category> updatedCategories = [];

    // Add API categories with default icons
    for (var apiCategory in apiCategories) {
      updatedCategories.add(
        Category(
          icon: _getIconFromString(apiCategory.icon),
          label: apiCategory.name,
          backgroundColor: Colors.white,
          iconColor: const Color(0xFF87CEEB),
          textColor: ColorTheme.mainColor,
        ),
      );
    }

    // Add More button at the end
    updatedCategories.add(
      Category(
        icon: Icons.add,
        label: 'More',
        backgroundColor: Colors.white,
        iconColor: const Color(0xFF87CEEB),
        textColor: ColorTheme.mainColor,
      ),
    );

    categories = updatedCategories;
    notifyListeners();
  }

  // Helper methods for icon conversion
  String _getIconString(IconData icon) {
    // Map IconData to string representation
    if (icon == Icons.local_drink) return 'drink';
    if (icon == Icons.directions_bus) return 'bus';
    if (icon == Icons.restaurant) return 'food';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.watch) return 'watch';
    if (icon == Icons.cloud) return 'cloud';
    if (icon == Icons.shopping_bag) return 'shopping';
    if (icon == Icons.card_giftcard) return 'gift';
    if (icon == Icons.movie) return 'movie';
    if (icon == Icons.local_pharmacy) return 'medicine';
    if (icon == Icons.account_balance_wallet) return 'wallet';
    if (icon == Icons.savings) return 'savings';
    if (icon == Icons.attach_money) return 'money';
    if (icon == Icons.medication) return 'medicine';
    if (icon == Icons.water_drop) return 'water';
    if (icon == Icons.directions_car) return 'car';
    if (icon == Icons.access_time) return 'time';
    if (icon == Icons.phone) return 'phone';
    return 'default';
  }

  IconData _getIconFromString(String iconString) {
    // Map string to IconData
    switch (iconString.toLowerCase()) {
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
      case 'cloud':
        return Icons.cloud;
      case 'shopping':
        return Icons.shopping_bag;
      case 'gift':
        return Icons.card_giftcard;
      case 'movie':
        return Icons.movie;
      case 'medicine':
        return Icons.local_pharmacy;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'money':
        return Icons.attach_money;
      case 'restaurant':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'water':
        return Icons.water_drop;
      case 'car':
        return Icons.directions_car;
      case 'time':
        return Icons.access_time;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.category;
    }
  }

  // Set loading state

  // Set transaction loading state
  void _setTransactionLoading(bool loading) {
    if (_disposed) return;
    _isLoadingTransactions = loading;
  }

  // Set error message
  void _setErrorMessage(String? message) {
    if (_disposed) return;
    _errorMessage = message;
  }

  // Clear error message
  void clearErrorMessage() {
    _setErrorMessage(null);
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // Preserve singleton pattern - never actually dispose when Provider calls it
    print(
      'CategoryController.dispose() called - singleton preserved, not disposing',
    );
    // This is intentionally a no-op to preserve the singleton pattern
    // Provider will call dispose() but we override it to keep the controller alive
  }

  // Internal method for actually disposing when needed
  void _actuallyDispose() {
    _disposed = true;
  }

  // Reset singleton instance (for testing or app restart)
  static void resetInstance() {
    _instance?._actuallyDispose();
    _instance = null;
  }
}

class Category {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  Category({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });
}
