import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/auth/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/profile/profile_screen/view/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/home/home_screen/controller/home_controller.dart';
import 'package:monaymanagment/core/widgets/custom_progress_bar.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Consumer<HomeController>(
        builder: (context, homeController, child) {
          return Scaffold(
            backgroundColor: ColorTheme.secondaryColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Blue Header - Matching DashboardScreen
                  Container(
                    width: double.infinity,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          SizeConstants.width(5),
                          SizeConstants.height(2),
                          SizeConstants.width(5),
                          SizeConstants.height(3),
                        ),
                        child: Column(
                          children: [
                            // Welcome Section with Profile Avatar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Profile Avatar
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: SizeConstants.width(12),
                                    height: SizeConstants.width(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: ColorTheme.mainColor2
                                            .withOpacity(0.3),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorTheme.mainColor
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: FutureBuilder<User?>(
                                      future:
                                          homeController.userProfileImage !=
                                              null
                                          ? Future.value(null)
                                          : AuthService().getStoredUser(),
                                      builder: (context, snapshot) {
                                        final fallbackUrl = (snapshot.hasData)
                                            ? (snapshot.data as User?)
                                                  ?.profilePhoto
                                            : null;
                                        final urlToUse =
                                            homeController.userProfileImage ??
                                            fallbackUrl;
                                        return CircleAvatar(
                                          radius: SizeConstants.width(6),
                                          backgroundColor:
                                              ColorTheme.mainColor2,
                                          backgroundImage:
                                              (urlToUse != null &&
                                                  urlToUse.isNotEmpty)
                                              ? NetworkImage(urlToUse)
                                              : null,
                                          child:
                                              (urlToUse == null ||
                                                  urlToUse.isEmpty)
                                              ? Icon(
                                                  Icons.person,
                                                  color:
                                                      ColorTheme.secondaryColor,
                                                  size: SizeConstants.font(6),
                                                )
                                              : null,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: SizeConstants.width(3)),

                                // Welcome Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hi, Welcome Back',
                                        style: TextStyles.bodyText(
                                          color: ColorTheme.mainColor2,
                                          size: SizeConstants.font(3.5),
                                          weight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: SizeConstants.height(0.5),
                                      ),
                                      Text(
                                        homeController.getGreeting(),
                                        style: TextStyles.smallText(
                                          color: ColorTheme.mainColor2
                                              .withOpacity(0.8),
                                          size: SizeConstants.font(3.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Notification Icon
                                NotificationIconButton(
                                  iconColor: ColorTheme.mainColor2,
                                  iconSize: SizeConstants.font(6),
                                  showBadge: true,
                                  badgeCount: 5,
                                ),
                              ],
                            ),

                            SizedBox(height: SizeConstants.height(3)),

                            // Balance & Expense Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            color: ColorTheme.mainColor2,
                                            size: SizeConstants.font(4),
                                          ),
                                          SizedBox(
                                            width: SizeConstants.width(2),
                                          ),
                                          Text(
                                            'Total Balance',
                                            style: TextStyles.smallText(
                                              color: ColorTheme.mainColor2,
                                              size: SizeConstants.font(3.2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: SizeConstants.height(0.5),
                                      ),
                                      Text(
                                        '₹${homeController.totalBalance.toStringAsFixed(2)}',
                                        style: TextStyles.bodyText(
                                          color: ColorTheme.mainColor2,
                                          size: SizeConstants.font(4),
                                          weight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: SizeConstants.height(4),
                                  color: ColorTheme.mainColor2,
                                ),
                                SizedBox(width: SizeConstants.width(5)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.trending_down,
                                            color: ColorTheme.mainColor2,
                                            size: SizeConstants.font(4),
                                          ),
                                          SizedBox(
                                            width: SizeConstants.width(2),
                                          ),
                                          Text(
                                            'Total Expense',
                                            style: TextStyles.smallText(
                                              color: ColorTheme.mainColor2,
                                              size: SizeConstants.font(3.2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: SizeConstants.height(0.5),
                                      ),
                                      Text(
                                        '₹${homeController.totalExpense.toStringAsFixed(2)}',
                                        style: TextStyles.bodyText(
                                          color: ColorTheme.targetBlue,
                                          size: SizeConstants.font(4),
                                          weight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: SizeConstants.height(2.5)),

                            // Progress Bar - Using Custom Widget
                            CustomProgressBar(
                              progressPercentage:
                                  homeController.expenseProgressPercentage,
                              targetAmount: homeController.expenseLimit,
                              trackColor: ColorTheme.mainColor2.withOpacity(
                                0.2,
                              ),
                              fillColor: const Color.fromARGB(255, 30, 59, 75),
                              percentageTextColor: ColorTheme.mainColor2,
                              amountTextColor: ColorTheme.mainColor2,
                              barHeight: SizeConstants.height(5),
                              showAmount: false,
                            ),

                            SizedBox(height: SizeConstants.height(1.5)),

                            // Status
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: ColorTheme.mainColor2,
                                  size: SizeConstants.font(3.5),
                                ),
                                SizedBox(width: SizeConstants.width(2)),
                                Expanded(
                                  child: Text(
                                    '${(homeController.expenseProgress * 100).toInt()}% Of Your Expenses, Looks Good.',
                                    style: TextStyles.smallText(
                                      color: ColorTheme.mainColor2,
                                      size: SizeConstants.font(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // White Content - Matching DashboardScreen
                  Container(
                    decoration: BoxDecoration(
                      color: ColorTheme.mainColor2,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(SizeConstants.width(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main White Content Card
                          Container(
                            decoration: BoxDecoration(
                              color: ColorTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorTheme.mainColor.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(SizeConstants.width(4)),
                              child: Row(
                                children: [
                                  // Savings Goal Section
                                  Expanded(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: SizeConstants.width(16),
                                          height: SizeConstants.width(16),
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                width: SizeConstants.width(16),
                                                height: SizeConstants.width(16),
                                                child: CircularProgressIndicator(
                                                  value: 0.25,
                                                  strokeWidth:
                                                      SizeConstants.width(2),
                                                  backgroundColor: ColorTheme
                                                      .mainColor2
                                                      .withOpacity(0.2),
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(ColorTheme.mainColor2),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: Center(
                                                  child: Icon(
                                                    Icons.directions_car,
                                                    color:
                                                        ColorTheme.mainColor2,
                                                    size: SizeConstants.font(6),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: SizeConstants.height(1),
                                        ),
                                        Text(
                                          'Savings',
                                          style: TextStyles.smallText(
                                            color: ColorTheme.mainColor2,
                                            size: SizeConstants.font(3.2),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'On Goals',
                                          style: TextStyles.smallText(
                                            color: ColorTheme.mainColor2,
                                            size: SizeConstants.font(3.2),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: 1,
                                    height: SizeConstants.height(8),
                                    color: ColorTheme.mainColor2.withOpacity(
                                      0.2,
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: SizeConstants.width(3),
                                    ),
                                  ),

                                  // Revenue & Food Section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Revenue Last Week',
                                          style: TextStyles.smallText(
                                            color: ColorTheme.mainColor2,
                                            size: SizeConstants.font(3.2),
                                          ),
                                        ),
                                        SizedBox(
                                          height: SizeConstants.height(0.5),
                                        ),
                                        Text(
                                          '₹${homeController.revenueLastWeek.toStringAsFixed(2)}',
                                          style: TextStyles.bodyText(
                                            color: ColorTheme.mainColor2,
                                            size: SizeConstants.font(4.5),
                                            weight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: SizeConstants.height(1.5),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              MyFlutterApp.vector__1_,
                                              color: ColorTheme.mainColor2,
                                              size: SizeConstants.font(4),
                                            ),
                                            SizedBox(
                                              width: SizeConstants.width(2),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Loan Balance To Pay',
                                                    style: TextStyles.smallText(
                                                      color:
                                                          ColorTheme.mainColor2,
                                                      size: SizeConstants.font(
                                                        3,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${homeController.loanBalanceToPay.toStringAsFixed(2)}',
                                                    style: TextStyles.bodyText(
                                                      color:
                                                          ColorTheme.mainColor2,
                                                      size: SizeConstants.font(
                                                        3.5,
                                                      ),
                                                      weight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: SizeConstants.height(3)),

                          // Filter Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: homeController.filterOptions.map((
                              filter,
                            ) {
                              final isSelected =
                                  homeController.selectedFilter == filter;
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: SizeConstants.width(2),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        homeController.changeFilter(filter),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? ColorTheme.secondaryColor
                                          : ColorTheme.targetBlue,
                                      foregroundColor: ColorTheme.mainColor2,
                                      elevation: 10,
                                      padding: EdgeInsets.symmetric(
                                        vertical: SizeConstants.height(1.2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      filter,
                                      style: TextStyles.smallText(
                                        color: ColorTheme.mainColor2,
                                        size: SizeConstants.font(3.2),
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: SizeConstants.height(2)),
                          homeController.isLoading
                              ? _buildTopCategoriesSection(homeController)
                              : homeController.transactions.isEmpty
                              ? _buildEmptyTransactionList(homeController)
                              : _buildTopCategoriesSection(homeController),

                          // Top Categories Section
                          // _buildTopCategoriesSection(homeController),
                          SizedBox(height: SizeConstants.height(22)),

                          // Transaction List with Pagination
                          // homeController.isLoading
                          //     ? _buildLoadingTransactionList()
                          //     : homeController.transactions.isEmpty
                          //         ? _buildEmptyTransactionList()
                          //         : _buildPaginatedTransactionList(homeController),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingTransactionList() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: SizeConstants.height(2)),
          padding: EdgeInsets.all(SizeConstants.width(4)),
          decoration: BoxDecoration(
            color: ColorTheme.mainColor2,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ColorTheme.mainColor.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: SizeConstants.width(12),
                height: SizeConstants.width(12),
                decoration: BoxDecoration(
                  color: ColorTheme.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: SizeConstants.width(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: SizeConstants.height(2),
                      width: SizeConstants.width(25),
                      decoration: BoxDecoration(
                        color: ColorTheme.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(0.5)),
                    Container(
                      height: SizeConstants.height(1.5),
                      width: SizeConstants.width(20),
                      decoration: BoxDecoration(
                        color: ColorTheme.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: SizeConstants.height(2),
                width: SizeConstants.width(18),
                decoration: BoxDecoration(
                  color: ColorTheme.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTransactionList(HomeController homeController) {
    String filterText = '';
    switch (homeController.selectedFilter.toLowerCase()) {
      case 'daily':
        filterText = 'No daily transactions';
        break;
      case 'weekly':
        filterText = 'No weekly transactions';
        break;
      case 'monthly':
        filterText = 'No monthly transactions';
        break;
      default:
        filterText = 'No transactions found';
        break;
    }

    return Container(
      padding: EdgeInsets.all(SizeConstants.width(8)),
      child: Column(
        children: [
          SizedBox(height: SizeConstants.height(2)),
          Center(
            child: Text(
              filterText,
              style: TextStyles.bodyText(
                color: ColorTheme.grey,
                size: SizeConstants.font(3.3),
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginatedTransactionList(HomeController homeController) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(SizeConstants.width(0)),
      itemCount:
          homeController.transactions.length +
          (homeController.hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        // Check if we should load more transactions automatically
        if (index < homeController.transactions.length) {
          homeController.checkAndLoadMore(
            index,
            homeController.transactions.length,
          );
        }

        // Show loading indicator at the end if there are more items
        if (index == homeController.transactions.length) {
          return _buildLoadMoreLoadingIndicator();
        }

        final transaction = homeController.transactions[index];
        return _TransactionCard(transaction: transaction, isFirst: index == 0);
      },
    );
  }

  Widget _buildLoadMoreLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: SizeConstants.height(2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: SizeConstants.width(5),
            height: SizeConstants.width(5),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorTheme.secondaryColor,
              ),
            ),
          ),
          SizedBox(width: SizeConstants.width(3)),
          Text(
            'Loading more...',
            style: TextStyles.smallText(
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(3.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesSection(HomeController homeController) {
    final topCategories = homeController.topCategories;

    if (topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(SizeConstants.width(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Categories (${homeController.selectedFilter})',
            style: TextStyles.bodyText(
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(3),
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeConstants.height(2)),
          ...topCategories.map(
            (category) => _buildCategoryItem(category, homeController),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    CategorySummary category,
    HomeController homeController,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.width(3),
        vertical: SizeConstants.height(1.2),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: SizeConstants.width(10),
            height: SizeConstants.width(10),
            decoration: BoxDecoration(
              color: ColorTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category.icon,
              color: ColorTheme.mainColor2,
              size: SizeConstants.font(4.5),
            ),
          ),

          SizedBox(width: SizeConstants.width(3)),

          // Category Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyles.bodyText(
                    color: ColorTheme.secondaryColor,
                    size: SizeConstants.font(3.2),
                    weight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeConstants.height(0.2)),
                Text(
                  'Total over last ${homeController.selectedFilter.toLowerCase()}',
                  style: TextStyles.smallText(
                    color: ColorTheme.grey,
                    size: SizeConstants.font(2.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '₹${category.totalAmount.toStringAsFixed(0)}',
            style: TextStyles.bodyText(
              color: ColorTheme.primaryColor,
              size: SizeConstants.font(3),
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for transaction card matching DashboardScreen style
class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final bool isFirst;

  const _TransactionCard({required this.transaction, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      margin: EdgeInsets.only(
        top: isFirst ? 0 : SizeConstants.height(1.2),
        bottom: SizeConstants.height(1.2),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen
            ? SizeConstants.width(2.5)
            : SizeConstants.width(3),
        vertical: SizeConstants.height(1.2),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transaction Icon
            Container(
              width: isSmallScreen
                  ? SizeConstants.width(9)
                  : SizeConstants.width(10),
              height: isSmallScreen
                  ? SizeConstants.width(9)
                  : SizeConstants.width(10),
              decoration: BoxDecoration(
                color: ColorTheme.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.icon,
                color: ColorTheme.mainColor2,
                size: isSmallScreen
                    ? SizeConstants.font(4)
                    : SizeConstants.font(4.5),
              ),
            ),

            SizedBox(
              width: isSmallScreen
                  ? SizeConstants.width(2)
                  : SizeConstants.width(2.5),
            ),

            // Transaction Details - Left Section
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title (like "1000" in the image)
                  Text(
                    transaction.title,
                    style: TextStyles.bodyText(
                      color: ColorTheme.secondaryColor,
                      size: isSmallScreen
                          ? SizeConstants.font(3.5)
                          : SizeConstants.font(3.8),
                      weight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConstants.height(0.1)),
                  // Time (like "12:00 AM - October 8, 2025" in the image)
                  Text(
                    transaction.time,
                    style: TextStyles.smallText(
                      color: ColorTheme.grey,
                      size: isSmallScreen
                          ? SizeConstants.font(2.5)
                          : SizeConstants.font(2.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Vertical Separator
            Container(
              width: 1,
              margin: EdgeInsets.symmetric(horizontal: SizeConstants.width(1)),
              color: ColorTheme.mainColor2,
            ),

            // Category Section - Middle Section
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  transaction.category,
                  style: TextStyles.smallText(
                    color: ColorTheme.secondaryColor,
                    size: isSmallScreen
                        ? SizeConstants.font(2.5)
                        : SizeConstants.font(2.8),
                    weight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Vertical Separator
            Container(
              width: 1,
              margin: EdgeInsets.symmetric(horizontal: SizeConstants.width(1)),
              color: ColorTheme.mainColor2,
            ),

            // Amount Section - Right Section
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${transaction.isIncome ? '' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyles.bodyText(
                    color: transaction.isIncome
                        ? ColorTheme.secondaryColor
                        : ColorTheme.chartBlue,
                    size: isSmallScreen
                        ? SizeConstants.font(3.5)
                        : SizeConstants.font(4),
                    weight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
