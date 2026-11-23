import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';

class DeleteAccountController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController passwordController = TextEditingController();

  bool showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  Future<bool> confirmDelete() async {
    // Clear previous messages
    _clearMessages();

    // Validate password
    if (passwordController.text.trim().isEmpty) {
      _setError('Please enter your password to confirm deletion');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Call delete account API
      await _authService.deleteAccount(
        password: passwordController.text.trim(),
      );

      _setSuccess('Account deleted successfully');
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      String errorMessage = 'Failed to delete account';

      if (e.toString().contains('password')) {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      _setError(errorMessage);
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  void cancel() {
    // Clear fields and messages
    passwordController.clear();
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
  }

  void onPasswordChanged() {
    if (_errorMessage != null || _successMessage != null) {
      _clearMessages();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
