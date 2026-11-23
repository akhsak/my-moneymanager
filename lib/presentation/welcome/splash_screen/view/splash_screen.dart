import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/presentation/bottom_navigation_screen/view/bottom_navigation_screen.dart';
import 'package:monaymanagment/presentation/welcome/on_boarding_screen/view/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final guestService = GuestStorageService.instance;
      if (guestService.isGuestMode) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
        );
        return;
      }

      // Check if user is logged in (has valid token)
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Validate token by trying to get current user
        try {
          await _authService.getCurrentUser();
          // Token is valid, navigate to main app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
          );
          return;
        } catch (e) {
          // Token is invalid or expired, continue to onboarding
          await _authService.logout(); // Clear invalid token
        }
      }

      // No valid token, show onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
      );
    } catch (e) {
      // Error checking auth status, show onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.secondaryColor,
      body: const Center(
        child: FractionallySizedBox(
          widthFactor: 0.55,
          child: Image(
            image: AssetImage('assets/on_boarding/finura_white.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
