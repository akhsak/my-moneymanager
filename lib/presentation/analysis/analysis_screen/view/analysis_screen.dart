import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/analyse/model/analysis_model.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/presentation/profile/all_targets_screen/view/all_targets_screen.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/analysis/analysis_screen/controller/analysis_controller.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';
import 'package:monaymanagment/presentation/home/home_screen/controller/home_controller.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalysisController()..loadData()),
        ChangeNotifierProvider(create: (_) => HomeController()),
      ],
      child: Consumer2<AnalysisController, HomeController>(
        builder: (context, controller, homeController, child) {
          return Scaffold(
            backgroundColor: ColorTheme.secondaryColor,
            appBar: CustomAppBar(
              title: 'Analysis',
              showProfileAvatar: true,
              showBackButton: false,
              showNotification: true,
              profileImageUrl: homeController.userProfileImage,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Balance Overview Section
                  _buildBalanceOverview(controller),
                  // Main Content
                  Expanded(child: _buildMainContent(context, controller)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceOverview(AnalysisController controller) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          children: [
            // Balance and Expense Summary
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             'Total Balance',
            //             style: TextStyles.smallText(
            //               color: Colors.white,
            //               size: SizeConstants.font(3.5),
            //             ),
            //           ),
            //           Text(
            //             '₹${controller.totalBalance.toStringAsFixed(2)}',
            //             style: TextStyles.bodyText(
            //               color: Colors.white,
            //               size: SizeConstants.font(4.5),
            //               weight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     Container(
            //       width: 1,
            //       height: SizeConstants.height(6),
            //       color: Colors.white,
            //     ),
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.end,
            //         children: [
            //           Text(
            //             'Total Expense',
            //             style: TextStyles.smallText(
            //               color: Colors.white,
            //               size: SizeConstants.font(3.5),
            //             ),
            //           ),
            //           Text(
            //             '-₹${controller.totalExpense.toStringAsFixed(2)}',
            //             style: TextStyles.bodyText(
            //               color: const Color(0xFF87CEEB),
            //               size: SizeConstants.font(4.5),
            //               weight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            // Analysis Type Selection
            _buildAnalysisTypeSelection(controller),
            SizedBox(height: SizeConstants.height(2)),

            // Time Period Selection
            _buildTimePeriodSelection(controller),

            SizedBox(height: SizeConstants.height(2)),

            // Progress Bar
            // Column(
            //   mainAxisSize: MainAxisSize.min,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     SizedBox(height: SizeConstants.height(1)),
            //     // Linear progress bar using custom widget
            //     CustomProgressBar(
            //       progressPercentage: controller.progressPercentage,
            //       targetAmount: controller.targetAmount,
            //       trackColor: const Color(0xFFEFF9F3), // mint light
            //       fillColor: const Color(0xFF082C2C), // dark teal
            //       percentageTextColor: Colors.white,
            //       amountTextColor: const Color(0xFF082C2C),
            //       barHeight: SizeConstants.height(5),
            //     ),
            //     SizedBox(height: SizeConstants.height(1)),
            //     Row(
            //       children: [
            //         const Icon(
            //           Icons.check_circle,
            //           color: Colors.white,
            //           size: 14,
            //         ),
            //         SizedBox(width: SizeConstants.width(1.5)),
            //         Flexible(
            //           child: Text(
            //             '${controller.progressPercentage.toInt()}% Of Your Expenses, Looks Good.',
            //             style: TextStyles.smallText(
            //               color: Colors.white,
            //               size: SizeConstants.font(2.8),
            //             ),
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    AnalysisController controller,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(SizeConstants.width(5)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - SizeConstants.width(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // // Analysis Type Selection
                  // _buildAnalysisTypeSelection(controller),
                  // SizedBox(height: SizeConstants.height(1)),
                  // // Time Period Selection
                  // _buildTimePeriodSelection(controller),
                  // SizedBox(height: SizeConstants.height(2)),
                  // Chart Section based on analysis type
                  _buildChartSection(context, controller),
                  SizedBox(height: SizeConstants.height(2)),
                  // Summary Cards
                  _buildSummaryCards(controller),
                  SizedBox(height: SizeConstants.height(3)),
                  // My Targets Section
                  _buildMyTargetsSection(controller),
                  SizedBox(
                    height: SizeConstants.height(2),
                  ), // Extra padding at bottom
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisTypeSelection(AnalysisController controller) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: SizeConstants.width(2)),
      padding: EdgeInsets.all(SizeConstants.width(2)),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(SizeConstants.width(6)),
        border: Border.all(
          color: ColorTheme.secondaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: controller.analysisTypes.map((type) {
          final isSelected = type == controller.selectedAnalysisType;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectAnalysisType(type),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(1),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(3),
                  vertical: SizeConstants.height(1.5),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorTheme.secondaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: ColorTheme.secondaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyles.smallText(
                    color: isSelected
                        ? Colors.white
                        : ColorTheme.secondaryColor,
                    size: SizeConstants.font(3),
                    weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimePeriodSelection(AnalysisController controller) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: SizeConstants.width(2)),
      padding: EdgeInsets.all(SizeConstants.width(1.5)),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(SizeConstants.width(5)),
        border: Border.all(
          color: ColorTheme.secondaryColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: controller.timePeriods.map((period) {
          final isSelected = period == controller.selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectTimePeriod(period),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(0.5),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(2.5),
                  vertical: SizeConstants.height(1.2),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorTheme.secondaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(SizeConstants.width(3)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: ColorTheme.secondaryColor.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyles.smallText(
                    color: isSelected
                        ? Colors.white
                        : ColorTheme.secondaryColor,
                    size: SizeConstants.font(3),
                    weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    AnalysisController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                controller.selectedAnalysisType == 'Category Analysis'
                    ? 'Category Analysis - ${controller.selectedFilter == 'expense'
                          ? 'Expenses'
                          : controller.selectedFilter == 'income'
                          ? 'Income'
                          : 'All'} - ${controller.selectedPeriod}'
                    : 'Income & Expenses - ${controller.selectedPeriod}',
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor,
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            SizedBox(width: SizeConstants.width(2)),
            // IconButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ChangeNotifierProvider(
            //           create: (_) => CalenderController()
            //             ..selectedYear = controller.selectedYear
            //             ..currentMonth = DateTime(controller.selectedYear, DateTime.now().month, 1),
            //           child: const CalenderScreen(),
            //         ),
            //       ),
            //     ).then((_) {
            //       // Refresh analytics when returning from calendar
            //       controller.refreshData();
            //     });
            //   },
            //   icon: Icon(
            //     Icons.calendar_today,
            //     color: ColorTheme.secondaryColor,
            //     size: SizeConstants.font(4),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: SizeConstants.height(2)),
        // Filter section for Category Analysis
        if (controller.selectedAnalysisType == 'Category Analysis') ...[
          _buildFilterSection(controller),
          SizedBox(height: SizeConstants.height(2)),
        ],
        // Chart based on analysis type
        controller.selectedAnalysisType == 'Category Analysis'
            ? _buildCategoryAnalysisChart(controller)
            : _buildTimeAnalysisChart(controller),
      ],
    );
  }

  Widget _buildFilterSection(AnalysisController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: controller.filterTypes.map((filter) {
        final isSelected = filter == controller.selectedFilter;
        return GestureDetector(
          onTap: () => controller.selectFilter(filter),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(4),
              vertical: SizeConstants.height(1),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorTheme.secondaryColor
                  : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              filter == 'expense'
                  ? 'Expenses'
                  : filter == 'income'
                  ? 'Income'
                  : 'All',
              style: TextStyles.smallText(
                color: isSelected ? Colors.white : ColorTheme.secondaryColor,
                size: SizeConstants.font(3.5),
                weight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryAnalysisChart(AnalysisController controller) {
    if (controller.analyticsLoading) {
      return Container(
        height: SizeConstants.height(25),
        child: Center(
          child: CircularProgressIndicator(color: ColorTheme.secondaryColor),
        ),
      );
    }

    if (controller.analyticsError != null) {
      return Container(
        height: SizeConstants.height(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(
              //   Icons.error_outline,
              //   size: SizeConstants.width(15),
              //   color: Colors.grey,
              // ),
              // SizedBox(height: SizeConstants.height(1)),
              Text(
                'Error loading data',
                style: TextStyles.bodyText(
                  color: Colors.grey,
                  size: SizeConstants.font(3.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pieData = controller.categoryPieData;
    if (pieData.isEmpty) {
      return Container(
        height: SizeConstants.height(20),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyles.bodyText(
              color: Colors.grey[600],
              size: SizeConstants.font(3.5),
            ),
          ),
        ),
      );
    }

    return _buildPieChart(controller, pieData);
  }

  Widget _buildTimeAnalysisChart(AnalysisController controller) {
    return _buildBarChart(controller);
  }

  Widget _buildBarChart(AnalysisController controller) {
    final maxValue = controller.maxChartValue;
    final chartHeight = SizeConstants.height(16);
    final chartWidth = SizeConstants.width(85);

    return Container(
      height: chartHeight,
      width: chartWidth,
      constraints: BoxConstraints(
        minHeight: SizeConstants.height(12),
        maxHeight: SizeConstants.height(20),
        minWidth: SizeConstants.width(70),
        maxWidth: SizeConstants.width(90),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD), // Light blue background matching image
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Grid lines
            _buildGridLines(chartHeight, chartWidth, maxValue),
            // Y-axis labels
            _buildYAxisLabels(chartHeight, maxValue),
            // Chart bars
            _buildChartBars(controller, maxValue, chartHeight, chartWidth),
            // X-axis labels
            _buildXAxisLabels(controller, chartHeight, chartWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildGridLines(
    double chartHeight,
    double chartWidth,
    double maxValue,
  ) {
    // Create grid lines based on max value
    final gridValues = _getGridValues(maxValue);

    return Positioned.fill(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: gridValues.map((value) {
          return Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(
                left: SizeConstants.width(8),
                right: SizeConstants.width(2),
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF87CEEB).withOpacity(0.2),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<double> _getGridValues(double maxValue) {
    if (maxValue <= 20000) {
      return [maxValue * 0.33, maxValue * 0.66, maxValue];
    } else if (maxValue <= 100000) {
      return [maxValue * 0.25, maxValue * 0.5, maxValue * 0.75, maxValue];
    } else {
      return [maxValue * 0.25, maxValue * 0.5, maxValue * 0.75, maxValue];
    }
  }

  Widget _buildYAxisLabels(double chartHeight, double maxValue) {
    final yLabels = _getYAxisLabels(maxValue);

    return Positioned(
      left: SizeConstants.width(1),
      top: 0,
      bottom: SizeConstants.height(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: yLabels.reversed.map((label) {
          // Reversed order: 15k at top, 1k at bottom
          return Flexible(
            child: Text(
              label,
              style: TextStyles.smallText(
                color: const Color(0xFF0068FF),
                size: SizeConstants.font(2.2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _getYAxisLabels(double maxValue) {
    if (maxValue <= 20000) {
      return [
        '${(maxValue * 0.33 / 1000).toInt()}k',
        '${(maxValue * 0.66 / 1000).toInt()}k',
        '${(maxValue / 1000).toInt()}k',
      ];
    } else if (maxValue <= 100000) {
      return [
        '${(maxValue * 0.25 / 1000).toInt()}k',
        '${(maxValue * 0.5 / 1000).toInt()}k',
        '${(maxValue * 0.75 / 1000).toInt()}k',
        '${(maxValue / 1000).toInt()}k',
      ];
    } else {
      return [
        '${(maxValue * 0.25 / 1000).toInt()}k',
        '${(maxValue * 0.5 / 1000).toInt()}k',
        '${(maxValue * 0.75 / 1000).toInt()}k',
        '${(maxValue / 1000).toInt()}k',
      ];
    }
  }

  Widget _buildChartBars(
    AnalysisController controller,
    double maxValue,
    double chartHeight,
    double chartWidth,
  ) {
    final barAreaHeight = chartHeight - SizeConstants.height(3);
    final barAreaWidth = chartWidth - SizeConstants.width(12);
    final data = controller.currentChartData;

    // Handle empty data
    if (data.isEmpty) {
      return Positioned(
        left: SizeConstants.width(8),
        top: 0,
        child: Container(
          height: barAreaHeight,
          width: barAreaWidth,
          child: Center(
            child: Text(
              'No data available',
              style: TextStyles.smallText(
                color: Colors.grey[600],
                size: SizeConstants.font(3),
              ),
            ),
          ),
        ),
      );
    }

    final itemCount = data.length;
    final itemWidth = barAreaWidth / itemCount;
    final barWidth = itemWidth * 0.2; // Smaller bars - 20% of item width
    final barSpacing = itemWidth * 0.05; // Smaller spacing between bars

    // Ensure maxValue is not zero or NaN
    final safeMaxValue = maxValue.isNaN || maxValue <= 0 ? 1.0 : maxValue;

    return Positioned(
      left: SizeConstants.width(8),
      top: 0,
      child: Container(
        height: barAreaHeight,
        width: barAreaWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((chartData) {
            // Ensure values are not NaN
            final safeIncome = chartData.income.isNaN ? 0.0 : chartData.income;
            final safeExpense = chartData.expense.isNaN
                ? 0.0
                : chartData.expense;

            // Calculate heights safely
            final incomeHeight = (safeIncome / safeMaxValue) * barAreaHeight;
            final expenseHeight = (safeExpense / safeMaxValue) * barAreaHeight;

            return Container(
              width: itemWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Income bar (dark blue)
                  Container(
                    width: barWidth,
                    height: incomeHeight.isNaN ? 0.0 : incomeHeight,
                    margin: EdgeInsets.only(right: barSpacing),
                    decoration: BoxDecoration(
                      color: ColorTheme.secondaryColor, // Dark blue for income
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Expense bar (light blue)
                  Container(
                    width: barWidth,
                    height: expenseHeight.isNaN ? 0.0 : expenseHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0068FF), // Light blue for expense
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildXAxisLabels(
    AnalysisController controller,
    double chartHeight,
    double chartWidth,
  ) {
    final barAreaWidth = chartWidth - SizeConstants.width(10);
    final data = controller.currentChartData;
    final itemCount = data.length;
    final labelWidth = barAreaWidth / itemCount;

    return Positioned(
      left: SizeConstants.width(8),
      bottom: 0,
      child: Container(
        height: SizeConstants.height(3),
        width: barAreaWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: data.map((chartData) {
            return Container(
              width: labelWidth,
              child: Text(
                chartData.day,
                textAlign: TextAlign.center,
                style: TextStyles.smallText(
                  color: ColorTheme.mainColor,
                  size: SizeConstants.font(2.8),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AnalysisController controller) {
    final showLoader = !controller.isGuestMode && controller.analyticsLoading;
    return Row(
      children: [
        // Income Card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(SizeConstants.width(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: SizeConstants.width(10),
                  height: SizeConstants.width(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: ColorTheme.secondaryColor,
                    size: SizeConstants.font(4),
                  ),
                ),
                SizedBox(height: SizeConstants.height(1)),
                Text(
                  'Income',
                  style: TextStyles.smallText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3.5),
                  ),
                ),
                SizedBox(height: SizeConstants.height(0.5)),
                showLoader
                    ? SizedBox(
                        width: SizeConstants.width(10),
                        height: SizeConstants.width(5),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorTheme.secondaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        '₹${controller.filteredIncome.toStringAsFixed(2)}',
                        style: TextStyles.bodyText(
                          color: ColorTheme.secondaryColor,
                          size: SizeConstants.font(4),
                          weight: FontWeight.bold,
                        ),
                      ),
                SizedBox(height: SizeConstants.height(0.5)),
                // Show period info
                Text(
                  '${controller.selectedPeriod} ${controller.selectedAnalysisType == 'Category Analysis' ? '- ${controller.selectedFilter == 'expense'
                            ? 'Expenses'
                            : controller.selectedFilter == 'income'
                            ? 'Income'
                            : 'All'}' : ''}',
                  style: TextStyles.smallText(
                    color: Colors.grey[600],
                    size: SizeConstants.font(2.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: SizeConstants.width(3)),
        // Expense Card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(SizeConstants.width(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: SizeConstants.width(10),
                  height: SizeConstants.width(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_down,
                    color: ColorTheme.secondaryColor,
                    size: SizeConstants.font(4),
                  ),
                ),
                SizedBox(height: SizeConstants.height(1)),
                Text(
                  'Expense',
                  style: TextStyles.smallText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3.5),
                  ),
                ),
                SizedBox(height: SizeConstants.height(0.5)),
                showLoader
                    ? SizedBox(
                        width: SizeConstants.width(10),
                        height: SizeConstants.width(5),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF0068FF),
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        '₹${controller.filteredExpense.toStringAsFixed(2)}',
                        style: TextStyles.bodyText(
                          color: const Color(0xFF0068FF),
                          size: SizeConstants.font(4),
                          weight: FontWeight.bold,
                        ),
                      ),
                SizedBox(height: SizeConstants.height(0.5)),
                // Show period info
                Text(
                  '${controller.selectedPeriod} ${controller.selectedAnalysisType == 'Category Analysis' ? '- ${controller.selectedFilter == 'expense'
                            ? 'Expenses'
                            : controller.selectedFilter == 'income'
                            ? 'Income'
                            : 'All'}' : ''}',
                  style: TextStyles.smallText(
                    color: Colors.grey[600],
                    size: SizeConstants.font(2.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyTargetsSection(AnalysisController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title with View More Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Targets',
              style: TextStyles.bodyText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(4.5),
                weight: FontWeight.bold,
              ),
            ),
            if (controller.targets.length > 2)
              Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllTargetsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View More',
                    style: TextStyles.smallText(
                      color: ColorTheme.secondaryColor,
                      size: SizeConstants.font(3.5),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: SizeConstants.height(2.5)),

        // Targets Grid
        controller.targetsLoading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(SizeConstants.height(4)),
                  child: CircularProgressIndicator(
                    color: ColorTheme.secondaryColor,
                  ),
                ),
              )
            : controller.targets.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(SizeConstants.height(4)),
                  child: Column(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: SizeConstants.width(15),
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: SizeConstants.height(1)),
                      Text(
                        'No targets set',
                        style: TextStyles.bodyText(
                          color: Colors.grey[600],
                          size: SizeConstants.font(3.5),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : controller.targets.length == 1
            ? _buildTargetCard(
                title: controller.targets[0].category,
                percentage: controller.targets[0].progressPercentage.toInt(),
                color: ColorTheme.chartBlue,
                backgroundColor: ColorTheme.targetBlue,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // First Target
                  Expanded(
                    child: _buildTargetCard(
                      title: controller.targets[0].category,
                      percentage: controller.targets[0].progressPercentage
                          .toInt(),
                      color: ColorTheme.chartBlue,
                      backgroundColor: ColorTheme.targetBlue,
                    ),
                  ),
                  SizedBox(width: SizeConstants.width(4)),
                  // Second Target (if available)
                  Expanded(
                    child: controller.targets.length > 1
                        ? _buildTargetCard(
                            title: controller.targets[1].category,
                            percentage: controller.targets[1].progressPercentage
                                .toInt(),
                            color: ColorTheme.chartBlue,
                            backgroundColor: ColorTheme.targetBlue,
                          )
                        : Container(), // Empty container if no second target
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildTargetCard({
    required String title,
    required int percentage,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeConstants.width(3)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Progress Indicator
          Container(
            width: SizeConstants.width(16),
            height: SizeConstants.width(16),
            child: Stack(
              children: [
                // Background Circle
                Container(
                  width: SizeConstants.width(16),
                  height: SizeConstants.width(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: SizeConstants.width(0.8),
                    ),
                  ),
                ),
                // Progress Circle
                SizedBox(
                  width: SizeConstants.width(16),
                  height: SizeConstants.width(16),
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: SizeConstants.width(0.8),
                    backgroundColor: ColorTheme.mainColor2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorTheme.targetBlue,
                    ),
                  ),
                ),
                // Percentage Text
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '$percentage%',
                      style: TextStyles.bodyText(
                        color: ColorTheme.mainColor2,
                        size: SizeConstants.font(3.5),
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConstants.height(1)),

          // Title
          Text(
            title,
            style: TextStyles.bodyText(
              color: Colors.white,
              size: SizeConstants.font(3),
              weight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    AnalysisController controller,
    List<CategoryPieData> pieData,
  ) {
    // Colors matching the reference image: red, yellow, green, light blue, dark blue
    final colors = [
      const Color(0xFF2F3F87), // Red - for Loan (largest slice)
      const Color(0xFFF6E05E), // Yellow - for akhsa M
      const Color(0xFF68D391), // Green - for foods
      const Color(0xFF63B3ED), // Light blue - for phone
      const Color(0xFF2B6CB0), // Dark blue - for travel
      const Color(0xFF805AD5), // Purple - for Gift
      const Color(0xFFED8936), // Orange - for Gifts
      const Color(0xFF38B2AC), // Teal - for Education
      const Color(0xFF718096), // Gray - for health
    ];

    return Container(
      height: SizeConstants.height(25),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 2,
            child: CustomPaint(
              painter: PieChartPainter(pieData: pieData, colors: colors),
              size: Size.square(SizeConstants.width(50)),
            ),
          ),
          SizedBox(width: SizeConstants.width(3)),
          // Legend
          Expanded(
            flex: 3,
            child: _buildPieChartLegend(controller, pieData, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(
    AnalysisController controller,
    List<CategoryPieData> pieData,
    List<Color> colors,
  ) {
    return Container(
      height: SizeConstants.height(20),
      child: ListView.builder(
        itemCount: pieData.length,
        itemBuilder: (context, index) {
          final item = pieData[index];
          final color = colors[item.colorIndex % colors.length];

          return Container(
            margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(2),
              vertical: SizeConstants.height(1),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConstants.width(2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: SizeConstants.width(4),
                  height: SizeConstants.width(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: SizeConstants.width(2)),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyles.bodyText(
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(3.2),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '₹${item.value.toStringAsFixed(0)}',
                  style: TextStyles.bodyText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3.2),
                    weight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: SizeConstants.width(1)),
                Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: TextStyles.bodyText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(2.8),
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<CategoryPieData> pieData;
  final List<Color> colors;

  PieChartPainter({required this.pieData, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 15;

    double startAngle = -math.pi / 2; // Start from top

    // Sort pie data by percentage (largest first) to match reference image
    final sortedData = List<CategoryPieData>.from(pieData)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    for (int i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final sweepAngle = 2 * math.pi * (item.percentage / 100);

      final paint = Paint()
        ..color = colors[item.colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Add white separator between slices for better visibility
      if (i < sortedData.length - 1) {
        final separatorPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        final separatorAngle = startAngle + sweepAngle;
        final x1 = center.dx + radius * math.cos(separatorAngle);
        final y1 = center.dy + radius * math.sin(separatorAngle);

        canvas.drawLine(center, Offset(x1, y1), separatorPaint);
      }

      startAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.3, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
