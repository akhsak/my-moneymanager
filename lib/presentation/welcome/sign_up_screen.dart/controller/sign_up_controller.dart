import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/auth/model/user_model.dart';

class SignUpController extends ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearFields() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    clearErrorMessage();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Validate inputs
  bool _validateInputs() {
    if (fullNameController.text.trim().isEmpty) {
      setErrorMessage('Please enter your full name');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      setErrorMessage('Please enter your email');
      return false;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      setErrorMessage('Please enter a valid email address');
      return false;
    }
    if (passwordController.text.isEmpty) {
      setErrorMessage('Please enter a password');
      return false;
    }
    if (passwordController.text.length < 6) {
      setErrorMessage('Password must be at least 6 characters long');
      return false;
    }
    if (confirmPasswordController.text.isEmpty) {
      setErrorMessage('Please confirm your password');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      setErrorMessage('Passwords do not match');
      return false;
    }
    return true;
  }

  // Sign up method
  Future<RegisterResponse?> signUp() async {
    clearErrorMessage();

    if (!_validateInputs()) {
      return null;
    }

    setLoading(true);

    try {
      final response = await _authService.register(
        name: fullNameController.text.trim(),
        username: emailController.text.trim(), // Using email as username
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: '', // Empty phone
        dateOfBirth: '', // Empty date of birth
      );
      clearFields();
      return response;
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Navigate to login
  void navigateToLogin() {
    debugPrint('Navigate to login');
  }

  // Open terms of use
  void openTermsOfUse() {
    debugPrint('Open Terms of Use');
  }

  // Open privacy policy
  void openPrivacyPolicy() {
    debugPrint('Open Privacy Policy');
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
