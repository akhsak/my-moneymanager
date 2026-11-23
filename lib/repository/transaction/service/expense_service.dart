import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monaymanagment/repository/auth/services/auth_service.dart';

class ExpenseService {
  static const String _baseUrl = 'https://money-manager-web.onrender.com/api';
  final AuthService _authService = AuthService();

  // Get expense titles for dropdown (category-specific)
  Future<List<String>> getExpenseTitles({String categoryName = 'home'}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse(
        '$_baseUrl/categories/$categoryName/expense-titles',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> titles = data['data'];
          return titles.map((title) => title.toString()).toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception(
          'Failed to load expense titles: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getExpenseTitles: $e');
      // Return empty list if API fails
      return [];
    }
  }

  // Get income titles for dropdown
  Future<List<String>> getIncomeTitles({String categoryName = 'food'}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/categories/$categoryName/income-titles');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> titles = data['data'];
          return titles.map((title) => title.toString()).toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load income titles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getIncomeTitles: $e');
      // Return empty list if API fails
      return [];
    }
  }

  // Get auto transactions for category-wise display
  Future<AutoTransactionsResponse> getAutoTransactions({int? year}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Build URL with or without year parameter
      final url = year != null
          ? Uri.parse('$_baseUrl/categories/auto/transactions?year=$year')
          : Uri.parse('$_baseUrl/categories/auto/transactions');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AutoTransactionsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        // Auto transactions API not available - return empty list instead of throwing
        print(
          'Auto transactions API not available (404) - returning empty list',
        );
        return AutoTransactionsResponse(success: true, data: []);
      } else {
        throw Exception(
          'Failed to load auto transactions: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getAutoTransactions: $e');
      rethrow;
    }
  }

  // Add new expense title (category-specific)
  Future<bool> addExpenseTitle(
    String title, {
    String categoryName = 'home',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse(
        '$_baseUrl/categories/$categoryName/expense-titles',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to add expense title: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in addExpenseTitle: $e');
      rethrow;
    }
  }

  // Add new income title (category-specific)
  Future<bool> addIncomeTitle(
    String title, {
    String categoryName = 'food',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$_baseUrl/categories/$categoryName/income-titles');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to add income title: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in addIncomeTitle: $e');
      rethrow;
    }
  }
}

// Response models
class AutoTransactionsResponse {
  final bool success;
  final List<AutoTransaction> data;

  AutoTransactionsResponse({required this.success, required this.data});

  factory AutoTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return AutoTransactionsResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => AutoTransaction.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AutoTransaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String time;
  final String? description;

  AutoTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.time,
    this.description,
  });

  factory AutoTransaction.fromJson(Map<String, dynamic> json) {
    return AutoTransaction(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isIncome: (json['amount'] ?? 0).toDouble() > 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      time: json['time']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}
