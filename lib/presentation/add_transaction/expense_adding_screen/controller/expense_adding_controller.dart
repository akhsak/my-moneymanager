import 'dart:collection';
import 'package:flutter/material.dart';

import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/repository/auth/services/shared_data_service.dart';
import 'package:monaymanagment/repository/category/service/category_service.dart';
import 'package:monaymanagment/repository/loan/service/loan_service.dart';
import 'package:monaymanagment/repository/reminder/service/reminder_service.dart';
import 'package:monaymanagment/repository/target/service/target_service.dart';
import 'package:monaymanagment/repository/transaction/service/expense_service.dart';

class ExpenseAddingController extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final ReminderService _reminderService = ReminderService();
  final ExpenseService _expenseService = ExpenseService();
  final TargetService _targetService = TargetService();
  final LoanService _loanService = LoanService();

  DateTime date = DateTime.now();
  String? category;
  String? selectedTitle;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController newTitleController = TextEditingController();

  // Loan-specific fields
  final TextEditingController loanNameController = TextEditingController();
  final TextEditingController principalController = TextEditingController();
  final TextEditingController loanNoteController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  // Title management
  List<String> _expenseTitles = [];
  List<String> _incomeTitles = [];
  bool _titlesLoading = false;
  String? _titlesError;
  bool _showNewTitleField = false;

  // Transaction mode: 'income', 'expense', 'loan'
  String _transactionMode = 'income';
  DateTime? _loanDeadline;

  // Getters
  String get transactionMode => _transactionMode;
  DateTime? get loanDeadline => _loanDeadline;

  // Initialize controllers with listeners
  ExpenseAddingController() {
    amountController.addListener(_validateForm);
    titleController.addListener(_validateForm);
    notesController.addListener(_validateForm);
    _loadTitles();
  }

  // Set transaction mode
  void setTransactionMode(String mode) {
    if (_isDisposed) return;
    _transactionMode = mode;
    // Clear form when switching modes
    _clearForm();
    notifyListeners();
  }

  // Set loan deadline
  void setLoanDeadline(DateTime? deadline) {
    if (_isDisposed) return;
    _loanDeadline = deadline;
    notifyListeners();
  }

  // Title management getters
  List<String> get expenseTitles =>
      List.unmodifiable(_dedupeList(_expenseTitles));
  List<String> get incomeTitles =>
      List.unmodifiable(_dedupeList(_incomeTitles));
  bool get titlesLoading => _titlesLoading;
  String? get titlesError => _titlesError;
  bool get showNewTitleField => _showNewTitleField;

  List<String> _dedupeList(List<String> source) {
    return LinkedHashSet<String>.from(source).toList();
  }

  // Load titles from API
  Future<void> _loadTitles() async {
    _titlesLoading = true;
    _titlesError = null;
    notifyListeners();

    try {
      // Load default titles for common categories
      _expenseTitles = await _expenseService.getExpenseTitles();
      _incomeTitles = await _expenseService.getIncomeTitles();
    } catch (e) {
      _titlesError = e.toString();
      print('Error loading titles: $e');
      // Leave titles empty if API fails
      _expenseTitles = [];
      _incomeTitles = [];
    } finally {
      _validateSelectedTitle();
      _titlesLoading = false;
      notifyListeners();
    }
  }

  void _validateSelectedTitle() {
    if (selectedTitle == null || selectedTitle!.isEmpty) return;
    if (_transactionMode == 'loan') {
      selectedTitle = null;
      return;
    }

    final List<String> activeTitles = _transactionMode == 'income'
        ? _dedupeList(_incomeTitles)
        : _dedupeList(_expenseTitles);

    if (!activeTitles.contains(selectedTitle)) {
      selectedTitle = null;
    }
  }

  // Load titles for specific category
  Future<void> loadTitlesForCategory(String categoryName, bool isIncome) async {
    // Defer the loading state change to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isDisposed) {
        _titlesLoading = true;
        _titlesError = null;
        notifyListeners();
      }

      try {
        if (isIncome) {
          _incomeTitles = await _expenseService.getIncomeTitles(
            categoryName: categoryName,
          );
        } else {
          _expenseTitles = await _expenseService.getExpenseTitles(
            categoryName: categoryName,
          );
        }
        _validateSelectedTitle();
      } catch (e) {
        _titlesError = e.toString();
        print('Error loading titles for category: $e');
      } finally {
        if (!_isDisposed) {
          _titlesLoading = false;
          notifyListeners();
        }
      }
    });
  }

  // Set selected title
  void setSelectedTitle(String? title) {
    selectedTitle = title;
    if (title != null && title != 'add_new') {
      titleController.text = title;
    }
    notifyListeners();
  }

  // Add new title
  Future<bool> addNewTitle(String title, bool isIncome) async {
    try {
      if (category == null || category!.isEmpty) {
        throw Exception('Please select a category first');
      }

      final success = isIncome
          ? await _expenseService.addIncomeTitle(title, categoryName: category!)
          : await _expenseService.addExpenseTitle(
              title,
              categoryName: category!,
            );

      if (success) {
        // Reload titles for the current category to get the updated list
        await loadTitlesForCategory(category!, isIncome);
        // Set the new title as selected
        setSelectedTitle(title);
        return true;
      } else {
        // If API call failed but title might already exist, add it locally
        if (isIncome) {
          if (!_incomeTitles.contains(title)) {
            _incomeTitles.add(title);
          }
        } else {
          if (!_expenseTitles.contains(title)) {
            _expenseTitles.add(title);
          }
        }
        setSelectedTitle(title);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true; // Allow transaction to proceed
      }
    } catch (e) {
      print('Error adding new title: $e');
      // If API call failed, still add the title locally and allow transaction to proceed
      if (isIncome) {
        if (!_incomeTitles.contains(title)) {
          _incomeTitles.add(title);
        }
      } else {
        if (!_expenseTitles.contains(title)) {
          _expenseTitles.add(title);
        }
      }
      setSelectedTitle(title);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true; // Allow transaction to proceed even if title API failed
    }
  }

  void setDate(DateTime d) {
    date = d;
    notifyListeners();
  }

  void setCategory(String value) {
    if (_isDisposed) return;
    category = value;
    _validateForm();
    // Load titles for the selected category
    if (value.isNotEmpty) {
      // Clear current titles and load category-specific titles
      _expenseTitles.clear();
      _incomeTitles.clear();
      selectedTitle = null; // Reset selected title
      _showNewTitleField = false; // Hide new title field
      newTitleController.clear();
      // Defer notifyListeners to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          notifyListeners();
        }
      });
    } else {
      notifyListeners();
    }
  }

  void showNewTitleFieldMethod() {
    if (_isDisposed) return;
    _showNewTitleField = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  void hideNewTitleField() {
    if (_isDisposed) return;
    _showNewTitleField = false;
    newTitleController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  bool get isValid {
    if (_transactionMode == 'loan') {
      // For loan mode
      return loanNameController.text.trim().isNotEmpty &&
          principalController.text.trim().isNotEmpty &&
          double.tryParse(principalController.text.replaceAll(',', '.')) !=
              null &&
          double.parse(principalController.text.replaceAll(',', '.')) > 0 &&
          _loanDeadline != null;
    } else {
      // For regular expense/income mode
      return (category != null && category!.isNotEmpty) &&
          amountController.text.trim().isNotEmpty &&
          double.tryParse(amountController.text.replaceAll(',', '.')) != null &&
          double.parse(amountController.text.replaceAll(',', '.')) > 0 &&
          (selectedTitle != null || newTitleController.text.trim().isNotEmpty);
    }
  }

  // Validation method for real-time validation
  void _validateForm() {
    notifyListeners(); // Trigger rebuild for validation feedback
  }

  // Get validation errors for display
  List<String> get validationErrors {
    List<String> errors = [];

    if (category == null || category!.isEmpty) {
      errors.add('Please select a category');
    }

    if (amountController.text.trim().isEmpty) {
      errors.add('Please enter an amount');
    } else if (double.tryParse(amountController.text.replaceAll(',', '.')) ==
        null) {
      errors.add('Please enter a valid amount');
    } else if (double.parse(amountController.text.replaceAll(',', '.')) <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (selectedTitle == null && newTitleController.text.trim().isEmpty) {
      errors.add('Please select or enter a title');
    }

    return errors;
  }

  // Getters for loading and error states
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Save expense/income via API
  Future<bool> saveExpense({required bool isIncome}) async {
    // Check validation first
    if (!isValid) {
      _setErrorMessage('Please fill all required fields correctly');
      return false;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final amount = double.parse(amountController.text.replaceAll(',', '.'));
      final finalAmount = isIncome ? amount : -amount; // Negative for expenses

      print('Saving ${isIncome ? 'income' : 'expense'}:');
      print('Category: $category');
      print('Amount: $finalAmount');
      print('Title: ${titleController.text.trim()}');

      // Create sub-transactions - Use selected title or new title
      final subTransactions = <Map<String, dynamic>>[];
      String mainTitle;

      if (newTitleController.text.trim().isNotEmpty) {
        // Use new title from text field
        mainTitle = newTitleController.text.trim();
        // Try to add the title to the API (handles errors gracefully)
        await addNewTitle(mainTitle, isIncome);
      } else if (selectedTitle != null && selectedTitle!.isNotEmpty) {
        // Use selected title from dropdown
        mainTitle = selectedTitle!;
      } else {
        throw Exception('Please select or enter a title');
      }

      // Always create the main transaction with the user's title
      subTransactions.add({
        'name': mainTitle,
        'amount': finalAmount,
        'date': _formatDateForAPI(date),
        'time': _formatTimeForAPI(date),
        'description': notesController.text.trim(),
      });

      print('Sub-transactions: $subTransactions');
      print('Main title: "$mainTitle"');

      // Create transaction with the correct payload structure
      print('Creating transaction...');
      final transactionResponse = await _categoryService.createTransaction(
        categoryName: category!,
        frequency: 'Daily', // Default frequency
        amount: finalAmount,
        currency: 'INR',
        subTransactions: subTransactions,
        year: date.year, // Pass the year from the selected date
        month: date.month, // Pass the month from the selected date
        transactionDate: date, // Pass the complete date object
        title: mainTitle, // Add the title field
        transactionType: isIncome
            ? 'income'
            : 'expense', // Add transaction type
      );

      print('Transaction created successfully: ${transactionResponse.message}');

      if (GuestStorageService.instance.isGuestMode) {
        await SharedDataService.instance.loadTransactions();
      } else {
        // Update target progress if it's an expense
        if (!isIncome) {
          try {
            await _targetService.updateTargetProgress(
              categoryId: '68d7be9af98a2b2530e73717', // Default category ID
              categoryName: category!,
              progress: amount, // Use the expense amount as progress
            );
            print('Target progress updated successfully');
          } catch (e) {
            print('Error updating target progress: $e');
            // Don't fail the entire operation if target update fails
          }
        }

        // Create reminder
        final reminderText =
            '${isIncome ? 'Income' : 'Expense'} added: ${titleController.text.trim()} - ₹${amount.toStringAsFixed(2)}';
        print('Creating reminder: $reminderText');

        final reminderResponse = await _reminderService.createReminder(
          reminder: reminderText,
          date: _formatDateForReminder(date),
          time: _formatTimeForAPI(date),
          type: 'transaction update',
        );

        print('Reminder created successfully: ${reminderResponse.message}');
      }

      // Clear form after successful save
      _clearForm();

      return true;
    } catch (e) {
      print('Error saving expense: $e');
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Save loan via API
  Future<bool> saveLoan() async {
    // Check validation first
    if (!isValid) {
      _setErrorMessage('Please fill all required fields correctly');
      return false;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final principal = double.parse(principalController.text.trim());
      final deadlineStr = _loanDeadline?.toIso8601String().split('T')[0] ?? '';

      print('Saving loan:');
      print('Name: ${loanNameController.text.trim()}');
      print('Principal: $principal');
      print('Deadline: $deadlineStr');

      await _loanService.createLoan(
        name: loanNameController.text.trim(),
        principal: principal,
        deadline: deadlineStr,
        note: loanNoteController.text.trim(),
        categoryId: '68d52c35392e967f1b2b5e47', // Default category ID
      );

      print('Loan created successfully');

      // Clear form after successful save
      _clearForm();

      return true;
    } catch (e) {
      print('Error saving loan: $e');
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear form after successful save
  void _clearForm() {
    category = null;
    amountController.clear();
    titleController.clear();
    notesController.clear();
    newTitleController.clear();
    _showNewTitleField = false;
    selectedTitle = null;

    // Loan fields
    loanNameController.clear();
    principalController.clear();
    loanNoteController.clear();
    _loanDeadline = null;

    notifyListeners();
  }

  Map<String, dynamic> buildExpensePayload() {
    return {
      'date': date.toIso8601String(),
      'category': category,
      'amount': double.parse(amountController.text.replaceAll(',', '.')),
      'title': selectedTitle ?? newTitleController.text.trim(),
      'notes': notesController.text.trim(),
    };
  }

  // Helper methods for date/time formatting
  String _formatDateForAPI(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTimeForAPI(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  String _formatDateForReminder(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    amountController.dispose();
    titleController.dispose();
    notesController.dispose();
    newTitleController.dispose();
    loanNameController.dispose();
    principalController.dispose();
    loanNoteController.dispose();
    super.dispose();
  }
}
