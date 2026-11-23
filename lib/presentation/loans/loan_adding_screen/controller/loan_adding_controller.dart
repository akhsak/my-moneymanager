import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/category/service/category_service.dart';
import 'package:monaymanagment/repository/loan/service/loan_service.dart';

class LoanAddingController extends ChangeNotifier {
  final LoanService _loanService = LoanService();
  final CategoryService _categoryService = CategoryService();

  // Controllers
  final TextEditingController loanNameController = TextEditingController();
  final TextEditingController principalController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // State variables
  String _category = '';
  DateTime _deadline = DateTime.now().add(
    const Duration(days: 365),
  ); // Default to 1 year from now
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get category => _category;
  DateTime get deadline => _deadline;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isValid {
    return loanNameController.text.trim().isNotEmpty &&
        _category.isNotEmpty &&
        principalController.text.trim().isNotEmpty &&
        _deadline.isAfter(DateTime.now());
  }

  // Setters
  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void setDeadline(DateTime deadline) {
    _deadline = deadline;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> saveLoan() async {
    if (!isValid) {
      _setErrorMessage('Please fill all required fields');
      return false;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final principal = double.tryParse(principalController.text.trim());
      if (principal == null || principal <= 0) {
        _setErrorMessage('Please enter a valid principal amount');
        return false;
      }

      // Get category ID from category name
      final categoryId = await _getCategoryId(_category);
      if (categoryId == null) {
        _setErrorMessage('Category not found');
        return false;
      }

      final result = await _loanService.createLoan(
        name: loanNameController.text.trim(),
        principal: principal,
        deadline: _deadline.toIso8601String().split(
          'T',
        )[0], // Format as YYYY-MM-DD
        note: notesController.text.trim(),
        categoryId: categoryId,
      );

      if (result['success'] == true) {
        // Clear form on success
        _clearForm();
        return true;
      } else {
        _setErrorMessage(
          result['message']?.toString() ?? 'Failed to save loan',
        );
        return false;
      }
    } catch (e) {
      _setErrorMessage('Error saving loan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> _getCategoryId(String categoryName) async {
    try {
      final response = await _categoryService.getCategories();
      if (response.success) {
        final category = response.data.firstWhere(
          (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
          orElse: () => throw Exception('Category not found'),
        );
        return category.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _clearForm() {
    loanNameController.clear();
    principalController.clear();
    interestRateController.clear();
    notesController.clear();
    _category = '';
    _deadline = DateTime.now().add(const Duration(days: 365));
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    loanNameController.dispose();
    principalController.dispose();
    interestRateController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
