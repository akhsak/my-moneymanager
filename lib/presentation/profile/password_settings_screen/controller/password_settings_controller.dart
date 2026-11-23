import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';

class PasswordSettingsController extends ChangeNotifier {
  // Services
  final AuthService _authService = AuthService();

  // Text controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Password visibility states
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Loading state
  bool _isLoading = false;

  // Error and success messages
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get showCurrentPassword => _showCurrentPassword;
  bool get showNewPassword => _showNewPassword;
  bool get showConfirmPassword => _showConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Toggle password visibility methods
  void toggleCurrentPassword() {
    _showCurrentPassword = !_showCurrentPassword;
    notifyListeners();
  }

  void toggleNewPassword() {
    _showNewPassword = !_showNewPassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    _showConfirmPassword = !_showConfirmPassword;
    notifyListeners();
  }

  // Update password method
  Future<void> updatePassword() async {
    // Clear previous messages
    _clearMessages();

    // Validation
    if (currentPasswordController.text.isEmpty) {
      _setError('Please enter your current password');
      return;
    }

    if (newPasswordController.text.isEmpty) {
      _setError('Please enter a new password');
      return;
    }

    if (newPasswordController.text.length < 6) {
      _setError('Password must be at least 6 characters long');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _setError('New passwords do not match');
      return;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      _setError('New password must be different from current password');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Call the API service
      await _authService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      // Success
      _setSuccess('Password changed successfully');
      _clearFields();
    } catch (e) {
      // Handle API errors
      String errorMessage = 'Failed to update password';
      if (e.toString().contains('currentPassword')) {
        errorMessage = 'Current password is incorrect';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      _setError(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _showCurrentPassword = false;
    _showNewPassword = false;
    _showConfirmPassword = false;
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _clearMessages();
  }

  // Clear messages when user starts typing
  void onTextChanged() {
    if (_errorMessage != null || _successMessage != null) {
      _clearMessages();
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
