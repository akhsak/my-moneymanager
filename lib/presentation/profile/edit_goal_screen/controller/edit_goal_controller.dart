import 'package:flutter/material.dart';

import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';
import 'package:monaymanagment/repository/target/service/target_service.dart';

class EditGoalController extends ChangeNotifier {
  final Target originalTarget;
  final TargetService _targetService = TargetService();
  final TextEditingController targetAmountController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategoryId;

  EditGoalController(this.originalTarget) {
    _initializeControllers();
  }

  void _initializeControllers() {
    targetAmountController.text = originalTarget.amount.toStringAsFixed(2);
    _selectedCategoryId = originalTarget.categoryId;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoryId => _selectedCategoryId;

  void setCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> saveChanges(BuildContext context, CategoryController categoryController) async {
    final targetAmount = double.tryParse(targetAmountController.text);

    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid target amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      // Keep the original progress percentage
      final progress = originalTarget.progress;
      
      // Get the selected category name
      final selectedCategory = categoryController.apiCategories.firstWhere(
        (cat) => cat.id == _selectedCategoryId,
      );
      final selectedCategoryName = selectedCategory.name;
      
      // Update target via API with all fields
      await _targetService.updateTarget(
        targetId: originalTarget.id,
        categoryId: _selectedCategoryId!,
        category: selectedCategoryName,
        amount: targetAmount,
        progress: progress,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      _setErrorMessage('Failed to update target: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update target: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    targetAmountController.dispose();
    super.dispose();
  }
}
