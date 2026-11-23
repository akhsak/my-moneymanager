import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/reminder/model/reminder_model.dart';

class ReminderService {
  static const String _baseUrl =
      'https://money-manager-web.onrender.com/api/reminders';
  final AuthService _authService = AuthService();

  // Create a reminder
  Future<ReminderResponse> createReminder({
    required String reminder,
    required String date,
    required String time,
    required String type,
    bool repeat = false,
    bool alarmSound = false,
    bool vibrate = false,
    bool remindMeLater = false,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse(_baseUrl);

    print('Creating reminder: $reminder');
    print('URL: $url');
    final payload = {
      'reminder': reminder,
      'date': date,
      'time': time,
      'type': type,
      'repeat': repeat,
      'alarmSound': alarmSound,
      'vibrate': vibrate,
      'remindMeLater': remindMeLater,
    };

    print('Payload: ${json.encode(payload)}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    print('Reminder response status code: ${response.statusCode}');
    print('Reminder response body: ${response.body}');

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return ReminderResponse.fromJson(responseBody);
      } catch (e) {
        print('Error parsing reminder response: $e');
        throw Exception('Invalid reminder response format from server');
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to create reminder';
        print('Reminder API Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing reminder error response: $e');
        throw Exception(
          'Reminder server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Get reminders with pagination
  Future<ReminderListResponse> getReminders({
    int page = 1,
    int limit = 8,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse('$_baseUrl?page=$page&limit=$limit');

    print('Fetching reminders: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Get reminders response status code: ${response.statusCode}');
    print('Get reminders response body: ${response.body}');

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return ReminderListResponse.fromJson(responseBody);
      } catch (e) {
        print('Error parsing get reminders response: $e');
        throw Exception('Invalid get reminders response format from server');
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to fetch reminders';
        print('Get reminders API Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing get reminders error response: $e');
        throw Exception(
          'Get reminders server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }
}
