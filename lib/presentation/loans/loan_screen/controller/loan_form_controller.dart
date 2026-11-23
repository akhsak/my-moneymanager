import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/loan/model/loan_model.dart';

import 'package:monaymanagment/repository/loan/service/loan_service.dart';

class LoanFormController extends ChangeNotifier {
  final LoanService _loanService = LoanService();
  
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController principalController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentNoteController = TextEditingController();
  
  // Form state
  DateTime? _selectedDate;
  Loan? _selectedLoan;
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAddingNewLoan = false;
  bool _isPaymentFormInitialized = false;

  // Getters
  DateTime? get selectedDate => _selectedDate;
  Loan? get selectedLoan => _selectedLoan;
  DateTime get paymentDate => _paymentDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAddingNewLoan => _isAddingNewLoan;

  // Constructor
  LoanFormController() {
    // Don't auto-initialize, let the UI control when to initialize
  }

  // Initialize form for editing
  void initializeForEdit(Loan loan) {
    nameController.text = loan.name;
    principalController.text = loan.principal.toString();
    noteController.text = loan.note;
    
    if (loan.deadline.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(loan.deadline);
      } catch (e) {
        _selectedDate = null;
      }
    } else {
      _selectedDate = null;
    }
    notifyListeners();
  }

  // Initialize form for payment
  void initializeForPayment() {
    if (_isPaymentFormInitialized) {
      print('Payment form already initialized, skipping...');
      return;
    }
    
    print('Initializing payment form...');
    amountController.clear();
    paymentNoteController.clear();
    _paymentDate = DateTime.now();
    _selectedLoan = null;
    _errorMessage = null;
    _isPaymentFormInitialized = true;
    print('Payment form initialized. Amount controller: ${amountController.text}, Note controller: ${paymentNoteController.text}');
    notifyListeners();
  }

  // Initialize form for adding loan
  void initializeForAddLoan() {
    nameController.clear();
    principalController.clear();
    noteController.clear();
    _selectedDate = null;
    _selectedLoan = null;
    _isAddingNewLoan = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Set selected loan from dropdown for editing
  void setSelectedLoanForEdit(Loan? loan) {
    _selectedLoan = loan;
    _isAddingNewLoan = false;
    if (loan != null) {
      nameController.text = loan.name;
      principalController.text = loan.principal.toString();
      noteController.text = loan.note;
      if (loan.deadline.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(loan.deadline);
        } catch (e) {
          _selectedDate = null;
        }
      } else {
        _selectedDate = null;
      }
    }
    notifyListeners();
  }

  // Set adding new loan mode
  void setAddingNewLoan(bool isAdding) {
    _isAddingNewLoan = isAdding;
    if (isAdding) {
      _selectedLoan = null;
      nameController.clear();
      principalController.clear();
      noteController.clear();
      _selectedDate = null;
    }
    notifyListeners();
  }

  // Set selected date
  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Set payment date
  void setPaymentDate(DateTime date) {
    _paymentDate = date;
    notifyListeners();
  }

  // Set selected loan for payment
  void setSelectedLoan(Loan? loan) {
    _selectedLoan = loan;
    notifyListeners();
  }

  // Create loan
  Future<bool> createLoan() async {
    if (!_validateLoanForm()) return false;
    
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final deadlineStr = _selectedDate?.toIso8601String().split('T')[0] ?? '';
      
      final response = await _loanService.createLoan(
        name: nameController.text.trim(),
        principal: double.parse(principalController.text.trim()),
        deadline: deadlineStr,
        note: noteController.text.trim(),
        categoryId: '68d52c35392e967f1b2b5e47', // Default category ID
      );

      if (response['success'] == true) {
        clearForm();
        return true;
      } else {
        throw Exception('Failed to create loan: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setErrorMessage('Failed to create loan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update loan
  Future<bool> updateLoan(String loanId) async {
    if (!_validateLoanForm()) return false;
    
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final deadlineStr = _selectedDate?.toIso8601String().split('T')[0] ?? '';
      
      final response = await _loanService.updateLoan(
        loanId: loanId,
        name: nameController.text.trim(),
        principal: double.parse(principalController.text.trim()),
        deadline: deadlineStr,
        note: noteController.text.trim(),
        categoryId: '68d52c35392e967f1b2b5e47', // Default category ID
      );

      if (response['success'] == true) {
        print('Loan updated successfully: ${response['message']}');
        return true;
      } else {
        throw Exception('Failed to update loan: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error updating loan: $e');
      _setErrorMessage('Failed to update loan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add payment
  Future<bool> addPayment() async {
    if (!_validatePaymentForm()) return false;
    
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final dateStr = _paymentDate.toIso8601String().split('T')[0];
      
      final response = await _loanService.addPayment(
        loanId: _selectedLoan!.id,
        amount: double.parse(amountController.text.trim()),
        date: dateStr,
        note: paymentNoteController.text.trim(),
      );

      if (response['success'] == true) {
        clearPaymentForm();
        return true;
      } else {
        throw Exception('Failed to add payment: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setErrorMessage('Failed to add payment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Validation methods
  bool _validateLoanForm() {
    if (nameController.text.trim().isEmpty) {
      _setErrorMessage('Please enter loan name');
      return false;
    }
    
    final principal = double.tryParse(principalController.text.trim());
    if (principal == null || principal <= 0) {
      _setErrorMessage('Please enter a valid principal amount');
      return false;
    }
    
    return true;
  }

  bool _validatePaymentForm() {
    if (_selectedLoan == null) {
      _setErrorMessage('Please select a loan');
      return false;
    }
    
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _setErrorMessage('Please enter a valid payment amount');
      return false;
    }
    
    if (amount > _selectedLoan!.balanceToPay) {
      _setErrorMessage('Amount cannot exceed loan balance');
      return false;
    }
    
    return true;
  }


  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _setErrorMessage(null);
  }

  // Clear all form data
  void clearForm() {
    nameController.clear();
    principalController.clear();
    noteController.clear();
    _selectedDate = null;
    _setErrorMessage(null);
    notifyListeners();
  }

  // Clear payment form data
  void clearPaymentForm() {
    amountController.clear();
    paymentNoteController.clear();
    _selectedLoan = null;
    _paymentDate = DateTime.now();
    _setErrorMessage(null);
    _isPaymentFormInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    principalController.dispose();
    noteController.dispose();
    amountController.dispose();
    paymentNoteController.dispose();
    super.dispose();
  }
}
