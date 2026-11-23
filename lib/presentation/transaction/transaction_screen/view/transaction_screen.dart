import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/transaction/transaction_screen/controller/transaction_controller.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';
import 'package:monaymanagment/presentation/home/home_screen/controller/home_controller.dart'
    as home_ctrl;

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final controller = TransactionController();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.loadTransactionData();
            });
            return controller;
          },
        ),
        ChangeNotifierProvider(create: (_) => home_ctrl.HomeController()),
      ],
      child: Consumer2<TransactionController, home_ctrl.HomeController>(
        builder: (context, controller, homeController, child) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Transaction',
              showProfileAvatar: true,
              showBackButton: false,
              showNotification: true,
              profileImageUrl: homeController.userProfileImage,
            ),
            backgroundColor: ColorTheme.secondaryColor,
            body: _buildBody(controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(TransactionController controller) {
    // Show loading only if no data is loaded yet
    if (controller.isLoading && !controller.isDataLoaded) {
      return _buildLoadingState();
    }

    // Show error only if no data is loaded and there's an error
    if (controller.errorMessage != null && !controller.isDataLoaded) {
      return _buildErrorState(controller.errorMessage!, controller);
    }

    // Show the main content (even if loading in background)
    return SafeArea(
      child: Column(
        children: [
          // Balance Overview Section
          Flexible(flex: 0, child: _buildBalanceOverview(controller)),
          // Transaction List
          Expanded(child: _buildTransactionList(controller)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: ColorTheme.secondaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'Loading transactions...',
              style: TextStyles.bodyText(
                color: Colors.white,
                size: SizeConstants.font(4),
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, TransactionController controller) {
    print('Error loading transactions: $error');
    return Container(
      color: ColorTheme.secondaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   Icons.error_outline,
            //   size: SizeConstants.font(12),
            //   color: Colors.white,
            // ),
            // SizedBox(height: SizeConstants.height(2)),
            Text(
              'Error loading transactions',
              style: TextStyles.bodyText(
                color: Colors.white,
                size: SizeConstants.font(3.8),
                weight: FontWeight.w600,
              ),
            ),

            // SizedBox(height: SizeConstants.height(1)),
            // Text(
            //   error,
            //   style: TextStyles.smallText(
            //     color: Colors.white70,
            //     size: SizeConstants.font(3.5),
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: SizeConstants.height(3)),
            ElevatedButton(
              onPressed: () => controller.refreshData(),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ColorTheme.secondaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(4),
                  vertical: SizeConstants.height(0.5),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyles.buttonText(
                  size: SizeConstants.font(3.2),
                  color: ColorTheme.secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceOverview(TransactionController controller) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total Balance Card
            GestureDetector(
              onTap: () => controller.setFilter('all'),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(4),
                  vertical: SizeConstants.height(1.5),
                ),
                decoration: BoxDecoration(
                  color: controller.selectedFilter == 'all'
                      ? const Color(0xFFE3F2FD)
                      : ColorTheme.mainColor2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyles.smallText(
                        color: controller.selectedFilter == 'all'
                            ? const Color(0xFF87CEEB)
                            : Colors.grey[600],
                        size: SizeConstants.font(3.2),
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(0.3)),
                    // Show loading indicator for balance if loading
                    controller.isLoading && !controller.isDataLoaded
                        ? SizedBox(
                            height: SizeConstants.height(3),
                            width: SizeConstants.width(20),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                controller.selectedFilter == 'all'
                                    ? const Color(0xFF87CEEB)
                                    : ColorTheme.mainColor,
                              ),
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹${controller.totalBalance.toStringAsFixed(2)}',
                              style: TextStyles.bodyText(
                                color: controller.selectedFilter == 'all'
                                    ? const Color(0xFF87CEEB)
                                    : ColorTheme.mainColor,
                                size: SizeConstants.font(5),
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),

            SizedBox(height: SizeConstants.height(2)),

            // Income and Expense in Separate Containers
            Row(
              children: [
                // Income Container
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setFilter('income'),
                    child: Container(
                      padding: EdgeInsets.all(SizeConstants.width(3)),
                      decoration: BoxDecoration(
                        color: controller.selectedFilter == 'income'
                            ? const Color(0xFFE3F2FD)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: SizeConstants.width(7),
                            height: SizeConstants.width(7),
                            decoration: BoxDecoration(
                              color: controller.selectedFilter == 'income'
                                  ? const Color(0xFF87CEEB)
                                  : ColorTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: SizeConstants.font(3.5),
                            ),
                          ),
                          SizedBox(height: SizeConstants.height(0.8)),
                          Text(
                            'Income',
                            style: TextStyles.smallText(
                              color: controller.selectedFilter == 'income'
                                  ? const Color(0xFF87CEEB)
                                  : Colors.grey[600],
                              size: SizeConstants.font(3),
                            ),
                          ),
                          // Show loading indicator for income if loading
                          controller.isLoading && !controller.isDataLoaded
                              ? SizedBox(
                                  height: SizeConstants.height(1.5),
                                  width: SizeConstants.width(15),
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.grey.withOpacity(
                                      0.3,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      controller.selectedFilter == 'income'
                                          ? const Color(0xFF87CEEB)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                )
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹${controller.totalIncome.toStringAsFixed(2)}',
                                    style: TextStyles.bodyText(
                                      color:
                                          controller.selectedFilter == 'income'
                                          ? const Color(0xFF87CEEB)
                                          : const Color(0xFF2E7D32),
                                      size: SizeConstants.font(3.5),
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: SizeConstants.width(3)),

                // Expense Container
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setFilter('expense'),
                    child: Container(
                      padding: EdgeInsets.all(SizeConstants.width(3)),
                      decoration: BoxDecoration(
                        color: controller.selectedFilter == 'expense'
                            ? const Color(0xFFE3F2FD)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: SizeConstants.width(7),
                            height: SizeConstants.width(7),
                            decoration: BoxDecoration(
                              color: controller.selectedFilter == 'expense'
                                  ? const Color(0xFF87CEEB)
                                  : ColorTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.trending_down,
                              color: Colors.white,
                              size: SizeConstants.font(3.5),
                            ),
                          ),
                          SizedBox(height: SizeConstants.height(0.8)),
                          Text(
                            'Expense',
                            style: TextStyles.smallText(
                              color: controller.selectedFilter == 'expense'
                                  ? const Color(0xFF87CEEB)
                                  : Colors.grey[600],
                              size: SizeConstants.font(3),
                            ),
                          ),
                          // Show loading indicator for expense if loading
                          controller.isLoading && !controller.isDataLoaded
                              ? SizedBox(
                                  height: SizeConstants.height(1.5),
                                  width: SizeConstants.width(15),
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.grey.withOpacity(
                                      0.3,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      controller.selectedFilter == 'expense'
                                          ? const Color(0xFF87CEEB)
                                          : ColorTheme.secondaryColor,
                                    ),
                                  ),
                                )
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹${controller.totalExpense.toStringAsFixed(2)}',
                                    style: TextStyles.bodyText(
                                      color:
                                          controller.selectedFilter == 'expense'
                                          ? const Color(0xFF87CEEB)
                                          : ColorTheme.secondaryColor,
                                      size: SizeConstants.font(3.5),
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConstants.height(1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: controller.isLoading && !controller.isDataLoaded
          ? _buildTransactionLoadingList()
          : controller.filteredTransactionGroups.isEmpty
          ? _buildEmptyTransactionList()
          : _buildPaginatedTransactionList(controller),
    );
  }

  Widget _buildTransactionLoadingList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorTheme.secondaryColor,
            ),
            strokeWidth: 3,
          ),
          SizedBox(height: SizeConstants.height(2)),
          Text(
            'Loading transaction list...',
            style: TextStyles.bodyText(
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(4),
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactionList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(
          //   Icons.receipt_long_outlined,
          //   size: SizeConstants.font(15),
          //   color: Colors.grey,
          // ),
          // SizedBox(height: SizeConstants.height(2)),
          Text(
            'No transactions yet',
            style: TextStyles.bodyText(
              color: Colors.grey,
              size: SizeConstants.font(3.5),
              weight: FontWeight.w500,
            ),
          ),
          // SizedBox(height: SizeConstants.height(1)),
          // Text(
          //   'Start adding transactions to see them here',
          //   style: TextStyles.smallText(
          //     color: Colors.grey,
          //     size: SizeConstants.font(2.5),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildPaginatedTransactionList(TransactionController controller) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        SizeConstants.width(5),
        SizeConstants.height(3),
        SizeConstants.width(5),
        SizeConstants.height(2),
      ),
      itemCount:
          controller.filteredTransactionGroups.length +
          (controller.hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        // Check if we should load more transactions automatically (deferred to next frame)
        if (index < controller.filteredTransactionGroups.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.checkAndLoadMore(
              index,
              controller.filteredTransactionGroups.length,
            );
          });
        }

        // Show loading indicator at the end if there are more items
        if (index == controller.filteredTransactionGroups.length) {
          return _buildLoadMoreLoadingIndicator();
        }

        final group = controller.filteredTransactionGroups[index];
        return _buildTransactionGroup(group);
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

  Widget _buildTransactionGroup(TransactionGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: SizeConstants.height(2)),
          child: Text(
            group.month,
            style: TextStyles.bodyText(
              color: ColorTheme.mainColor,
              size: SizeConstants.font(4.5),
              weight: FontWeight.bold,
            ),
          ),
        ),
        ...group.transactions.map(
          (transaction) => _buildTransactionItem(transaction),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Builder(
      builder: (context) {
        final controller = Provider.of<TransactionController>(
          context,
          listen: false,
        );

        return GestureDetector(
          onTap: () =>
              controller.showTransactionDetailDialog(context, transaction),
          child: Container(
            margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(3.5),
              vertical: SizeConstants.height(1.2),
            ),
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
            child: Row(
              children: [
                // Icon
                Container(
                  width: SizeConstants.width(10),
                  height: SizeConstants.width(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: ColorTheme.secondaryColor,
                    size: SizeConstants.font(4),
                  ),
                ),

                SizedBox(width: SizeConstants.width(3)),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyles.bodyText(
                          color: ColorTheme.mainColor,
                          size: SizeConstants.font(3.5),
                          weight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SizeConstants.height(0.2)),
                      Text(
                        transaction.time,
                        style: TextStyles.smallText(
                          color: ColorTheme.secondaryColor,
                          size: SizeConstants.font(2.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SizeConstants.height(0.2)),
                      Text(
                        transaction.category,
                        style: TextStyles.smallText(
                          color: ColorTheme.mainColor,
                          size: SizeConstants.font(2.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Amount
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${transaction.isExpense ? '-' : '+'}₹${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyles.bodyText(
                        color: transaction.isExpense
                            ? ColorTheme.secondaryColor
                            : ColorTheme.green,
                        size: SizeConstants.font(3.5),
                        weight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
