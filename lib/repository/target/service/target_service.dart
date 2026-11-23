import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';

class TargetService {
  final AuthService _authService = AuthService();
  final GuestStorageService _guestService = GuestStorageService.instance;
  final String _baseUrl =
      'https://money-manager-web.onrender.com/api/my-targets';

  // Get all targets
  Future<TargetListResponse> getTargets() async {
    if (_guestService.isGuestMode) {
      return TargetListResponse(targets: _guestService.guestTargets);
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Get targets response status code: ${response.statusCode}');
    print('Get targets response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final List<dynamic> jsonData = json.decode(response.body);
        return TargetListResponse.fromJson(jsonData);
      } catch (e) {
        print('Error parsing get targets response: $e');
        throw Exception('Failed to parse targets data');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to fetch targets';
        print('Get targets API Error: $errorMessage');
        throw Exception(
          'Get targets server error: ${response.statusCode} - $errorMessage',
        );
      } catch (e) {
        print('Error parsing get targets error response: $e');
        throw Exception(
          'Get targets server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Create a new target
  Future<TargetResponse> createTarget({
    required String categoryId,
    required String category,
    required double amount,
  }) async {
    if (_guestService.isGuestMode) {
      final target = await _guestService.createGuestTarget(
        categoryId: categoryId,
        categoryName: category,
        amount: amount,
      );
      return TargetResponse(
        message: 'Target stored locally for guest mode',
        target: target,
      );
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final payload = {
      'categoryId': categoryId,
      'category': category,
      'amount': amount,
    };

    print('Creating target: $payload');
    print('URL: $_baseUrl');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    print('Create target response status code: ${response.statusCode}');
    print('Create target response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(response.body);
        return TargetResponse.fromJson(jsonData);
      } catch (e) {
        print('Error parsing create target response: $e');
        throw Exception('Failed to parse target creation response');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to create target';
        print('Create target API Error: $errorMessage');
        throw Exception(
          'Create target server error: ${response.statusCode} - $errorMessage',
        );
      } catch (e) {
        print('Error parsing create target error response: $e');
        throw Exception(
          'Create target server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Update target (PUT API)
  Future<TargetResponse> updateTarget({
    required String targetId,
    required String categoryId,
    required String category,
    required double amount,
    required double progress,
  }) async {
    if (_guestService.isGuestMode) {
      final updated = await _guestService.updateGuestTarget(
        targetId: targetId,
        categoryId: categoryId,
        categoryName: category,
        amount: amount,
        progress: progress,
      );
      if (updated == null) {
        throw Exception('Target not found');
      }
      return TargetResponse(
        message: 'Target updated locally for guest mode',
        target: updated,
      );
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final payload = {
      'categoryId': categoryId,
      'category': category,
      'amount': amount,
      'progress': progress,
    };

    print('Updating target: $payload');
    print('URL: $_baseUrl/$targetId');

    final response = await http.put(
      Uri.parse('$_baseUrl/$targetId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    print('Update target response status code: ${response.statusCode}');
    print('Update target response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(response.body);
        return TargetResponse.fromJson(jsonData);
      } catch (e) {
        print('Error parsing update target response: $e');
        throw Exception('Failed to parse target update response');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to update target';
        print('Update target API Error: $errorMessage');
        throw Exception(
          'Update target server error: ${response.statusCode} - $errorMessage',
        );
      } catch (e) {
        print('Error parsing update target error response: $e');
        throw Exception(
          'Update target server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Delete target
  Future<bool> deleteTarget(String targetId) async {
    if (_guestService.isGuestMode) {
      return _guestService.deleteGuestTarget(targetId);
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    print('Deleting target: $targetId');
    print('URL: $_baseUrl/$targetId');

    final response = await http.delete(
      Uri.parse('$_baseUrl/$targetId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Delete target response status code: ${response.statusCode}');
    print('Delete target response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(response.body);
        final message = jsonData['message'] ?? '';
        print('Delete target success: $message');
        return true;
      } catch (e) {
        print('Error parsing delete target response: $e');
        return true; // Still consider it successful if we can't parse the response
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to delete target';
        print('Delete target API Error: $errorMessage');
        throw Exception(
          'Delete target server error: ${response.statusCode} - $errorMessage',
        );
      } catch (e) {
        print('Error parsing delete target error response: $e');
        throw Exception(
          'Delete target server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Update target progress
  Future<Map<String, dynamic>> updateTargetProgress({
    required String categoryId,
    required String categoryName,
    required double progress,
  }) async {
    if (_guestService.isGuestMode) {
      final success = await _guestService.updateGuestTargetProgress(
        categoryId: categoryId,
        progress: progress,
      );
      return {
        'success': success,
        'message': success
            ? 'Target progress updated locally for guest mode'
            : 'Failed to update target progress in guest mode',
      };
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final payload = {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'progress': progress,
    };

    print('Updating target progress: $payload');
    print('URL: $_baseUrl/update-progress');

    final response = await http.put(
      Uri.parse('$_baseUrl/update-progress'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
      'Update target progress response status code: ${response.statusCode}',
    );
    print('Update target progress response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(response.body);
        return jsonData;
      } catch (e) {
        print('Error parsing update target progress response: $e');
        throw Exception('Failed to parse target progress update response');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Failed to update target progress';
        print('Update target progress API Error: $errorMessage');
        throw Exception(
          'Update target progress server error: ${response.statusCode} - $errorMessage',
        );
      } catch (e) {
        print('Error parsing update target progress error response: $e');
        throw Exception(
          'Update target progress server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }
}
