import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';

class LoanService {
  static const String baseUrl = 'https://money-manager-web.onrender.com/api';
  final AuthService _authService = AuthService();
  final GuestStorageService _guestService = GuestStorageService.instance;

  // Get all loans with pagination
  Future<Map<String, dynamic>> getLoans({int page = 1, int limit = 10}) async {
    try {
      if (_guestService.isGuestMode) {
        final loans = _guestService.guestLoans;
        return {
          'success': true,
          'data': loans.map((loan) => loan.toJson()).toList(),
          'pagination': {
            'page': 1,
            'pages': 1,
            'total': loans.length,
            'limit': loans.length,
          },
        };
      }

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/loans?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get loans response status: ${response.statusCode}');
      print('Get loans response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load loans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting loans: $e');
      throw Exception('Error getting loans: $e');
    }
  }

  // Create a new loan
  Future<Map<String, dynamic>> createLoan({
    required String name,
    required double principal,
    required String deadline,
    required String note,
    required String categoryId,
  }) async {
    try {
      if (_guestService.isGuestMode) {
        final parsedDeadline =
            DateTime.tryParse(deadline) ??
            DateTime.now().add(const Duration(days: 30));
        final loan = await _guestService.createLoan(
          name: name,
          principal: principal,
          deadline: parsedDeadline,
          note: note,
          categoryId: categoryId,
        );
        return {'success': true, 'loan': loan.toJson()};
      }

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final payload = {
        'name': name,
        'principal': principal,
        'deadline': deadline,
        'note': note,
        'categoryId': categoryId,
      };

      print('Create loan payload: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl/loans'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      print('Create loan response status: ${response.statusCode}');
      print('Create loan response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to create loan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating loan: $e');
      throw Exception('Error creating loan: $e');
    }
  }

  // Add payment to a loan
  Future<Map<String, dynamic>> addPayment({
    required String loanId,
    required double amount,
    required String date,
    required String note,
  }) async {
    try {
      if (_guestService.isGuestMode) {
        final parsedDate = DateTime.tryParse(date) ?? DateTime.now();
        final updated = await _guestService.addLoanPayment(
          loanId: loanId,
          amount: amount,
          date: parsedDate,
          note: note,
        );
        if (updated == null) {
          throw Exception('Loan not found');
        }
        return {'success': true, 'loan': updated.toJson()};
      }

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final payload = {'amount': amount, 'date': date, 'note': note};

      print('Add payment payload: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl/loans/$loanId/pay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      print('Add payment response status: ${response.statusCode}');
      print('Add payment response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to add payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding payment: $e');
      throw Exception('Error adding payment: $e');
    }
  }

  // Update a loan
  Future<Map<String, dynamic>> updateLoan({
    required String loanId,
    required String name,
    required double principal,
    required String deadline,
    required String note,
    required String categoryId,
  }) async {
    try {
      if (_guestService.isGuestMode) {
        final parsedDeadline =
            DateTime.tryParse(deadline) ??
            DateTime.now().add(const Duration(days: 30));
        final updated = await _guestService.updateLoan(
          loanId: loanId,
          name: name,
          principal: principal,
          deadline: parsedDeadline,
          note: note,
          categoryId: categoryId,
        );
        if (updated == null) {
          throw Exception('Loan not found');
        }
        return {'success': true, 'loan': updated.toJson()};
      }

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final payload = {
        'name': name,
        'principal': principal,
        'deadline': deadline,
        'note': note,
        'categoryId': categoryId,
      };

      print('Update loan payload: $payload');

      final response = await http.put(
        Uri.parse('$baseUrl/loans/$loanId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      print('Update loan response status: ${response.statusCode}');
      print('Update loan response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to update loan: ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error updating loan: $e');
      throw Exception('Error updating loan: $e');
    }
  }

  // Delete a loan
  Future<bool> deleteLoan(String loanId) async {
    try {
      if (_guestService.isGuestMode) {
        return await _guestService.deleteLoan(loanId);
      }

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/loans/$loanId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete loan response status: ${response.statusCode}');
      print('Delete loan response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to delete loan: ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error deleting loan: $e');
      throw Exception('Error deleting loan: $e');
    }
  }

  // Add income to loan
  Future<Map<String, dynamic>> addIncomeToLoan({
    required String loanId,
    required double amount,
    required String title,
    required String description,
    required DateTime date,
  }) async {
    try {
      if (_guestService.isGuestMode) {
        final updated = await _guestService.addLoanIncome(
          loanId: loanId,
          amount: amount,
          date: date,
          note: '$title - $description'.trim(),
        );
        if (updated == null) {
          throw Exception('Loan not found');
        }
        return {'success': true, 'loan': updated.toJson()};
      }

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final payload = {
        'amount': amount,
        'title': title,
        'description': description,
        'date': _formatDateForAPI(date),
        'time': _formatTimeForAPI(date),
      };

      print('Add income to loan payload: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl/loans/$loanId/add-income'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      print('Add income to loan response status: ${response.statusCode}');
      print('Add income to loan response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to add income to loan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding income to loan: $e');
      throw Exception('Error adding income to loan: $e');
    }
  }

  // Helper methods for date/time formatting
  String _formatDateForAPI(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTimeForAPI(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}
