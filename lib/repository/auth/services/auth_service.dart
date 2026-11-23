import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class AuthService {
  static const String baseUrl = 'https://money-manager-web.onrender.com/auth';
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';

  // Register user
  Future<RegisterResponse> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        // Store token and user data
        if (authResponse.accessToken != null) {
          await _storeToken(authResponse.accessToken!);
          await _storeUser(authResponse.user);
        }

        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        await _storeUser(user); // Update stored user data
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get user data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    required String name,
    required String username,
    String? phone,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'username': username,
          if (phone != null) 'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        await _storeUser(user); // Update stored user data
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Upload/Update profile photo (multipart/form-data PUT)
  Future<User> uploadProfilePhoto(File file, {String? mimeType}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final uri = Uri.parse('$baseUrl/me/profile-photo');
      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        await _storeUser(user);
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to upload profile photo');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Upload profile photo via POST (multipart/form-data) to /auth/me/profile-photo
  Future<User> uploadProfilePhotoPost(File file, {String? mimeType}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final uri = Uri.parse('$baseUrl/me/profile-photo');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        await _storeUser(user);
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to upload profile photo');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Delete profile photo
  Future<User> deleteProfilePhoto() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/me/profile-photo'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        await _storeUser(user);
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete profile photo');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/me/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount({required String password}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Account deleted successfully, clear local storage
        await _clearToken();
        await _clearUser();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear local storage
      await _clearToken();
      await _clearUser();
    }
  }

  // Token management
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // User data management
  Future<void> _storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Validate token by checking with server
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Try to get current user to validate token
      await getCurrentUser();
      return true;
    } catch (e) {
      // Token is invalid or expired
      return false;
    }
  }
}
