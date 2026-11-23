import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monaymanagment/core/guset_models/cateqory/guest_category.dart';
import 'package:monaymanagment/core/guset_models/transaction/guest_transaction.dart';

import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/repository/category/model/category_model.dart';
import 'package:monaymanagment/repository/transaction/model/transaction_model.dart';

class CategoryService {
  static const String _baseUrl =
      'https://money-manager-web.onrender.com/api/categories';
  final AuthService _authService = AuthService();

  // Get all categories
  Future<CategoryListResponse> getCategories() async {
    // Check for token first - if user has valid token, use API regardless of guest mode
    final token = await _authService.getToken();
    if (token != null) {
      // User has token, fetch from API
      final url = Uri.parse('$_baseUrl/');

      print('Fetching categories: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get categories response status code: ${response.statusCode}');
      print('Get categories response body: ${response.body}');

      // Handle successful responses (200, 201, etc.)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseBody = json.decode(response.body);
          return CategoryListResponse.fromJson(responseBody);
        } catch (e) {
          print('Error parsing get categories response: $e');
          throw Exception('Invalid get categories response format from server');
        }
      } else {
        try {
          final errorBody = json.decode(response.body);
          final errorMessage =
              errorBody['message'] ?? 'Failed to fetch categories';
          print('Get categories API Error: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          print('Error parsing get categories error response: $e');
          throw Exception(
            'Get categories server error: ${response.statusCode} - ${response.body}',
          );
        }
      }
    }

    // No token - check if guest mode is enabled
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      return CategoryListResponse(
        success: true,
        data: guestService.guestCategoryModels,
        message: 'Guest categories',
      );
    }

    // No token and not in guest mode
    throw Exception('No access token found. User not logged in.');
  }

  // Create a new category
  Future<CategoryResponse> createCategory({
    required String name,
    String icon = '',
  }) async {
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      final category = await guestService.createCategory(
        name: name,
        icon: icon.isEmpty ? '💰' : icon,
      );
      final model = CategoryModel(
        id: category.id,
        userId: 'guest',
        name: category.name,
        isActive: category.isActive,
        icon: category.icon,
        createdAt: category.createdAt.toIso8601String(),
        updatedAt: category.updatedAt.toIso8601String(),
      );
      return CategoryResponse(
        success: true,
        data: model,
        message: 'Category stored locally for guest mode',
      );
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse('$_baseUrl/');

    print('Creating category: $name');
    print('URL: $url');
    print('Payload: ${json.encode({'name': name, 'icon': icon})}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name, 'icon': icon}),
    );

    print('Create category response status code: ${response.statusCode}');
    print('Create category response body: ${response.body}');

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return CategoryResponse.fromJson(responseBody);
      } catch (e) {
        print('Error parsing create category response: $e');
        throw Exception('Invalid create category response format from server');
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to create category';
        print('Create category API Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing create category error response: $e');
        throw Exception(
          'Create category server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Get category transactions
  Future<CategoryTransactionResponse> getCategoryTransactions({
    required String categoryName,
    int? year,
  }) async {
    // Check for token first - if user has valid token, use API regardless of guest mode
    final token = await _authService.getToken();
    if (token != null) {
      // User has token, fetch from API
      // Build URL with or without year parameter
      final url = year != null
          ? Uri.parse('$_baseUrl/$categoryName/transactions?year=$year')
          : Uri.parse('$_baseUrl/$categoryName/transactions');

      print('Fetching category transactions: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        'Get category transactions response status code: ${response.statusCode}',
      );
      print('Get category transactions response body: ${response.body}');

      // Handle successful responses (200, 201, etc.)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseBody = json.decode(response.body);
          return CategoryTransactionResponse.fromJson(responseBody);
        } catch (e) {
          print('Error parsing get category transactions response: $e');
          throw Exception(
            'Invalid get category transactions response format from server',
          );
        }
      } else if (response.statusCode == 404) {
        // Category not found - return empty response instead of throwing
        print(
          'Category "$categoryName" not found (404) - returning empty response',
        );
        return CategoryTransactionResponse(
          success: true,
          category: {
            '_id': '',
            'name': categoryName,
            'icon': _iconForCategory(categoryName),
          },
          transactions: [],
        );
      } else {
        try {
          final errorBody = json.decode(response.body);
          final errorMessage =
              errorBody['message'] ?? 'Failed to fetch category transactions';
          print('Get category transactions API Error: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          print('Error parsing get category transactions error response: $e');
          throw Exception(
            'Get category transactions server error: ${response.statusCode} - ${response.body}',
          );
        }
      }
    }

    // No token - check if guest mode is enabled
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      final transactions = guestService.guestTransactions
          .where(
            (tx) => tx.categoryName.toLowerCase() == categoryName.toLowerCase(),
          )
          .map(_mapGuestTransactionToModel)
          .toList();

      final category = guestService.guestCategories.firstWhere(
        (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
        orElse: () => GuestCategory(
          id: 'guest-${_slug(categoryName)}',
          name: categoryName,
          icon: _iconForCategory(categoryName),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return CategoryTransactionResponse(
        success: true,
        category: {
          '_id': category.id,
          'name': category.name,
          'icon': category.icon,
        },
        transactions: transactions,
      );
    }

    // No token and not in guest mode
    throw Exception('No access token found. User not logged in.');
  }

  // Create a transaction for a category
  Future<TransactionResponse> createTransaction({
    required String categoryName,
    required String frequency,
    required double amount,
    required String currency,
    required List<Map<String, dynamic>> subTransactions,
    int? year,
    int? month,
    DateTime? transactionDate,
    String? title,
    String? transactionType,
  }) async {
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      final normalized = categoryName.trim();
      GuestCategory? category;
      try {
        category = guestService.guestCategories.firstWhere(
          (cat) => cat.name.toLowerCase() == normalized.toLowerCase(),
        );
      } catch (_) {
        category = null;
      }

      category ??= await guestService.createCategory(
        name: normalized,
        icon: _iconForCategory(normalized),
      );

      final type = _mapTransactionType(transactionType);
      final resolvedTitle =
          title ??
          (subTransactions.isNotEmpty
              ? (subTransactions.first['name'] ?? normalized)
              : normalized);
      final description = subTransactions.isNotEmpty
          ? (subTransactions.first['description'] ?? '')
          : '';

      final guestTransaction = await guestService.createTransaction(
        categoryId: category.id,
        categoryName: category.name,
        title: resolvedTitle,
        amount: amount,
        date: transactionDate ?? DateTime.now(),
        type: type,
        description: description,
        frequency: frequency,
        currency: currency,
      );

      final transaction = _mapGuestTransactionToModel(guestTransaction);
      return TransactionResponse(
        success: true,
        data: transaction,
        message: 'Stored locally for guest mode',
      );
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse('$_baseUrl/$categoryName/transactions');

    print('Creating transaction for category: $categoryName');
    print('URL: $url');
    final payload = {
      'frequency': frequency,
      'amount': amount,
      'currency': currency,
      'year': year ?? DateTime.now().year,
      'month': _getMonthName(month ?? DateTime.now().month),
      'date': _formatDateForAPI(transactionDate ?? DateTime.now()),
      'time': _formatTimeForAPI(transactionDate ?? DateTime.now()),
      'subTransactions': subTransactions,
    };

    // Add optional fields if provided
    if (title != null && title.isNotEmpty) {
      payload['title'] = title;
    }
    if (transactionType != null && transactionType.isNotEmpty) {
      payload['transactionType'] = transactionType;
    }

    print('Full Payload: ${json.encode(payload)}');
    print('Sub-transactions details:');
    for (int i = 0; i < subTransactions.length; i++) {
      print('  Sub-transaction $i: ${subTransactions[i]}');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return TransactionResponse.fromJson(responseBody);
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Invalid response format from server');
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to create transaction';
        print('API Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing error response: $e');
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  GuestTransactionType _mapTransactionType(String? transactionType) {
    switch (transactionType?.toLowerCase()) {
      case 'income':
        return GuestTransactionType.income;
      case 'loan':
        return GuestTransactionType.loan;
      default:
        return GuestTransactionType.expense;
    }
  }

  Transaction _mapGuestTransactionToModel(GuestTransaction transaction) {
    final firstTimestamp = transaction.subTransactions.isNotEmpty
        ? transaction.subTransactions.first.timestamp
        : transaction.createdAt;

    final subTransactions = transaction.subTransactions
        .map(
          (sub) => SubTransaction(
            id: sub.id,
            name: sub.name,
            amount: sub.amount,
            date: _formatDateForAPI(sub.timestamp),
            time: _formatTimeForAPI(sub.timestamp),
            description: sub.description,
          ),
        )
        .toList();

    return Transaction(
      id: transaction.id,
      categoryId: transaction.categoryId,
      month: _getMonthName(firstTimestamp.month),
      year: firstTimestamp.year,
      time: _formatTimeForAPI(firstTimestamp),
      date: _formatDateForAPI(firstTimestamp),
      frequency: transaction.frequency,
      amount: transaction.amount,
      currency: transaction.currency,
      subTransactions: subTransactions,
      userId: 'guest',
      createdAt: transaction.createdAt.toIso8601String(),
      updatedAt: transaction.updatedAt.toIso8601String(),
    );
  }

  String _iconForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food')) return '🍔';
    if (lower.contains('travel') || lower.contains('transport')) return '🚌';
    if (lower.contains('salary') || lower.contains('income')) return '💼';
    if (lower.contains('shopping')) return '🛍️';
    if (lower.contains('health')) return '💊';
    if (lower.contains('entertainment')) return '🎬';
    if (lower.contains('loan')) return '💳';
    return '💰';
  }

  String _slug(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  // Helper method to format date for API
  String _formatDateForAPI(DateTime date) {
    const months = [
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

  // Helper method to format time for API
  String _formatTimeForAPI(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  // Update category
  Future<CategoryResponse> updateCategory({
    required String categoryId,
    required String name,
    String icon = '',
  }) async {
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      final updated = await guestService.updateCategory(
        categoryId,
        name: name,
        icon: icon.isEmpty ? null : icon,
      );
      if (updated == null) {
        throw Exception('Category not found locally');
      }
      final model = CategoryModel(
        id: updated.id,
        userId: 'guest',
        name: updated.name,
        isActive: updated.isActive,
        icon: updated.icon,
        createdAt: updated.createdAt.toIso8601String(),
        updatedAt: updated.updatedAt.toIso8601String(),
      );
      return CategoryResponse(
        success: true,
        data: model,
        message: 'Category updated locally',
      );
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse('$_baseUrl/id/$categoryId');

    print('Updating category: $name');
    print('URL: $url');
    print('Payload: ${json.encode({'name': name, 'icon': icon})}');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name, 'icon': icon}),
    );

    print('Update category response status code: ${response.statusCode}');
    print('Update category response body: ${response.body}');

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return CategoryResponse.fromJson(responseBody);
      } catch (e) {
        print('Error parsing update category response: $e');
        throw Exception('Invalid update category response format from server');
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to update category';
        print('Update category API Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing update category error response: $e');
        throw Exception(
          'Update category server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Delete category
  Future<Map<String, dynamic>> deleteCategory({
    required String categoryName,
  }) async {
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      GuestCategory? match;
      try {
        match = guestService.guestCategories.firstWhere(
          (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
        );
      } catch (_) {
        match = null;
      }

      if (match == null) {
        return {
          'success': false,
          'message': 'Category not found locally',
          'statusCode': 404,
        };
      }
      await guestService.deleteCategory(match.id);
      return {
        'success': true,
        'message': 'Category removed locally',
        'statusCode': 200,
      };
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse('$_baseUrl/$categoryName');

    print('Deleting category: $categoryName');
    print('URL: $url');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Delete category response status code: ${response.statusCode}');
    print('Delete category response body: ${response.body}');

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return responseBody;
      } catch (e) {
        print('Error parsing delete category response: $e');
        throw Exception('Invalid delete category response format from server');
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to delete category';
        print('Delete category API Error: $errorMessage');

        // For 404 errors, return a proper response instead of throwing exception
        if (response.statusCode == 404) {
          return {'success': false, 'message': errorMessage, 'statusCode': 404};
        }

        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing delete category error response: $e');
        throw Exception(
          'Delete category server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Update sub-transaction
  Future<Map<String, dynamic>> updateSubTransaction({
    required String transactionId,
    required int subTransactionIndex,
    required String name,
    required double amount,
    required DateTime date,
    required String time,
    required String description,
  }) async {
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      print(
        'Updating sub-transaction in guest mode: transactionId=$transactionId index=$subTransactionIndex',
      );
      final success = await guestService.updateSubTransaction(
        transactionId: transactionId,
        subTransactionIndex: subTransactionIndex,
        name: name,
        amount: amount,
        date: date,
        time: time,
        description: description,
      );

      if (success) {
        return {
          'success': true,
          'message': 'Sub-transaction updated locally for guest mode',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update sub-transaction in guest mode',
        };
      }
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse(
      '$_baseUrl/transactions/$transactionId/sub-transactions/$subTransactionIndex',
    );

    print('=== URL CONSTRUCTION DEBUG ===');
    print('Base URL: $_baseUrl');
    print('Transaction ID: $transactionId');
    print('Sub-transaction Index: $subTransactionIndex');
    print('Final URL: $url');
    print('==============================');

    // Backend expects payload wrapped in "subTransaction" key
    final payload = {
      'subTransaction': {
        'name': name,
        'amount': amount,
        'date': _formatDateForAPI(date),
        'time': time,
        'description': description,
      },
    };

    print('=== UPDATE SUB-TRANSACTION DEBUG (CORRECTED) ===');
    print('Updating sub-transaction: $name');
    print('URL: $url');
    print(
      'Individual values - Name: $name, Amount: $amount, Date: ${_formatDateForAPI(date)}, Time: $time, Description: $description',
    );
    print('Payload structure: ${json.encode(payload)}');
    print('Payload type: ${payload.runtimeType}');
    print('Using PUT with wrapped subTransaction object structure');
    print('==================================================');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    print(
      'Update sub-transaction response status code: ${response.statusCode}',
    );
    print('Update sub-transaction response body: ${response.body}');

    // Parse and log the response data to verify the update
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final transactionData = responseData['data'];
          print('✅ Updated transaction data: ${transactionData['_id']}');
          print('Updated sub-transactions:');
          for (int i = 0; i < transactionData['subTransactions'].length; i++) {
            final sub = transactionData['subTransactions'][i];
            print(
              '  [$i] ${sub['name']}: ${sub['amount']} (ID: ${sub['_id']})',
            );
          }
        }
      } catch (e) {
        print('Error parsing update response: $e');
      }
    }

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return responseBody;
      } catch (e) {
        print('Error parsing update sub-transaction response: $e');
        throw Exception(
          'Invalid update sub-transaction response format from server',
        );
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to update sub-transaction';
        final errorDetail = errorBody['error'] ?? '';
        print('❌ Update sub-transaction API Error: $errorMessage');
        print('Error details: $errorDetail');
        throw Exception(
          '$errorMessage${errorDetail.isNotEmpty ? '\nDetails: $errorDetail' : ''}',
        );
      } catch (e) {
        print('Error parsing update sub-transaction error response: $e');
        throw Exception(
          'Update sub-transaction server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Delete sub-transaction
  Future<Map<String, dynamic>> deleteSubTransaction({
    required String transactionId,
    required int subTransactionIndex,
  }) async {
    final guestService = GuestStorageService.instance;
    if (guestService.isGuestMode) {
      print(
        'Deleting sub-transaction in guest mode: transactionId=$transactionId, index=$subTransactionIndex',
      );
      final success = await guestService.deleteSubTransaction(
        transactionId: transactionId,
        subTransactionIndex: subTransactionIndex,
      );

      if (success) {
        return {
          'success': true,
          'message': 'Sub-transaction deleted successfully in guest mode',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete sub-transaction in guest mode',
        };
      }
    }

    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No access token found. User not logged in.');
    }

    final url = Uri.parse(
      '$_baseUrl/transactions/$transactionId/sub-transactions/$subTransactionIndex',
    );

    print('Deleting sub-transaction at index: $subTransactionIndex');
    print('URL: $url');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
      'Delete sub-transaction response status code: ${response.statusCode}',
    );
    print('Delete sub-transaction response body: ${response.body}');

    // Handle successful responses (200, 201, etc.)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = json.decode(response.body);
        return responseBody;
      } catch (e) {
        print('Error parsing delete sub-transaction response: $e');
        throw Exception(
          'Invalid delete sub-transaction response format from server',
        );
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Failed to delete sub-transaction';
        print('Delete sub-transaction API Error: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing delete sub-transaction error response: $e');
        throw Exception(
          'Delete sub-transaction server error: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }
}
