import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monaymanagment/repository/analyse/model/analysis_model.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';

class AnalysisService {
  static const String _baseUrl =
      'https://money-manager-web.onrender.com/api/categories';

  Future<CategoryAnalyticsResponse> getCategoryAnalytics({
    required String period,
    required int year,
    required String filter,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/category-analytics?period=$period&year=$year&filter=$filter',
      );

      print('Fetching category analytics: $url');

      // Get authentication token
      final authService = AuthService();
      final token = await authService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Category analytics response status code: ${response.statusCode}');
      print('Category analytics response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CategoryAnalyticsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print('Unauthorized access - returning empty data for new user');
        return _getEmptyAnalyticsData(period, year, filter);
      } else if (response.statusCode == 404) {
        print('No data found - returning empty data');
        return _getEmptyAnalyticsData(period, year, filter);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to load category analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getCategoryAnalytics: $e');
      // Return empty data for new users instead of mock data
      return _getEmptyAnalyticsData(period, year, filter);
    }
  }

  CategoryAnalyticsResponse _getEmptyAnalyticsData(
    String period,
    int year,
    String filter,
  ) {
    // Return empty data for new users with no transactions
    final emptyData = {
      "success": true,
      "data": {
        "chartData": [], // Empty array for no categories
        "summary": {
          "totalIncome": 0.0,
          "totalExpense": 0.0,
          "totalBalance": 0.0,
          "totalAmount": 0.0,
        },
        "period": period,
        "year": year,
      },
    };

    return CategoryAnalyticsResponse.fromJson(emptyData);
  }

  CategoryAnalyticsResponse _getMockAnalyticsData(
    String period,
    int year,
    String filter,
  ) {
    // Mock data based on the API response structure you provided
    final mockData = {
      "success": true,
      "data": {
        "chartData": [
          {
            "name": "Loan",
            "icon": "money",
            "income": 300151,
            "expense": 71301.68520547944,
            "total": 371452.68520547944,
            "percentage": 75.7,
          },
          {
            "name": "akhsa M",
            "icon": "bus",
            "income": 0,
            "expense": 10100,
            "total": 10100,
            "percentage": 10.7,
          },
          {
            "name": "foods",
            "icon": "",
            "income": 10000,
            "expense": 10100,
            "total": 20100,
            "percentage": 10.7,
          },
          {
            "name": "phone",
            "icon": "",
            "income": 1000,
            "expense": 1000,
            "total": 2000,
            "percentage": 1.1,
          },
          {
            "name": "travel",
            "icon": "",
            "income": 0,
            "expense": 1000,
            "total": 1000,
            "percentage": 1.1,
          },
          {
            "name": "Gift",
            "icon": "",
            "income": 0,
            "expense": 300,
            "total": 300,
            "percentage": 0.3,
          },
          {
            "name": "Gifts",
            "icon": "default",
            "income": 0,
            "expense": 250,
            "total": 250,
            "percentage": 0.3,
          },
          {
            "name": "Education",
            "icon": "school",
            "income": 100,
            "expense": 100,
            "total": 200,
            "percentage": 0.1,
          },
          {
            "name": "health",
            "icon": "medicine",
            "income": 0,
            "expense": 10,
            "total": 10,
            "percentage": 0,
          },
        ],
        "summary": {
          "totalIncome": 311251,
          "totalExpense": 94161.68520547944,
          "totalBalance": 217089.31479452056,
          "totalAmount": 405412.68520547944,
        },
        "period": period,
        "year": year,
      },
    };

    return CategoryAnalyticsResponse.fromJson(mockData);
  }

  Future<CategoryAnalyticsResponse> getTimeAnalytics({
    required String period,
    required int year,
    required String filter,
  }) async {
    // Time analytics uses the same API endpoint but with different parameters
    return getCategoryAnalytics(period: period, year: year, filter: filter);
  }
}
