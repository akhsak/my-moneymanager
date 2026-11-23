import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/analysis/calender_screen/controller/calender_controller.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';

class CalenderScreen extends StatelessWidget {
  const CalenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return ChangeNotifierProvider(
      create: (_) => CalenderController()
        ..selectedDates.add(DateTime(2023, 4, 19))
        ..currentMonth = DateTime(2023, 4, 1)
        ..initializeCalendar(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        body: Consumer<CalenderController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody(controller, context)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorTheme.secondaryColor),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConstants.width(3),
            vertical: SizeConstants.height(1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConstants.width(3.5)),
              ),
              Expanded(
                child: Text(
                  'Calender',
                  textAlign: TextAlign.center,
                  style: TextStyles.bodyText(color: Colors.white, size: SizeConstants.font(4.2), weight: FontWeight.bold),
                ),
              ),
              NotificationIconButton(
                iconColor: Colors.white,
                iconSize: SizeConstants.font(6),
                showBadge: true,
                badgeCount: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(CalenderController controller, BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthHeader(controller, context),
            SizedBox(height: SizeConstants.height(2)),
            _buildWeekdayHeader(),
            SizedBox(height: SizeConstants.height(1)),
            _buildCalendarGrid(controller),
            SizedBox(height: SizeConstants.height(3)),
            _buildFilterOptions(controller),
            SizedBox(height: SizeConstants.height(2)),
            _buildRefreshButton(controller),
            SizedBox(height: SizeConstants.height(2)),
            _buildCategoryTabs(controller),
            SizedBox(height: SizeConstants.height(2)),
            _buildCategories(controller),
            SizedBox(height: SizeConstants.height(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(CalenderController controller, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous month arrow
        GestureDetector(
          onTap: () => controller.goPrevMonth(),
          child: Container(
            padding: EdgeInsets.all(SizeConstants.width(2)),
            decoration: BoxDecoration(
              color: ColorTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeConstants.width(2)),
            ),
            child: Icon(
              Icons.chevron_left,
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(4),
            ),
          ),
        ),
        
        // Month and Year
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showMonthPicker(controller, context),
                child: Row(
          children: [
            Text(
              controller.monthName(controller.currentMonth.month),
              style: TextStyles.bodyText(color: ColorTheme.mainColor, size: SizeConstants.font(4), weight: FontWeight.w600),
            ),
                    Icon(Icons.keyboard_arrow_down, color: ColorTheme.secondaryColor, size: SizeConstants.font(3)),
                  ],
                ),
              ),
              SizedBox(width: SizeConstants.width(3)),
              GestureDetector(
                onTap: () => _showYearPicker(controller, context),
                child: Row(
          children: [
            Text(
              '${controller.currentMonth.year}',
              style: TextStyles.bodyText(color: ColorTheme.mainColor, size: SizeConstants.font(4), weight: FontWeight.w600),
            ),
                    Icon(Icons.keyboard_arrow_down, color: ColorTheme.secondaryColor, size: SizeConstants.font(3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Next month arrow
            GestureDetector(
          onTap: () => controller.goNextMonth(),
          child: Container(
            padding: EdgeInsets.all(SizeConstants.width(2)),
            decoration: BoxDecoration(
              color: ColorTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeConstants.width(2)),
            ),
            child: Icon(
              Icons.chevron_right,
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(4),
            ),
          ),
        ),
      ],
    );
  }

  void _showMonthPicker(CalenderController controller, BuildContext context) {
    final months = List.generate(12, (i) => i + 1);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Month', style: TextStyles.bodyText(size: SizeConstants.font(4.5), weight: FontWeight.bold)),
            SizedBox(height: SizeConstants.height(2)),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: SizeConstants.width(3),
                mainAxisSpacing: SizeConstants.height(1.5),
                childAspectRatio: 2.4,
                children: months.map((m) {
                  final isSelected = m == controller.currentMonth.month;
                  return GestureDetector(
                    onTap: () {
                      controller.setMonth(m);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.2)),
                      decoration: BoxDecoration(
                        color: isSelected ? ColorTheme.secondaryColor : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _monthShort(m),
                          style: TextStyles.bodyText(
                            color: isSelected ? Colors.white : ColorTheme.secondaryColor,
                            size: SizeConstants.font(3.5),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showYearPicker(CalenderController controller, BuildContext context) {
    final int currentYear = DateTime.now().year;
    final years = List.generate(11, (i) => currentYear - 5 + i);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Year', style: TextStyles.bodyText(size: SizeConstants.font(4.5), weight: FontWeight.bold)),
            SizedBox(height: SizeConstants.height(2)),
            SizedBox(
              height: SizeConstants.height(25),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final y = years[index];
                  final isSelected = y == controller.currentMonth.year;
                  return ListTile(
                    title: Text(
                      y.toString(),
                      style: TextStyles.bodyText(
                        color: isSelected ? ColorTheme.secondaryColor : ColorTheme.mainColor,
                        size: SizeConstants.font(4),
                        weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      controller.setYear(y);
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: years.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int m) {
    const shorts = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return shorts[m - 1];
  }

  

  Widget _buildWeekdayHeader() {
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(d, style: TextStyles.smallText(color: const Color(0xFF0068FF), size: SizeConstants.font(3))),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(CalenderController controller) {
    final firstDayOfMonth = DateTime(controller.currentMonth.year, controller.currentMonth.month, 1);
    final startWeekday = (firstDayOfMonth.weekday + 6) % 7; // Monday=0
    final daysInMonth = DateTime(controller.currentMonth.year, controller.currentMonth.month + 1, 0).day;

    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (col) {
            final index = row * 7 + col;
            if (index < startWeekday || index >= startWeekday + daysInMonth) {
              return _buildDayCell(null, controller);
            }
            final dayNum = index - startWeekday + 1;
            final date = DateTime(controller.currentMonth.year, controller.currentMonth.month, dayNum);
            return _buildDayCell(date, controller);
          }),
        );
      }),
    );
  }

  Widget _buildDayCell(DateTime? date, CalenderController controller) {
    final isEmpty = date == null;
    final double cellSize = SizeConstants.width(10);
    final bool selected = !isEmpty && controller.isSelected(DateTime(date.year, date.month, date.day));
    return SizedBox(
      width: cellSize,
      height: cellSize * 1.2,
      child: Center(
        child: isEmpty
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: () => controller.toggleDate(date),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: selected ? ColorTheme.secondaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(cellSize / 2),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyles.smallText(
                        color: selected ? Colors.white : ColorTheme.mainColor,
                        size: SizeConstants.font(3.2),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFilterOptions(CalenderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by:',
          style: TextStyles.bodyText(
            color: ColorTheme.mainColor,
            size: SizeConstants.font(3.5),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Today', 'This Month', 'This Year', 'All'].map((filter) {
            final isSelected = filter == controller.selectedFilter;
            return GestureDetector(
              onTap: () => controller.selectFilter(filter),
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(3),
                  vertical: SizeConstants.height(0.8),
                ),
              decoration: BoxDecoration(
                  color: isSelected ? ColorTheme.secondaryColor : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  filter,
                  style: TextStyles.smallText(
                    color: isSelected ? Colors.white : ColorTheme.secondaryColor,
                    size: SizeConstants.font(3),
                    weight: FontWeight.w600,
              ),
            ),
          ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(CalenderController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => controller.selectFilter(controller.selectedFilter),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(6),
              vertical: SizeConstants.height(1),
            ),
            decoration: BoxDecoration(
              color: ColorTheme.secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: SizeConstants.font(3.5),
                ),
                SizedBox(width: SizeConstants.width(2)),
                Text(
                  'Refresh Data',
                  style: TextStyles.smallText(
                    color: Colors.white,
                    size: SizeConstants.font(3.2),
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(CalenderController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.toggleCategoryView(true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.2)),
              decoration: BoxDecoration(
                color: controller.showChartView ? ColorTheme.secondaryColor : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  'categories chart',
                  style: TextStyles.bodyText(
                    color: controller.showChartView ? Colors.white : ColorTheme.secondaryColor,
                    size: SizeConstants.font(3.5),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: SizeConstants.width(3)),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.toggleCategoryView(false),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.2)),
              decoration: BoxDecoration(
                color: controller.showChartView ? const Color(0xFFE3F2FD) : ColorTheme.secondaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  'List of Categories',
                  style: TextStyles.bodyText(
                    color: controller.showChartView ? ColorTheme.secondaryColor : Colors.white,
                    size: SizeConstants.font(3.5),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(CalenderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected date and filter info
        if (controller.selectedDates.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories for ${controller.selectedDates.first.day}/${controller.selectedDates.first.month}/${controller.selectedDates.first.year}',
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor,
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(3),
                  vertical: SizeConstants.height(0.5),
                ),
                decoration: BoxDecoration(
                  color: ColorTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Filter: ${controller.selectedFilter}',
                  style: TextStyles.smallText(
                    color: Colors.white,
                    size: SizeConstants.font(2.8),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConstants.height(1)),
        ] else ...[
          Text(
            'Category Overview - ${controller.currentMonth.month}/${controller.currentMonth.year}',
            style: TextStyles.bodyText(
              color: ColorTheme.mainColor,
              size: SizeConstants.font(3.5),
              weight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConstants.height(0.5)),
          Text(
            'Filter: ${controller.selectedFilter} | Year: ${controller.currentMonth.year}',
            style: TextStyles.smallText(
              color: Colors.grey[600],
              size: SizeConstants.font(2.8),
            ),
          ),
          SizedBox(height: SizeConstants.height(1)),
        ],
        
        // Analytics content
        if (controller.analyticsLoading) ...[
          Container(
            height: SizeConstants.height(30),
            child: Center(
              child: CircularProgressIndicator(
                color: ColorTheme.secondaryColor,
              ),
            ),
          ),
        ] else if (controller.analyticsError != null) ...[
          Container(
            height: SizeConstants.height(25),
            child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  // Icon(
                  //   Icons.error_outline,
                  //   size: SizeConstants.width(15),
                  //   color: Colors.red,
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
          ),
        ] else ...[
          if (controller.categoryPieData.isEmpty) ...[
            Container(
              height: SizeConstants.height(25),
              child: Center(
                child: Text(
                  controller.selectedDates.isEmpty 
                    ? 'Select a date to view categories'
                    : 'No data available for selected date',
                  style: TextStyles.bodyText(
                    color: Colors.grey[600],
                    size: SizeConstants.font(3.5),
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: SizeConstants.height(3)),
            // Show either pie chart or list view based on selection
            controller.showChartView 
              ? Column(
                  children: [
                    Center(child: _fullPieChart(controller.categoryPieData)),
                    SizedBox(height: SizeConstants.height(2)),
                    _buildCategoryLegend(controller, controller.categoryPieData),
                  ],
                )
              : _buildCategoryListView(controller),
            SizedBox(height: SizeConstants.height(2)),
          ],
        ],
      ],
    );
  }

  
  Widget _fullPieChart(List<CategorySlice> slices) {
    final double radius = SizeConstants.width(30);
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: _FullPiePainter(slices: slices),
      ),
    );
  }
  
  Widget _buildCategoryLegend(CalenderController controller, List<CategorySlice> slices) {
    return Container(
      height: SizeConstants.height(15),
      child: ListView.builder(
        itemCount: slices.length,
        itemBuilder: (context, index) {
          final slice = slices[index];
          return Container(
            margin: EdgeInsets.only(bottom: SizeConstants.height(1)),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(3),
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
                    color: slice.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: SizeConstants.width(3)),
                Expanded(
                  child: Text(
                    slice.label,
                    style: TextStyles.bodyText(
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(3.5),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                // Show amount if available from analytics
                if (controller.categoryAnalytics != null && controller.categoryAnalytics!.data.chartData.isNotEmpty) ...[
                    Text(
                    '₹${_getAmountForCategory(controller, slice.label)}',
                      style: TextStyles.bodyText(
                      color: ColorTheme.mainColor,
                        size: SizeConstants.font(3.2), 
                      weight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: SizeConstants.width(1)),
                ],
                Text(
                  '${(slice.percent * 100).toStringAsFixed(1)}%',
                  style: TextStyles.bodyText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3),
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
  
  Widget _buildCategoryListView(CalenderController controller) {
    final categoryList = controller.categoryListData;
    
    if (categoryList.isEmpty) {
      return Container(
        height: SizeConstants.height(25),
        child: Center(
          child: Text(
            'No category data available',
            style: TextStyles.bodyText(
              color: Colors.grey[600],
              size: SizeConstants.font(3.5),
            ),
          ),
        ),
      );
    }
    
    return Container(
      height: SizeConstants.height(30),
      child: ListView.builder(
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          final item = categoryList[index];
          
          return Container(
            margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(4),
              vertical: SizeConstants.height(1.5),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConstants.width(3)),
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
                // Category icon
                Container(
                  width: SizeConstants.width(12),
                  height: SizeConstants.width(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                  ),
                  child: Icon(
                    _getIconForCategory(item.icon),
                    color: item.color,
                    size: SizeConstants.font(4),
                  ),
                ),
                SizedBox(width: SizeConstants.width(3)),
                // Category name
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyles.bodyText(
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(3.5),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                // Amount
                Text(
                  '₹${item.amount.toStringAsFixed(0)}',
                  style: TextStyles.bodyText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3.5),
                    weight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: SizeConstants.width(2)),
                // Percentage
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConstants.width(2),
                    vertical: SizeConstants.height(0.5),
                  ),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeConstants.width(1)),
                  ),
                  child: Text(
                    '${item.percentage.toStringAsFixed(1)}%',
                    style: TextStyles.smallText(
                      color: item.color,
                      size: SizeConstants.font(2.8),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Helper method to get icon for category
  IconData _getIconForCategory(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'money':
        return Icons.account_balance_wallet;
      case 'bus':
        return Icons.directions_bus;
      case 'food':
        return Icons.restaurant;
      case 'medicine':
        return Icons.medical_services;
      case 'default':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
  
  // Helper method to get amount for a category
  double _getAmountForCategory(CalenderController controller, String categoryName) {
    final analytics = controller.categoryAnalytics?.data;
    if (analytics == null) return 0.0;
    
    final categoryData = analytics.chartData.firstWhere(
      (item) => item.name == categoryName,
      orElse: () => analytics.chartData.first,
    );
    
    // Return expense amount (since we're using expense filter)
    return categoryData.expense;
  }
}


class _FullPiePainter extends CustomPainter {
  final List<CategorySlice> slices;
  _FullPiePainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(centerX, centerY) - 10;
    
    final rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);
    double startAngle = -math.pi / 2; // Start from top

    for (final s in slices) {
      final sweep = 2 * math.pi * s.percent; // Full circle proportion
      final paint = Paint()..color = s.color..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      
      // Draw percentage label inside the slice
      final labelAngle = startAngle + sweep / 2;
      final labelRadius = radius * 0.6; // Position label inside the slice
      final labelX = centerX + labelRadius * math.cos(labelAngle);
      final labelY = centerY + labelRadius * math.sin(labelAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(s.percent * 100).round()}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConstants.font(3.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
      
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

