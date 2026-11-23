import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/home/quick_analysis_screen/controller/qucik_analysis_controller.dart';
import 'dart:math' as math;

class QuickAnalysisScreen extends StatelessWidget {
  const QuickAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (context) => QuickAnalysisController(),
      child: Consumer<QuickAnalysisController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor:
                ColorTheme.secondaryColor, // Light green background
            body: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorTheme.secondaryColor, // Dark blue background
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(SizeConstants.width(5)),
                      child: Column(
                        children: [
                          // Navigation Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: ColorTheme.mainColor2,
                                  size: SizeConstants.font(6),
                                ),
                              ),
                              // Title
                              Text(
                                'Quickly Analysis',
                                style: TextStyles.bodyText(
                                  color: ColorTheme.mainColor2,
                                  size: SizeConstants.font(5.5),
                                  weight: FontWeight.bold,
                                ),
                              ),
                              // Bell Icon
                              Icon(
                                MyFlutterApp.vector__8_,
                                color: ColorTheme.mainColor2,
                                size: SizeConstants.font(6),
                              ),
                            ],
                          ),

                          SizedBox(height: SizeConstants.height(4)),

                          // Savings Goal and Weekly Summary
                          Row(
                            children: [
                              // Savings Goal - Circular Progress
                              Container(
                                width: SizeConstants.width(20),
                                height: SizeConstants.width(20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Background Circle
                                    Container(
                                      width: SizeConstants.width(20),
                                      height: SizeConstants.width(20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: SizeConstants.width(0.8),
                                        ),
                                      ),
                                    ),
                                    // Progress Arc
                                    CustomPaint(
                                      size: Size(
                                        SizeConstants.width(20),
                                        SizeConstants.width(20),
                                      ),
                                      painter: _CircularProgressPainter(
                                        progress: controller.savingsProgress,
                                        strokeWidth: SizeConstants.width(0.8),
                                        progressColor: const Color(0xFF1E66FF),
                                      ),
                                    ),
                                    // Car Icon
                                    Icon(
                                      Icons.directions_car,
                                      color: const Color(0xFF082C2C),
                                      size: SizeConstants.font(6),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: SizeConstants.width(3)),

                              // Vertical Divider
                              Container(
                                width: 1,
                                height: SizeConstants.height(8),
                                color: Colors.white.withOpacity(0.3),
                              ),

                              SizedBox(width: SizeConstants.width(3)),

                              // Weekly Summary Cards
                              Expanded(
                                child: Column(
                                  children: [
                                    // Revenue Last Week
                                    _buildSummaryCard(
                                      icon: Icons.attach_money,
                                      title: 'Revenue Last Week',
                                      amount:
                                          '\₹${controller.revenueLastWeek.toStringAsFixed(2)}',
                                    ),

                                    SizedBox(height: SizeConstants.height(1)),

                                    // Horizontal Divider
                                    Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.3),
                                    ),

                                    SizedBox(height: SizeConstants.height(1)),

                                    // Food Last Week
                                    _buildSummaryCard(
                                      icon: Icons.restaurant,
                                      title: 'Food Last Week',
                                      amount:
                                          '-\₹${controller.foodLastWeek.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content Container
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConstants.height(1)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF9F3), // Light green background
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Expense Chart Sect
                        Padding(
                          padding: EdgeInsetsGeometry.all(
                            SizeConstants.width(5),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.all(SizeConstants.width(5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Chart Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'April Expenses',
                                      style: TextStyles.bodyText(
                                        color: const Color(0xFF082C2C),
                                        size: SizeConstants.font(5),
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: const Color(0xFF082C2C),
                                          size: SizeConstants.font(5),
                                        ),
                                        SizedBox(width: SizeConstants.width(3)),
                                        Icon(
                                          Icons.calendar_today,
                                          color: const Color(0xFF082C2C),
                                          size: SizeConstants.font(5),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: SizeConstants.height(3)),

                                // Chart
                                _buildExpenseChart(controller),
                              ],
                            ),
                          ),
                        ),

                        // Transaction List
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: SizeConstants.width(4),
                            ),
                            child: ListView.builder(
                              itemCount: controller.transactions.length,
                              itemBuilder: (context, index) {
                                final transaction =
                                    controller.transactions[index];
                                return _buildTransactionItem(transaction);
                              },
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String amount,
  }) {
    return Row(
      children: [
        Icon(icon, color: ColorTheme.mainColor2, size: SizeConstants.font(5)),
        SizedBox(width: SizeConstants.width(2)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyles.smallText(
                  color: ColorTheme.mainColor2,
                  size: SizeConstants.font(3.5),
                ),
              ),
              Text(
                amount,
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor2,
                  size: SizeConstants.font(4.5),
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseChart(QuickAnalysisController controller) {
    return Container(
      height: SizeConstants.height(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Y-axis labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: controller.chartYAxisValues.map((value) {
              return Text(
                '${(value / 1000).toInt()}k',
                style: TextStyles.smallText(
                  color: const Color(0xFF1E66FF),
                  size: SizeConstants.font(3),
                ),
              );
            }).toList(),
          ),

          SizedBox(width: SizeConstants.width(2)),

          // Chart bars
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: controller.weeklyExpenses.map((expense) {
                final normalizedHeight = controller.getNormalizedHeight(
                  expense.amount,
                );
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bar
                    Container(
                      width: SizeConstants.width(8),
                      height: SizeConstants.height(15) * normalizedHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E66FF),
                        borderRadius: BorderRadius.circular(
                          SizeConstants.width(1),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(1)),
                    // Week label
                    Text(
                      expense.week,
                      style: TextStyles.smallText(
                        color: const Color(0xFF082C2C).withOpacity(0.7),
                        size: SizeConstants.font(2.8),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
      padding: EdgeInsets.all(SizeConstants.width(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: SizeConstants.width(12),
            height: SizeConstants.width(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E66FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeConstants.width(2.5)),
            ),
            child: Icon(
              transaction.icon,
              color: const Color(0xFF1E66FF),
              size: SizeConstants.font(5),
            ),
          ),

          SizedBox(width: SizeConstants.width(3)),

          // Title and Time
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyles.bodyText(
                    color: const Color(0xFF082C2C),
                    size: SizeConstants.font(4.2),
                    weight: FontWeight.bold,
                  ),
                ),
                Text(
                  transaction.time,
                  style: TextStyles.smallText(
                    color: const Color(0xFF082C2C).withOpacity(0.6),
                    size: SizeConstants.font(3.2),
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider
          // Container(
          //   width: 1,
          //   height: SizeConstants.height(4),
          //   color: const Color(0xFFE0E0E0),
          // ),

          // SizedBox(width: SizeConstants.width(2)),

          // Category
          Expanded(
            flex: 1,
            child: Text(
              transaction.category,
              style: TextStyles.smallText(
                color: const Color(0xFF082C2C),
                size: SizeConstants.font(3.5),
              ),
            ),
          ),

          // Vertical Divider
          // Container(
          //   width: 1,
          //   height: SizeConstants.height(4),
          //   color: const Color(0xFFE0E0E0),
          // ),

          // SizedBox(width: SizeConstants.width(2)),

          // Amount
          Expanded(
            flex: 1,
            child: Text(
              '${transaction.isIncome ? '' : ''}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyles.bodyText(
                color: transaction.isIncome ? Colors.green : Colors.red,
                size: SizeConstants.font(4),
                weight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw progress arc
    final startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
