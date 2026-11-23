import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/auth/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/controller/loan_controller.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/view/add_loan_screen.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/view/pay_loan_screen.dart';
import 'package:monaymanagment/presentation/home/home_screen/controller/home_controller.dart';
import 'package:monaymanagment/presentation/profile/profile_screen/view/profile_screen.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoanController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
      ],
      child: Consumer2<LoanController, HomeController>(
        builder: (context, controller, homeController, _) {
          return Scaffold(
            backgroundColor: ColorTheme.secondaryColor,
            body: Column(
              children: [
                // Curved Header Section
                Container(
                  decoration: BoxDecoration(color: ColorTheme.secondaryColor),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header Row with Profile, Title, and Notification
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConstants.width(3),
                            vertical: SizeConstants.height(2),
                          ),
                          child: Row(
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
                                  width: SizeConstants.width(8),
                                  height: SizeConstants.width(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: FutureBuilder<User?>(
                                    future:
                                        (homeController
                                                .userProfileImage
                                                ?.isNotEmpty ??
                                            false)
                                        ? Future.value(null)
                                        : AuthService().getStoredUser(),
                                    builder: (context, snapshot) {
                                      final fallbackUrl = (snapshot.hasData)
                                          ? (snapshot.data as User?)
                                                ?.profilePhoto
                                          : null;
                                      final urlToUse =
                                          (homeController
                                                  .userProfileImage
                                                  ?.isNotEmpty ??
                                              false)
                                          ? homeController.userProfileImage
                                          : fallbackUrl;
                                      return CircleAvatar(
                                        radius: SizeConstants.width(3.5),
                                        backgroundColor: Colors.white,
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
                                                size: SizeConstants.width(4),
                                              )
                                            : null,
                                        onBackgroundImageError:
                                            (urlToUse != null &&
                                                urlToUse.isNotEmpty)
                                            ? (exception, stackTrace) {
                                                print(
                                                  'Profile image load error: $exception',
                                                );
                                              }
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: SizeConstants.width(3)),
                              // Title
                              Expanded(
                                child: Text(
                                  'Loans',
                                  textAlign: TextAlign.center,
                                  style: TextStyles.bodyText(
                                    color: Colors.white,
                                    size: SizeConstants.font(4.5),
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Notification Icon Button
                              NotificationIconButton(
                                iconColor: Colors.white,
                                iconSize: SizeConstants.width(5.5),
                                showBadge: true,
                              ),
                            ],
                          ),
                        ),
                        // Summary Cards in Header
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConstants.width(4),
                          ),
                          child: _buildSummaryCards(controller),
                        ),
                        SizedBox(height: SizeConstants.height(2)),
                      ],
                    ),
                  ),
                ),
                // Curved Content Area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8F0), // Light green background
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(SizeConstants.width(8)),
                        topRight: Radius.circular(SizeConstants.width(8)),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () => controller.refresh(),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(SizeConstants.width(5)),
                        child: Column(
                          children: [
                            // Summary Cards
                            // _buildSummaryCards(controller),
                            //SizedBox(height: SizeConstants.height(2)),
                            // Add Loan and Pay Loan Buttons
                            _buildActionButtons(context, controller),
                            SizedBox(height: SizeConstants.height(2)),
                            // Loans List
                            _buildLoansList(context, controller),
                          ],
                        ),
                      ),
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

  Widget _buildSummaryCards(LoanController controller) {
    return Row(
      children: [
        // Total Amount Card (using totalPrincipal from API)
        Expanded(
          child: _buildSummaryCard(
            'Total Amount',
            '₹${controller.totalPrincipal.toStringAsFixed(0)}',
            const Color(0xFFE3F2FD),
          ),
        ),
        SizedBox(width: SizeConstants.width(2)),
        // Amount Paid Card
        Expanded(
          child: _buildSummaryCard(
            'Amount Paid',
            '₹${controller.totalAmountPaid.toStringAsFixed(0)}',
            const Color(0xFFE3F2FD),
          ),
        ),
        SizedBox(width: SizeConstants.width(2)),
        // Balance To Pay Card
        Expanded(
          child: _buildSummaryCard(
            'Balance  Pay',
            '₹${controller.totalBalanceToPay.toStringAsFixed(0)}',
            const Color(0xFFE3F2FD),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(SizeConstants.width(4)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyles.smallText(
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(2.5),
              weight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeConstants.height(1)),
          Text(
            amount,
            style: TextStyles.bodyText(
              color: ColorTheme.primaryColor,
              size: SizeConstants.font(2.5),
              weight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LoanController controller) {
    return Row(
      children: [
        // Add Loan Button
        Expanded(
          child: ElevatedButton(
            onPressed: () => _navigateToAddLoan(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.secondaryColor,
              padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConstants.width(4)),
              ),
            ),
            child: Text(
              'Add Loan',
              style: TextStyles.buttonText(
                color: Colors.white,
                size: SizeConstants.font(3),
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: SizeConstants.width(3)),
        // Pay Loan Button
        Expanded(
          child: ElevatedButton(
            onPressed: controller.loans.isEmpty
                ? null
                : () => _navigateToPayLoan(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.secondaryColor,
              padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConstants.width(4)),
              ),
            ),
            child: Text(
              'Pay Loan',
              style: TextStyles.buttonText(
                color: Colors.white,
                size: SizeConstants.font(3),
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoansList(BuildContext context, LoanController controller) {
    if (controller.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(SizeConstants.height(4)),
          child: CircularProgressIndicator(color: ColorTheme.secondaryColor),
        ),
      );
    }

    if (controller.loans.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(SizeConstants.height(8)),
          child: Column(
            children: [
              SizedBox(height: SizeConstants.height(2)),
              Text(
                'No loans found',
                style: TextStyles.bodyText(
                  color: Colors.grey[600],
                  size: SizeConstants.font(3.8),
                  weight: FontWeight.w500,
                ),
              ),
              SizedBox(height: SizeConstants.height(1)),
              Text(
                'Add your first loan to get started',
                style: TextStyles.smallText(
                  color: Colors.grey[500],
                  size: SizeConstants.font(3.2),
                  weight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loans List
        ...controller.paginatedLoans.map(
          (loan) => _buildLoanCard(context, controller, loan),
        ),
        SizedBox(height: SizeConstants.height(2)),
        // Pagination
        _buildPagination(controller),
      ],
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanController controller, loan) {
    return Dismissible(
      key: Key(loan.id.toString()),
      background: _buildSwipeLeftBackground(),
      secondaryBackground: _buildSwipeRightBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - Delete
          return await _showDeleteConfirmationDialog(context, controller, loan);
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - Edit
          _navigateToEditLoan(context, controller, loan);
          return false; // Don't dismiss
        }
        return false;
      },
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConstants.width(4)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeConstants.width(3.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row - Name and Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      loan.name,
                      style: TextStyles.bodyText(
                        color: ColorTheme.primaryColor,
                        size: SizeConstants.font(3.8),
                        weight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: SizeConstants.width(2)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConstants.width(2.5),
                      vertical: SizeConstants.height(0.5),
                    ),
                    decoration: BoxDecoration(
                      color: ColorTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(
                        SizeConstants.width(2),
                      ),
                    ),
                    child: Text(
                      '₹${loan.balanceToPay.toStringAsFixed(0)}',
                      style: TextStyles.smallText(
                        color: Colors.white,
                        size: SizeConstants.font(3),
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConstants.height(1.2)),
              // Details Row
              Row(
                children: [
                  // Deadline
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: SizeConstants.width(3.5),
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: SizeConstants.width(1.5)),
                        Expanded(
                          child: Text(
                            _formatDateString(loan.deadline),
                            style: TextStyles.smallText(
                              color: Colors.grey[700],
                              size: SizeConstants.font(2.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: SizeConstants.width(2)),
                  // Payment Info
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: SizeConstants.width(3.5),
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: SizeConstants.width(1)),
                      Text(
                        '₹${loan.amountPaid.toStringAsFixed(0)} / ₹${loan.principal.toStringAsFixed(0)}',
                        style: TextStyles.smallText(
                          color: Colors.grey[700],
                          size: SizeConstants.font(2.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: SizeConstants.height(0.8)),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(SizeConstants.width(1)),
                child: LinearProgressIndicator(
                  value: loan.principal > 0
                      ? loan.amountPaid / loan.principal
                      : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loan.balanceToPay == 0
                        ? Colors.green
                        : ColorTheme.secondaryColor,
                  ),
                  minHeight: SizeConstants.height(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Swipe left background (Edit)
  Widget _buildSwipeLeftBackground() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: SizeConstants.width(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.penToSquare,
            color: Colors.white,
            size: SizeConstants.width(5),
          ),
          SizedBox(height: SizeConstants.height(0.5)),
          Text(
            'Edit',
            style: TextStyles.smallText(
              color: Colors.white,
              size: SizeConstants.font(2.8),
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Swipe right background (Delete)
  Widget _buildSwipeRightBackground() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: SizeConstants.width(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.trash,
            color: Colors.white,
            size: SizeConstants.width(5),
          ),
          SizedBox(height: SizeConstants.height(0.5)),
          Text(
            'Delete',
            style: TextStyles.smallText(
              color: Colors.white,
              size: SizeConstants.font(2.8),
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(LoanController controller) {
    if (controller.totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        ElevatedButton(
          onPressed: controller.hasPreviousPage
              ? controller.previousPage
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.hasPreviousPage
                ? const Color(0xFFE3F2FD)
                : Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConstants.width(3)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(4),
              vertical: SizeConstants.height(1),
            ),
          ),
          child: Text(
            'Previous',
            style: TextStyles.smallText(
              color: controller.hasPreviousPage
                  ? ColorTheme.mainColor
                  : Colors.grey[600],
              size: SizeConstants.font(3),
              weight: FontWeight.w500,
            ),
          ),
        ),
        // Page Info
        Text(
          'Page ${controller.currentPage} of ${controller.totalPages}',
          style: TextStyles.smallText(
            color: ColorTheme.mainColor,
            size: SizeConstants.font(3),
            weight: FontWeight.w500,
          ),
        ),
        // Next Button
        ElevatedButton(
          onPressed: controller.hasNextPage ? controller.nextPage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.hasNextPage
                ? const Color(0xFFE3F2FD)
                : Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConstants.width(3)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(4),
              vertical: SizeConstants.height(1),
            ),
          ),
          child: Text(
            'Next',
            style: TextStyles.smallText(
              color: controller.hasNextPage
                  ? ColorTheme.mainColor
                  : Colors.grey[600],
              size: SizeConstants.font(3),
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Navigation Methods
  void _navigateToAddLoan(BuildContext context, LoanController controller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: controller,
          child: const AddLoanScreen(),
        ),
      ),
    );
  }

  void _navigateToPayLoan(BuildContext context, LoanController controller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: controller,
          child: const PayLoanScreen(),
        ),
      ),
    );
  }

  void _navigateToEditLoan(
    BuildContext context,
    LoanController controller,
    loan,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: controller,
          child: AddLoanScreen(existingLoan: loan, isEditing: true),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    LoanController controller,
    loan,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConstants.width(5)),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConstants.width(5)),
            boxShadow: [
              BoxShadow(
                color: ColorTheme.secondaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.all(SizeConstants.width(5)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorTheme.secondaryColor,
                      ColorTheme.secondaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(SizeConstants.width(5)),
                    topRight: Radius.circular(SizeConstants.width(5)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.trash,
                      color: Colors.white,
                      size: SizeConstants.width(5),
                    ),
                    SizedBox(width: SizeConstants.width(3)),
                    Text(
                      'Delete Loan',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(4.5),
                        weight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(SizeConstants.width(5)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Are you sure you want to delete this loan?',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(3.5),
                        color: ColorTheme.mainColor,
                        weight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: SizeConstants.height(2.5)),
                    // Loan Info Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(SizeConstants.width(4)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorTheme.secondaryColor.withOpacity(0.1),
                            ColorTheme.secondaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          SizeConstants.width(3),
                        ),
                        border: Border.all(
                          color: ColorTheme.secondaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: ColorTheme.secondaryColor,
                                size: SizeConstants.width(5),
                              ),
                              SizedBox(width: SizeConstants.width(2)),
                              Expanded(
                                child: Text(
                                  loan.name,
                                  style: TextStyles.bodyText(
                                    size: SizeConstants.font(3.5),
                                    weight: FontWeight.bold,
                                    color: ColorTheme.mainColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConstants.height(1.5)),
                          Divider(
                            color: ColorTheme.secondaryColor.withOpacity(0.2),
                            thickness: 1,
                          ),
                          SizedBox(height: SizeConstants.height(1)),
                          _buildInfoRow(
                            icon: Icons.currency_rupee,
                            label: 'Principal',
                            value: '₹${loan.principal.toStringAsFixed(0)}',
                          ),
                          SizedBox(height: SizeConstants.height(0.8)),
                          _buildInfoRow(
                            icon: Icons.payment,
                            label: 'Amount Paid',
                            value: '₹${loan.amountPaid.toStringAsFixed(0)}',
                          ),
                          SizedBox(height: SizeConstants.height(0.8)),
                          _buildInfoRow(
                            icon: Icons.account_balance,
                            label: 'Balance',
                            value: '₹${loan.balanceToPay.toStringAsFixed(0)}',
                            isHighlight: true,
                          ),
                        ],
                      ),
                    ),

                    // Warning Message
                  ],
                ),
              ),
              // Action Buttons
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeConstants.width(5),
                  0,
                  SizeConstants.width(5),
                  SizeConstants.width(5),
                ),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: ColorTheme.secondaryColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SizeConstants.width(3),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConstants.height(1.5),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyles.buttonText(
                            size: SizeConstants.font(3.5),
                            color: ColorTheme.secondaryColor,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConstants.width(3)),
                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(false);
                          try {
                            await controller.deleteLoan(loan.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: SizeConstants.width(2)),
                                      Text('Loan deleted successfully!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      SizeConstants.width(2),
                                    ),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: SizeConstants.width(2)),
                                      Expanded(
                                        child: Text('Failed to delete: $e'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      SizeConstants.width(2),
                                    ),
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SizeConstants.width(3),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConstants.height(1.5),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyles.buttonText(
                            size: SizeConstants.font(3.5),
                            color: Colors.white,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for info rows in dialog
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: SizeConstants.width(4),
          color: isHighlight
              ? Colors.red
              : ColorTheme.secondaryColor.withOpacity(0.7),
        ),
        SizedBox(width: SizeConstants.width(2)),
        Expanded(
          child: Text(
            label,
            style: TextStyles.smallText(
              size: SizeConstants.font(3),
              color: Colors.grey[600],
              weight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyles.bodyText(
            size: SizeConstants.font(3.2),
            color: isHighlight ? Colors.red : ColorTheme.mainColor,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateString(String dateStr) {
    if (dateStr.isEmpty) return 'Not set';
    try {
      final date = DateTime.parse(dateStr);
      return _formatDate(date);
    } catch (e) {
      return dateStr;
    }
  }
}
