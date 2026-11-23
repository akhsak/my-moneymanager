import 'package:flutter/material.dart';

class OtpController extends ChangeNotifier {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  String _otp = '';

  // Getters
  List<TextEditingController> get otpControllers => _otpControllers;
  List<FocusNode> get focusNodes => _focusNodes;
  bool get isLoading => _isLoading;
  String get otp => _otp;

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Update OTP
  void updateOtp() {
    _otp = _otpControllers.map((controller) => controller.text).join();
    notifyListeners();
  }

  // Handle OTP input
  void onOtpChanged(String value, int index) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty) {
      // Move to previous field
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    updateOtp();
  }

  // Accept OTP
  Future<void> acceptOtp() async {
    if (_otp.length != 6) {
      debugPrint('Please enter complete OTP');
      return;
    }

    setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Handle successful OTP verification
      debugPrint('OTP verified successfully: $_otp');
      
    } catch (e) {
      // Handle OTP verification error
      debugPrint('OTP verification error: $e');
    } finally {
      setLoading(false);
    }
  }

  // Send OTP again
  Future<void> sendAgain() async {
    setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Clear current OTP
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _otp = '';
      _focusNodes[0].requestFocus();
      
      debugPrint('OTP sent again');
      
    } catch (e) {
      // Handle error
      debugPrint('Error sending OTP: $e');
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
