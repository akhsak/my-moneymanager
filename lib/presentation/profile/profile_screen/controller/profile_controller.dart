import 'dart:io';
import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/repository/auth/model/user_model.dart';
import 'package:monaymanagment/presentation/profile/edit_profile_screen/view/edit_profile_screen.dart';
import 'package:monaymanagment/presentation/profile/notification_settings_screen/view/notification_settings_screen.dart';
import 'package:monaymanagment/presentation/profile/my_target_screen/view/my_target_screen.dart';
import 'package:monaymanagment/presentation/welcome/login_screen/view/login_screen.dart';
import 'package:monaymanagment/presentation/welcome/splash_screen/view/splash_screen.dart';
import 'package:monaymanagment/presentation/profile/help_screen/view/help_screen.dart';
import 'package:monaymanagment/presentation/profile/settings_screen/view/settings_screen.dart';

class ProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GuestStorageService _guestService = GuestStorageService.instance;
  bool _isDisposed = false;

  // User information
  String userName = 'Loading...';
  String userId = '';
  String userPhone = '';
  String userEmail = '';
  String profileImageUrl =
      ''; // Empty by default, will be set from API or use fallback
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGuestMode => _guestService.isGuestMode;

  // Initialize controller and load user data
  ProfileController() {
    loadUserProfile();
  }

  // Set loading state
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String? message) {
    if (_isDisposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  // Load user profile from API
  Future<void> loadUserProfile() async {
    setLoading(true);
    setErrorMessage(null);

    if (isGuestMode) {
      _loadGuestProfile();
      setLoading(false);
      return;
    }

    try {
      // Try to get stored user first
      final storedUser = await _authService.getStoredUser();
      if (storedUser != null) {
        _updateUserData(storedUser);
      }

      // Then fetch latest data from API
      final user = await _authService.getCurrentUser();
      _updateUserData(user);
    } catch (e) {
      setErrorMessage(
        'Failed to load profile: ${e.toString().replaceAll('Exception: ', '')}',
      );

      // If API fails, try to show stored user data
      final storedUser = await _authService.getStoredUser();
      if (storedUser != null) {
        _updateUserData(storedUser);
      }
    } finally {
      setLoading(false);
    }
  }

  void _loadGuestProfile() {
    final profile = _guestService.guestProfile;
    userName = profile['name']?.toString() ?? 'Guest User';
    userEmail = profile['email']?.toString() ?? 'guest@finura.app';
    userPhone = '';
    profileImageUrl = profile['avatar']?.toString() ?? '';
    notifyListeners();
  }

  // Update user data in the UI
  void _updateUserData(User user) {
    if (_isDisposed) return;
    userName = user.name;
    userId = user.id;
    userPhone = user.phone ?? '';
    userEmail = user.username;
    profileImageUrl = (user.profilePhoto ?? '').toString();
    notifyListeners();
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // Upload a new profile photo from a file path (POST /auth/me/pro, fallback to PUT)
  Future<bool> uploadProfilePhoto(String filePath) async {
    setErrorMessage(null);
    try {
      User updatedUser;
      try {
        updatedUser = await _authService.uploadProfilePhotoPost(File(filePath));
      } catch (_) {
        updatedUser = await _authService.uploadProfilePhoto(File(filePath));
      }
      _updateUserData(updatedUser);
      // Ensure freshest data
      try {
        final fresh = await _authService.getCurrentUser();
        _updateUserData(fresh);
      } catch (_) {}
      return true;
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Delete current profile photo (DELETE /auth/me/profile-photo)
  Future<bool> deleteProfilePhoto() async {
    setErrorMessage(null);
    try {
      final updatedUser = await _authService.deleteProfilePhoto();
      _updateUserData(updatedUser);
      try {
        final fresh = await _authService.getCurrentUser();
        _updateUserData(fresh);
      } catch (_) {}
      return true;
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Navigation methods
  void navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    // If profile was updated, refresh the profile data
    if (result == true) {
      await refreshProfile();
    }
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          contentPadding: const EdgeInsets.all(30),
          title: const Text(
            'End Session',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Yes, End Session Button (Green)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _performLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Yes, End Session',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Cancel Button (Blue)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.secondaryColor, // Blue color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    setLoading(true);

    try {
      // Call logout API
      await _authService.logout();

      // Navigate to splash screen and clear all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Even if logout API fails, clear local data and navigate
      setErrorMessage('Logout failed, but clearing local session');

      // Navigate anyway after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (Route<dynamic> route) => false,
        );
      });
    } finally {
      setLoading(false);
    }
  }

  // Menu options
  List<ProfileMenuItem> getMenuItems(BuildContext context) {
    if (isGuestMode) {
      return [
        ProfileMenuItem(
          title: 'Login',
          icon: Icons.login,
          onTap: () => navigateToLogin(context),
        ),
        ProfileMenuItem(
          title: 'My Target',
          icon: MyFlutterApp.vector__6_,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyTargetScreen()),
            );
          },
        ),
        ProfileMenuItem(
          title: 'Help',
          icon: Icons.help_outline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          },
        ),
      ];
    }

    return [
      ProfileMenuItem(
        title: 'Edit Profile',
        icon: MyFlutterApp.profile,
        onTap: () => navigateToEditProfile(context),
      ),
      ProfileMenuItem(
        title: 'Notification',
        icon: MyFlutterApp.vector__8_,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationSettingsScreen(),
            ),
          );
        },
      ),
      ProfileMenuItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        },
      ),
      ProfileMenuItem(
        title: 'My Target',
        icon: MyFlutterApp.vector__6_,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyTargetScreen()),
          );
        },
      ),
      ProfileMenuItem(
        title: 'Help',
        icon: Icons.help_outline,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpScreen()),
          );
        },
      ),
      ProfileMenuItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () {
          showLogoutDialog(context);
        },
      ),
    ];
  }

  void navigateToLogin(BuildContext context) async {
    setLoading(true);
    try {
      await _guestService.setGuestMode(false);
    } finally {
      setLoading(false);
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void updateUserName(String name) {
    userName = name;
    notifyListeners();
  }

  void updateUserId(String id) {
    userId = id;
    notifyListeners();
  }

  void updateProfileImage(String imageUrl) {
    profileImageUrl = imageUrl;
    notifyListeners();
  }
}

class ProfileMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  ProfileMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
