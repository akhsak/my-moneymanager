import 'package:flutter/material.dart';

class ForgotPasswordController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;

  void clearFields() {
    emailController.clear();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Next step method
  Future<bool> nextStep() async {
    if (emailController.text.isEmpty) {
      // Handle validation error
      debugPrint('Please enter email address');
      return false;
    }

    setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Handle successful email send
      debugPrint('Reset email sent successfully');
      clearFields();
      return true;
    } catch (e) {
      // Handle error
      debugPrint('Error sending reset email: $e');
      return false;
    } finally {
      setLoading(false);
    }
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

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
