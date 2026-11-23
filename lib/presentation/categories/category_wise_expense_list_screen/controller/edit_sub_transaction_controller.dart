import 'package:flutter/material.dart';

class EditSubTransactionController extends ChangeNotifier {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _timeController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late double _originalAmount;
  bool _isLoading = false;

  // Getters
  TextEditingController get nameController => _nameController;
  TextEditingController get amountController => _amountController;
  TextEditingController get timeController => _timeController;
  TextEditingController get descriptionController => _descriptionController;
  DateTime get selectedDate => _selectedDate;
  double get originalAmount => _originalAmount;
  bool get isLoading => _isLoading;

  EditSubTransactionController({
    required String name,
    required double amount,
    required DateTime date,
    required String time,
    required String description,
  }) {
    _nameController = TextEditingController(text: name);
    _originalAmount = amount;
    // Show absolute value in the field, but preserve the original sign
    _amountController = TextEditingController(text: amount.abs().toString());
    _timeController = TextEditingController(text: time);
    _descriptionController = TextEditingController(text: description);
    _selectedDate = date;
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
