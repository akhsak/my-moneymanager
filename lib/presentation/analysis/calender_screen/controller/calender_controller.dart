import 'package:flutter/material.dart';

import 'package:monaymanagment/repository/analyse/model/analysis_model.dart';
import 'package:monaymanagment/repository/analyse/service/analysis_service.dart';

class CalenderController extends ChangeNotifier {
  DateTime currentMonth = DateTime.now();
  final Set<DateTime> selectedDates = <DateTime>{};
  int selectedYear = DateTime.now().year;

  bool showSpends = false; // false => Categories (always show categories)
  String selectedFilter = 'All';
  bool showChartView = true; // true => Pie Chart, false => List View
  
  // Analysis service integration
  final AnalysisService _analysisService = AnalysisService();
  CategoryAnalyticsResponse? _categoryAnalytics;
  bool _analyticsLoading = false;
  String? _analyticsError;

  // Sample spends data for the selected date(s)
  // Map of date (yyyy-mm-dd) to list of items
  final Map<String, List<SpendItem>> spendsByDate = {
    '2023-04-19': [
      SpendItem(icon: Icons.shopping_bag, title: 'Groceries', subtitle: '17:00 - April 24', tag: 'Pantry', amount: -100.00),
      SpendItem(icon: Icons.payments, title: 'Others', subtitle: '17:00 - April 24', tag: 'Payments', amount: 120.00),
    ],
  };

  // Categories distribution for the pie chart - will be updated based on selected date
  List<CategorySlice> categories = [
    CategorySlice(label: 'Groceries', percent: 0.10, color: Color(0xFFE53E3E)),
    CategorySlice(label: 'Others', percent: 0.79, color: Color(0xFFF6E05E)),
    CategorySlice(label: 'Third', percent: 0.11, color: Color(0xFF68D391)),
  ];

  void toggleTab(bool isSpends) {
    showSpends = isSpends;
    notifyListeners();
  }
  
  void toggleCategoryView(bool isChartView) {
    showChartView = isChartView;
    notifyListeners();
  }
  
  // Initialize calendar with default data
  void initializeCalendar() {
    // Load default analytics for current month if no dates selected
    if (selectedDates.isEmpty) {
      _loadDefaultAnalytics();
    }
  }
  
  Future<void> _loadDefaultAnalytics() async {
    _analyticsLoading = true;
    _analyticsError = null;
    notifyListeners();
    
    try {
      String period = 'monthly';
      int year = currentMonth.year;
      String filter = 'expense';
      
      print('Loading default calendar analytics: period=$period, year=$year, filter=$filter');
      
      _categoryAnalytics = await _analysisService.getCategoryAnalytics(
        period: period,
        year: year,
        filter: filter,
      );
      
      categories = categoryPieData;
      
      print('Default calendar analytics loaded successfully. Categories: ${categories.length}');
    } catch (e) {
      print('Error loading default calendar analytics: $e');
      _analyticsError = e.toString();
    } finally {
      _analyticsLoading = false;
      notifyListeners();
    }
  }
  
  void selectFilter(String filter) {
    selectedFilter = filter;
    // Reload analytics when filter changes
    _loadAnalyticsForSelectedDate();
    notifyListeners();
  }

  void goPrevMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    notifyListeners();
  }

  void goNextMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    notifyListeners();
  }

  void setMonth(int month) {
    if (month < 1 || month > 12) return;
    currentMonth = DateTime(currentMonth.year, month, 1);
    // Reload analytics when month changes
    _loadAnalyticsForSelectedDate();
    notifyListeners();
  }

  void setYear(int year) {
    currentMonth = DateTime(year, currentMonth.month, 1);
    selectedYear = year;
    // Reload analytics when year changes
    _loadAnalyticsForSelectedDate();
    notifyListeners();
  }

  void toggleDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (selectedDates.any((d) => _isSameDay(d, day))) {
      selectedDates.removeWhere((d) => _isSameDay(d, day));
    } else {
      selectedDates.add(day);
    }
    // Load analytics for selected date
    _loadAnalyticsForSelectedDate();
    notifyListeners();
  }

  bool isSelected(DateTime date) => selectedDates.any((d) => _isSameDay(d, date));

  List<SpendItem> get visibleSpends {
    // merge spends for all selected dates
    final List<SpendItem> items = [];
    for (final d in selectedDates) {
      final key = _keyFor(d);
      final list = spendsByDate[key];
      if (list != null) items.addAll(list);
    }
    return items;
  }

  String monthName(int month) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return months[month - 1];
  }


  // Analytics getters
  CategoryAnalyticsResponse? get categoryAnalytics => _categoryAnalytics;
  bool get analyticsLoading => _analyticsLoading;
  String? get analyticsError => _analyticsError;
  
  // Get category pie chart data for calendar
  List<CategorySlice> get categoryPieData {
    final analytics = _categoryAnalytics?.data;
    if (analytics == null || analytics.chartData.isEmpty) return categories;
    
    final colors = [
      const Color(0xFF2F3F87), // Blue
      const Color(0xFFF6E05E), // Yellow
      const Color(0xFF68D391), // Green
      const Color(0xFF63B3ED), // Light blue
      const Color(0xFF2B6CB0), // Dark blue
      const Color(0xFF805AD5), // Purple
      const Color(0xFFED8936), // Orange
      const Color(0xFF38B2AC), // Teal
      const Color(0xFF718096), // Gray
    ];
    
    return analytics.chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return CategorySlice(
        label: item.name,
        percent: item.percentage / 100, // Convert percentage to decimal
        color: colors[index % colors.length],
      );
    }).where((item) => item.percent > 0).toList();
  }
  
  // Get category list data for displaying as a list
  List<CategoryListItem> get categoryListData {
    final analytics = _categoryAnalytics?.data;
    if (analytics == null || analytics.chartData.isEmpty) return [];
    
    final colors = [
      const Color(0xFF2F3F87), // Blue
      const Color(0xFFF6E05E), // Yellow
      const Color(0xFF68D391), // Green
      const Color(0xFF63B3ED), // Light blue
      const Color(0xFF2B6CB0), // Dark blue
      const Color(0xFF805AD5), // Purple
      const Color(0xFFED8936), // Orange
      const Color(0xFF38B2AC), // Teal
      const Color(0xFF718096), // Gray
    ];
    
    return analytics.chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return CategoryListItem(
        name: item.name,
        icon: item.icon,
        amount: item.expense, // Using expense for category analysis
        percentage: item.percentage,
        color: colors[index % colors.length],
      );
    }).where((item) => item.amount > 0).toList();
  }

  Future<void> _loadAnalyticsForSelectedDate() async {
    _analyticsLoading = true;
    _analyticsError = null;
    notifyListeners();
    
    try {
      String period = 'daily';
      int year = selectedYear; // Use selectedYear instead of date year
      String filter = 'expense'; // Default to expense for category analysis
      
      // Adjust period based on selected filter
      switch (selectedFilter) {
        case 'Today':
          period = 'daily';
          break;
        case 'This Month':
          period = 'monthly';
          break;
        case 'This Year':
          period = 'year';
          break;
        case 'All':
          period = 'year';
          break;
        default:
          period = 'daily';
      }
      
      // If specific date is selected, use daily period
      if (selectedDates.isNotEmpty) {
        period = 'daily';
        year = selectedDates.first.year;
      } else {
        // If no date selected, use month-based period
        period = selectedFilter == 'This Month' ? 'monthly' : 'year';
        year = currentMonth.year;
      }
      
      print('Loading calendar analytics: period=$period, year=$year, filter=$filter');
      
      _categoryAnalytics = await _analysisService.getCategoryAnalytics(
        period: period,
        year: year,
        filter: filter,
      );
      
      // Update categories with new data
      categories = categoryPieData;
      
      print('Calendar analytics loaded successfully. Categories: ${categories.length}');
    } catch (e) {
      print('Error loading calendar analytics: $e');
      _analyticsError = e.toString();
    } finally {
      _analyticsLoading = false;
      notifyListeners();
    }
  }

  String _keyFor(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class SpendItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final double amount; // negative => expense
  const SpendItem({required this.icon, required this.title, required this.subtitle, required this.tag, required this.amount});
}

class CategorySlice {
  final String label;
  final double percent; // 0..1
  final Color color;
  const CategorySlice({required this.label, required this.percent, required this.color});
}

class CategoryListItem {
  final String name;
  final String icon;
  final double amount;
  final double percentage;
  final Color color;
  const CategoryListItem({
    required this.name,
    required this.icon,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
