import 'package:flutter/material.dart';

class ChangePasswordDoneController extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Navigate to login or home screen after success
  Future<void> navigateToNextScreen(BuildContext context) async {
    if (_isLoading) return; // Prevent multiple calls
    
    _isLoading = true;
    notifyListeners();

    try {
      // Wait for animation to complete
      await Future.delayed(const Duration(seconds: 3));
      
      // Check if context is still mounted and controller is not disposed
      if (context.mounted && !_isDisposed) {
        // Check if there are routes to pop
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          // If no routes to pop, just print success message
          print('Password changed successfully!');
        }
      }
    } catch (e) {
      print('Error navigating: $e');
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _isDisposed = false;

  // Alternative method to navigate back to previous screen
  void navigateBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
