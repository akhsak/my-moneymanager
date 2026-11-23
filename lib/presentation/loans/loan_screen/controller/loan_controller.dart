import 'package:flutter/material.dart';

import 'package:monaymanagment/repository/loan/model/loan_model.dart';
import 'package:monaymanagment/repository/loan/service/loan_service.dart';
import 'package:monaymanagment/repository/loan/service/loan_summary_service.dart';

class LoanController extends ChangeNotifier {
  final LoanService _loanService = LoanService();
  final LoanSummaryService _summaryService = LoanSummaryService();
  
  List<Loan> _loans = [];
  LoanSummaryData? _summaryData;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int _totalPages = 1;
  int _totalLoans = 0;
  bool _disposed = false;

  // Getters
  List<Loan> get loans => _loans;
  LoanSummaryData? get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalLoans => _totalLoans;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Paginated loans (now handled by API)
  List<Loan> get paginatedLoans => _loans;

  // Summary getters from API
  double get totalPrincipal => _summaryData?.totalPrincipal ?? 0.0;
  double get totalAmountPaid => _summaryData?.totalPaid ?? 0.0;
  double get totalBalanceToPay => _summaryData?.totalBalance ?? 0.0;
  double get totalInterest => _summaryData?.totalInterest ?? 0.0;
  int get totalLoansCount => _summaryData?.totalLoans ?? 0;

  LoanController() {
    _loadData();
  }

  // Load both loans and summary
  Future<void> _loadData() async {
    await Future.wait([
      _loadLoans(),
      _loadSummary(),
    ]);
  }

  // Load summary from API
  Future<void> _loadSummary() async {
    try {
      final response = await _summaryService.getLoanSummary();
      if (_disposed) return;
      _summaryData = response.data;
      if (!_disposed) notifyListeners();
    } catch (e) {
      print('Error loading loan summary: $e');
      // Don't show error for summary, just log it
    }
  }

  // Load loans from API
  Future<void> _loadLoans() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _loanService.getLoans(page: _currentPage, limit: _itemsPerPage);
      
      if (response['success'] == true) {
        final List<dynamic> loansData = response['data'] ?? [];
        _loans = loansData.map((json) => Loan.fromJson(json)).toList();
        
        // Update pagination info
        final pagination = response['pagination'] ?? {};
        _totalPages = pagination['pages'] ?? 1;
        _totalLoans = pagination['total'] ?? 0;
      } else {
        throw Exception('Failed to load loans: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setErrorMessage('Failed to load loans: $e');
      _loans = [];
    } finally {
      _setLoading(false);
    }
  }

  // Add new loan
  Future<void> addLoan({
    required String name,
    required double principal,
    required DateTime deadline,
    String? note,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // Format deadline as YYYY-MM-DD
      final deadlineStr = deadline.toIso8601String().split('T')[0];
      
      final response = await _loanService.createLoan(
        name: name,
        principal: principal,
        deadline: deadlineStr,
        note: note ?? '',
        categoryId: '68d52c35392e967f1b2b5e47', // Default category ID
      );

      if (response['success'] == true) {
        // Reload loans to get updated data
        await _loadLoans();
      } else {
        throw Exception('Failed to add loan: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setErrorMessage('Failed to add loan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add payment to loan
  Future<void> addPayment({
    required String loanId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // Format date as YYYY-MM-DD
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await _loanService.addPayment(
        loanId: loanId,
        amount: amount,
        date: dateStr,
        note: note ?? '',
      );

      if (response['success'] == true) {
        // Reload loans to get updated data
        await _loadLoans();
      } else {
        throw Exception('Failed to add payment: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setErrorMessage('Failed to add payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update loan
  Future<void> updateLoan({
    required String loanId,
    required String name,
    required double principal,
    required DateTime deadline,
    String? note,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // Format deadline as YYYY-MM-DD
      final deadlineStr = deadline.toIso8601String().split('T')[0];
      
      final response = await _loanService.updateLoan(
        loanId: loanId,
        name: name,
        principal: principal,
        deadline: deadlineStr,
        note: note ?? '',
        categoryId: '68d52c35392e967f1b2b5e47', // Default category ID
      );

      if (response['success'] == true) {
        // Reload loans to get updated data
        await _loadLoans();
      } else {
        throw Exception('Failed to update loan: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setErrorMessage('Failed to update loan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete loan
  Future<void> deleteLoan(String loanId) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final success = await _loanService.deleteLoan(loanId);
      
      if (success) {
        print('Loan deleted successfully');
        // Reload loans to get updated data
        await _loadLoans();
      } else {
        throw Exception('Failed to delete loan');
      }
    } catch (e) {
      print('Error deleting loan: $e');
      _setErrorMessage('Failed to delete loan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Pagination methods
  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      _loadLoans();
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      _loadLoans();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage = page;
      _loadLoans();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadData();
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    if (!_disposed) notifyListeners();
  }

  void _setErrorMessage(String? message) {
    if (_disposed) return;
    _errorMessage = message;
    if (!_disposed) notifyListeners();
  }

  void clearError() {
    _setErrorMessage(null);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
