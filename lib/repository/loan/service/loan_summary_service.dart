import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';

class LoanSummaryService {
  static const String baseUrl = 'https://money-manager-web.onrender.com/api';

  Future<LoanSummaryResponse> getLoanSummary() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      final guestService = GuestStorageService.instance;

      if (guestService.isGuestMode) {
        final loans = guestService.guestLoans;
        final totalPrincipal = loans.fold<double>(
          0.0,
          (sum, loan) => sum + loan.principal,
        );
        final totalPaid = loans.fold<double>(
          0.0,
          (sum, loan) => sum + loan.amountPaid,
        );
        final totalBalance = loans.fold<double>(
          0.0,
          (sum, loan) => sum + loan.remainingAmount,
        );
        final summary = LoanSummaryData(
          totalLoans: loans.length,
          totalPrincipal: totalPrincipal,
          totalPaid: totalPaid,
          totalBalance: totalBalance,
          totalInterest: 0.0,
        );
        return LoanSummaryResponse(success: true, data: summary);
      }

      print('Fetching loan summary...');
      final response = await http.get(
        Uri.parse('$baseUrl/loans/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Loan summary response status code: ${response.statusCode}');
      print('Loan summary response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return LoanSummaryResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load loan summary: ${response.body}');
      }
    } catch (e) {
      print('Error fetching loan summary: $e');
      throw Exception('Failed to load loan summary: $e');
    }
  }
}

class LoanSummaryResponse {
  final bool success;
  final LoanSummaryData data;

  LoanSummaryResponse({required this.success, required this.data});

  factory LoanSummaryResponse.fromJson(Map<String, dynamic> json) {
    return LoanSummaryResponse(
      success: json['success'] ?? false,
      data: LoanSummaryData.fromJson(json['data'] ?? {}),
    );
  }
}

class LoanSummaryData {
  final int totalLoans;
  final double totalPrincipal;
  final double totalPaid;
  final double totalBalance;
  final double totalInterest;

  LoanSummaryData({
    required this.totalLoans,
    required this.totalPrincipal,
    required this.totalPaid,
    required this.totalBalance,
    required this.totalInterest,
  });

  factory LoanSummaryData.fromJson(Map<String, dynamic> json) {
    return LoanSummaryData(
      totalLoans: json['totalLoans'] ?? 0,
      totalPrincipal: (json['totalPrincipal'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      totalInterest: (json['totalInterest'] ?? 0).toDouble(),
    );
  }
}
