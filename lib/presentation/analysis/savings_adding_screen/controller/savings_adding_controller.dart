import 'package:flutter/material.dart';

class SavingsAddingController extends ChangeNotifier {
  DateTime date = DateTime.now();
  String? category;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Available categories for savings
  final List<String> categories = [
    'Travel',
    'New House',
    'Car',
    'Wedding',
    'Education',
    'Emergency Fund',
    'Vacation',
    'Investment',
  ];

  void setDate(DateTime d) {
    date = d;
    notifyListeners();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  bool get isValid =>
      (category != null && category!.isNotEmpty) &&
      double.tryParse(amountController.text.replaceAll(',', '.')) != null &&
      titleController.text.trim().isNotEmpty;

  Map<String, dynamic> buildSavingsPayload() {
    return {
      'date': date.toIso8601String(),
      'category': category,
      'amount': double.parse(amountController.text.replaceAll(',', '.')),
      'title': titleController.text.trim(),
      'message': messageController.text.trim(),
    };
  }

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
