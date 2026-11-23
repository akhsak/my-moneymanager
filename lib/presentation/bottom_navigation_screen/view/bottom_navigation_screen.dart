import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/analysis/analysis_screen/view/analysis_screen.dart';
import 'package:monaymanagment/presentation/categories/category_screen/view/category_screen.dart';
import 'package:monaymanagment/presentation/profile/profile_screen/view/profile_screen.dart';
import 'package:monaymanagment/presentation/transaction/transaction_screen/view/transaction_screen.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/view/loan_screen.dart';
import 'package:monaymanagment/presentation/add_transaction/expense_adding_screen/view/expense_adding_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/presentation/bottom_navigation_screen/controller/bottom_navigation_controller.dart';
import 'package:monaymanagment/presentation/home/home_screen/view/home_screen.dart';

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (context) => BottomNavigationController(),
      child: Consumer<BottomNavigationController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: ColorTheme.mainColor2,
            body: SafeArea(
              top: false,
              child: _getBody(controller.currentIndex),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpenseAddingScreen(
                      categories: [],
                      isIncome: false,
                    ),
                  ),
                );
              },
              backgroundColor: ColorTheme.secondaryColor,
              shape: const CircleBorder(),
              child: Icon(Icons.add, color: ColorTheme.mainColor2, size: 28),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: Container(
              margin: EdgeInsets.symmetric(
                horizontal: SizeConstants.width(4),
                vertical: SizeConstants.height(2),
              ),
              decoration: BoxDecoration(
                color: ColorTheme.bottomNavigationColor,
                borderRadius: BorderRadius.circular(SizeConstants.width(6)),
                border: Border.all(
                  color: ColorTheme.mainColor2, // Light green border
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(3),
                  vertical: SizeConstants.height(1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    controller.navigationItems.length,
                    (index) => _buildNavigationItem(controller, index),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationItem(
    BottomNavigationController controller,
    int index,
  ) {
    final item = controller.navigationItems[index];
    final isActive = controller.currentIndex == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConstants.width(2),
          vertical: SizeConstants.height(1),
        ),
        decoration: BoxDecoration(
          color: isActive ? ColorTheme.secondaryColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? item.activeIcon : item.icon,
          color: isActive ? ColorTheme.mainColor2 : ColorTheme.mainColor,
          size: SizeConstants.font(6),
        ),
      ),
    );
  }

  Widget _getBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AnalysisScreen();
      case 2:
        return const TransactionScreen();
      case 3:
        return const CategoryScreen();
      case 4:
        return const LoanScreen();
      case 5:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
