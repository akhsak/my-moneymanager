import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/auth/model/user_model.dart';

class LoginScreenController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
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

  // Validate input
  bool _validateInput() {
    if (emailController.text.trim().isEmpty) {
      setErrorMessage('Please enter your username or email');
      return false;
    }
    if (passwordController.text.isEmpty) {
      setErrorMessage('Please enter your password');
      return false;
    }
    return true;
  }

  // Login method
  Future<AuthResponse?> login() async {
    clearErrorMessage();

    if (!_validateInput()) {
      return null;
    }

    setLoading(true);

    try {
      final response = await _authService.login(
        username: emailController.text.trim(),
        password: passwordController.text,
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

  // Forgot password method
  void forgotPassword() {
    // Handle forgot password logic
    debugPrint('Forgot password tapped');
  }

  // Social login methods
  void loginWithFacebook() {
    debugPrint('Facebook login tapped');
  }

  void loginWithGoogle() {
    debugPrint('Google login tapped');
  }

  // Navigate to sign up
  void navigateToSignUp() {
    debugPrint('Navigate to sign up');
  }

  // Use fingerprint
  void useFingerprint() {
    debugPrint('Use fingerprint tapped');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
