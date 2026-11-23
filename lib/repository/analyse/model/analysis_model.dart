class CategoryAnalyticsResponse {
  final bool success;
  final CategoryAnalyticsData data;
  final String? message;

  CategoryAnalyticsResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory CategoryAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return CategoryAnalyticsResponse(
      success: json['success'] ?? false,
      data: CategoryAnalyticsData.fromJson(json['data'] ?? {}),
      message: json['message'],
    );
  }
}

class CategoryAnalyticsData {
  final List<ChartDataItem> chartData;
  final AnalyticsSummary summary;
  final String period;
  final int year;

  CategoryAnalyticsData({
    required this.chartData,
    required this.summary,
    required this.period,
    required this.year,
  });

  factory CategoryAnalyticsData.fromJson(Map<String, dynamic> json) {
    return CategoryAnalyticsData(
      chartData: (json['chartData'] as List?)
          ?.map((item) => ChartDataItem.fromJson(item))
          .toList() ?? [],
      summary: AnalyticsSummary.fromJson(json['summary'] ?? {}),
      period: json['period'] ?? '',
      year: json['year'] ?? DateTime.now().year,
    );
  }
}

class ChartDataItem {
  final String name;
  final String icon;
  final double income;
  final double expense;
  final double total;
  final double percentage;

  ChartDataItem({
    required this.name,
    required this.icon,
    required this.income,
    required this.expense,
    required this.total,
    required this.percentage,
  });

  factory ChartDataItem.fromJson(Map<String, dynamic> json) {
    return ChartDataItem(
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'default',
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class AnalyticsSummary {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final double totalAmount;

  AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.totalAmount,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpense: (json['totalExpense'] ?? 0).toDouble(),
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

// For time analysis chart data
class TimeChartData {
  final String day;
  final double income;
  final double expense;

  TimeChartData({
    required this.day,
    required this.income,
    required this.expense,
  });
}

// For category pie chart
class CategoryPieData {
  final String name;
  final double value;
  final double percentage;
  final String icon;
  final int colorIndex;

  CategoryPieData({
    required this.name,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.colorIndex,
  });
}
