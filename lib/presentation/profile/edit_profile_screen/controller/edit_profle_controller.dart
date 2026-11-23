import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:monaymanagment/repository/auth/model/user_model.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/theme_service.dart';
import 'package:path/path.dart' as p;

class EditProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();
  bool _isDisposed = false;

  // User information
  String userName = 'Loading...';
  String userId = '';
  String phone = '';
  String email = '';
  String profileImageUrl = '';

  // Form controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Toggle states
  bool pushNotifications = true;
  bool darkTheme = false;

  // Loading and error states
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  EditProfileController() {
    loadUserProfile();
    _loadThemeSettings();
  }

  // Set loading state
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  // Set updating state
  void setUpdating(bool updating) {
    if (_isDisposed) return;
    _isUpdating = updating;
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String? message) {
    if (_isDisposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void clearErrorMessage() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  // Load user profile from API or stored data
  Future<void> loadUserProfile() async {
    setLoading(true);
    clearErrorMessage();

    try {
      // Try to get stored user first
      final storedUser = await _authService.getStoredUser();
      if (storedUser != null) {
        _updateUserData(storedUser);
        _initializeControllers();
      }

      // Then fetch latest data from API
      final user = await _authService.getCurrentUser();
      _updateUserData(user);
      _initializeControllers();
    } catch (e) {
      setErrorMessage(
        'Failed to load profile: ${e.toString().replaceAll('Exception: ', '')}',
      );

      // If API fails, try to show stored user data
      final storedUser = await _authService.getStoredUser();
      if (storedUser != null) {
        _updateUserData(storedUser);
        _initializeControllers();
      }
    } finally {
      setLoading(false);
    }
  }

  // Update user data in the UI
  void _updateUserData(User user) {
    if (_isDisposed) return;
    userName = user.name;
    userId = user.id;
    phone = user.phone ?? '';
    email = user.username;
    profileImageUrl = _resolveProfilePhoto(user.profilePhoto);
    notifyListeners();
  }

  // Initialize form controllers with current values
  void _initializeControllers() {
    usernameController.text = userName;
    phoneController.text = phone;
    emailController.text = email;
  }

  void updateUserName(String name) {
    if (_isDisposed) return;
    userName = name;
    notifyListeners();
  }

  void updatePhone(String phoneNumber) {
    if (_isDisposed) return;
    phone = phoneNumber;
    notifyListeners();
  }

  void updateEmail(String emailAddress) {
    if (_isDisposed) return;
    email = emailAddress;
    notifyListeners();
  }

  void togglePushNotifications(bool value) {
    if (_isDisposed) return;
    pushNotifications = value;
    notifyListeners();
  }

  // Validate input fields
  bool _validateInputs() {
    if (usernameController.text.trim().isEmpty) {
      setErrorMessage('Please enter your name');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      setErrorMessage('Please enter your email/username');
      return false;
    }
    return true;
  }

  // Update profile via API
  Future<bool> updateProfile() async {
    clearErrorMessage();

    if (!_validateInputs()) {
      return false;
    }

    setUpdating(true);

    try {
      final updatedUser = await _authService.updateProfile(
        name: usernameController.text.trim(),
        username: emailController.text.trim(),
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );

      // Update local data
      _updateUserData(updatedUser);

      return true;
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      setUpdating(false);
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // Upload a new profile photo from a file path
  Future<bool> uploadProfilePhoto(String filePath) async {
    clearErrorMessage();
    setUpdating(true);
    try {
      final preparedFile = await _prepareFileForUpload(filePath);
      if (preparedFile == null) {
        return false;
      }
      // Prefer POST /auth/me/pro first
      User updatedUser;
      try {
        updatedUser = await _authService.uploadProfilePhotoPost(
          preparedFile.file,
          mimeType: preparedFile.mimeType,
        );
      } catch (_) {
        // Fallback to PUT /auth/me/profile-photo
        updatedUser = await _authService.uploadProfilePhoto(
          preparedFile.file,
          mimeType: preparedFile.mimeType,
        );
      }
      _updateUserData(updatedUser);
      // Refresh from server to ensure latest
      try {
        final fresh = await _authService.getCurrentUser();
        _updateUserData(fresh);
      } catch (_) {}
      return true;
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      setUpdating(false);
    }
  }

  // Delete current profile photo
  Future<bool> deleteProfilePhoto() async {
    clearErrorMessage();
    setUpdating(true);
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
    } finally {
      setUpdating(false);
    }
  }

  // Load theme settings
  Future<void> _loadThemeSettings() async {
    darkTheme = _themeService.isDarkTheme;
    notifyListeners();
  }

  // Toggle dark theme
  Future<void> toggleDarkTheme() async {
    darkTheme = !darkTheme;
    await _themeService.setDarkTheme(darkTheme);
    notifyListeners();
  }

  String _resolveProfilePhoto(String? photo) {
    if (photo == null) return '';
    final trimmed = photo.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    const base = 'https://money-manager-web.onrender.com';
    if (trimmed.startsWith('/')) {
      return '$base$trimmed';
    }
    return '$base/$trimmed';
  }

  Future<_PreparedUploadFile?> _prepareFileForUpload(String filePath) async {
    final originalFile = File(filePath);
    if (!await originalFile.exists()) {
      setErrorMessage('Selected image could not be found.');
      return null;
    }

    List<int>? headerBytes;
    try {
      headerBytes = await originalFile.openRead(0, 32).first;
    } catch (_) {
      headerBytes = null;
    }

    final mimeType = lookupMimeType(
      originalFile.path,
      headerBytes: headerBytes,
    );
    if (mimeType == null || !mimeType.startsWith('image/')) {
      setErrorMessage(
        'Unsupported image type. Please pick a photo from your gallery or camera.',
      );
      return null;
    }

    if (mimeType == 'image/jpeg') {
      return _PreparedUploadFile(file: originalFile, mimeType: 'image/jpeg');
    }

    final bytes = await originalFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      setErrorMessage('Failed to read the selected image.');
      return null;
    }

    final sanitizedPath = p.join(
      Directory.systemTemp.path,
      'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    try {
      final convertedBytes = img.encodeJpg(decoded, quality: 90);
      final convertedFile = await File(
        sanitizedPath,
      ).writeAsBytes(convertedBytes, flush: true);
      return _PreparedUploadFile(file: convertedFile, mimeType: 'image/jpeg');
    } catch (e) {
      setErrorMessage('Unable to prepare the selected image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _isDisposed = true;
    super.dispose();
  }
}

class _PreparedUploadFile {
  final File file;
  final String mimeType;

  const _PreparedUploadFile({required this.file, required this.mimeType});
}
