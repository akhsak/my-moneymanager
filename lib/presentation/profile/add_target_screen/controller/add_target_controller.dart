import 'package:flutter/material.dart';

class AddTargetController extends ChangeNotifier {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  String? selectedCategoryId;
  String? selectedCategoryName;
  
  bool _isLoading = false;
  String? _errorMessage;

  // Initialize controllers with listeners
  AddTargetController() {
    amountController.addListener(_validateForm);
    descriptionController.addListener(_validateForm);
  }

  void setCategory(String categoryId) {
    selectedCategoryId = categoryId;
    _validateForm();
    notifyListeners();
  }

  bool get isValid =>
      selectedCategoryId != null &&
      selectedCategoryId!.isNotEmpty &&
      amountController.text.trim().isNotEmpty &&
      double.tryParse(amountController.text.replaceAll(',', '.')) != null &&
      double.parse(amountController.text.replaceAll(',', '.')) > 0;

  // Validation method for real-time validation
  void _validateForm() {
    notifyListeners(); // Trigger rebuild for validation feedback
  }

  // Get validation errors for display
  List<String> get validationErrors {
    List<String> errors = [];
    
    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      errors.add('Please select a category');
    }
    
    if (amountController.text.trim().isEmpty) {
      errors.add('Please enter a target amount');
    } else if (double.tryParse(amountController.text.replaceAll(',', '.')) == null) {
      errors.add('Please enter a valid amount');
    } else if (double.parse(amountController.text.replaceAll(',', '.')) <= 0) {
      errors.add('Amount must be greater than 0');
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

  // Save target via API
  Future<bool> saveTarget() async {
    // Check validation first
    if (!isValid) {
      _setErrorMessage('Please fill all required fields correctly');
      return false;
    }
    
    _setLoading(true);
    _setErrorMessage(null);
    
    try {
      final amount = double.parse(amountController.text.replaceAll(',', '.'));
      
      print('Creating target:');
      print('Category ID: $selectedCategoryId');
      print('Amount: $amount');
      
      // Get the MyTargetController from the context and call addTarget
      // This will be handled by the screen that has access to the controller
      return true;
      
    } catch (e) {
      print('Error creating target: $e');
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
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
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}