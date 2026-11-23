import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/add_transaction/expense_adding_screen/controller/expense_adding_controller.dart';
import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/view/add_loan_screen.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/controller/loan_controller.dart';
import 'package:monaymanagment/presentation/add_transaction/add_income_screen/view/add_income_screen.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseAddingController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
      ],
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConstants.width(3.5)),
          ),
          title: Text(
            'Add Expense',
            style: TextStyles.bodyText(color: Colors.white, size: SizeConstants.font(4.5), weight: FontWeight.bold)
          ),
          actions: [
            NotificationIconButton(
              iconColor: Colors.white,
              iconSize: SizeConstants.font(6),
              showBadge: true,
              badgeCount: 5,
            ),
            SizedBox(width: SizeConstants.width(2)),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F8F0),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
          ),
          child: Column(
            children: [
              // Quick Navigation Buttons
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(5), 
                  vertical: SizeConstants.height(2)
                ),
                child: _buildNavigationButtons(context),
              ),
              Expanded(
                child: Consumer2<ExpenseAddingController, CategoryController>(
                  builder: (context, controller, categoryController, _) {
                    // Load categories if not already loaded and not currently loading
                    if (!categoryController.isDataLoaded && !categoryController.isLoading) {
                      Future.microtask(() {
                        categoryController.loadCategories();
                      });
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () async {
                        await categoryController.loadCategories();
                      },
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(5), vertical: SizeConstants.height(1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Date'),
                            _dateField(context, controller),
                            SizedBox(height: SizeConstants.height(2.5)),
                            _label('Category *'),
                            _categoryField(controller, categoryController, context),
                            // Show error message if category loading failed
                            if (categoryController.errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(top: SizeConstants.height(1)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        categoryController.errorMessage!,
                                        style: TextStyles.smallText(
                                          color: Colors.red,
                                          size: SizeConstants.font(3),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        categoryController.loadCategories();
                                      },
                                      child: Text(
                                        'Retry',
                                        style: TextStyles.smallText(
                                          color: ColorTheme.secondaryColor,
                                          size: SizeConstants.font(3),
                                          weight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: SizeConstants.height(2.5)),
                            _label('Amount *'),
                            _roundedField(
                              child: TextField(
                                controller: controller.amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter Amount'),
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(2.5)),
                            _label('Expense Title *'),
                            Builder(
                              builder: (context) => _roundedField(
                                child: DropdownButtonFormField<String>(
                                  value: controller.selectedTitle,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Select expense title',
                                  ),
                                  items: [
                                    // Add existing expense titles
                                    ...controller.expenseTitles.map((title) => DropdownMenuItem(
                                      value: title,
                                      child: Text(title),
                                    )),
                                    // Add "Add new title" option
                                    DropdownMenuItem(
                                      value: 'add_new',
                                      child: Row(
                                        children: [
                                          Icon(Icons.add, color: ColorTheme.secondaryColor, size: SizeConstants.font(3.5)),
                                          SizedBox(width: SizeConstants.width(2)),
                                          Text('Add new title', style: TextStyle(color: ColorTheme.secondaryColor)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == 'add_new') {
                                      controller.showNewTitleFieldMethod();
                                    } else {
                                      controller.setSelectedTitle(value);
                                      controller.hideNewTitleField();
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a title';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            // Show new title text field when "Add new title" is selected
                            if (controller.showNewTitleField) ...[
                              SizedBox(height: SizeConstants.height(1.5)),
                              Builder(
                                builder: (context) => _roundedField(
                                  child: TextField(
                                    controller: controller.newTitleController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter new expense title',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          controller.hideNewTitleField();
                                        },
                                        icon: Icon(Icons.close, color: Colors.grey[600], size: SizeConstants.font(3.5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: SizeConstants.height(2.5)),
                            _roundedField(
                              minHeight: SizeConstants.height(18),
                              child: TextField(
                                controller: controller.notesController,
                                maxLines: 6,
                                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter Message'),
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(2)),
                            
                            // Show error message if saving failed
                            if (controller.errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(SizeConstants.width(3)),
                                margin: EdgeInsets.only(bottom: SizeConstants.height(2)),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Text(
                                  controller.errorMessage!,
                                  style: TextStyles.smallText(
                                    color: Colors.red,
                                    size: SizeConstants.font(3.2),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            SizedBox(height: SizeConstants.height(2)),
                            Center(
                              child: Builder(
                                builder: (context) => GestureDetector(
                                  onTap: controller.isValid && !controller.isLoading && !categoryController.isLoading
                                      ? () async {
                                          // Clear any previous errors
                                          controller.clearErrorMessage();
                                          
                                          // Save expense
                                          final success = await controller.saveExpense(isIncome: false);
                                          final successMessage = 'Expense saved successfully!';
                                          
                                          if (success) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(successMessage),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                              if (context.mounted) {
                                                Navigator.pop(context, true);
                                              }
                                            }
                                          } else {
                                            // Error message is already set in controller
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(controller.errorMessage ?? 'Failed to save'),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      : () {
                                          // Show validation errors when button is tapped but form is invalid
                                          if (!controller.isValid && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Please fill all required fields'),
                                                backgroundColor: Colors.orange,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                  child: Container(
                                    width: SizeConstants.width(50),
                                    padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.6)),
                                    decoration: BoxDecoration(
                                      color: controller.isValid && !controller.isLoading && !categoryController.isLoading 
                                          ? ColorTheme.secondaryColor 
                                          : ColorTheme.secondaryColor.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    alignment: Alignment.center,
                                    child: controller.isLoading
                                        ? SizedBox(
                                            width: SizeConstants.width(5),
                                            height: SizeConstants.width(5),
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            controller.isLoading 
                                                ? 'Saving...' 
                                                : controller.isValid 
                                                    ? 'Save Expense'
                                                    : 'Save', 
                                            style: TextStyles.buttonText(
                                              size: SizeConstants.font(3.6), 
                                              color: Colors.white, 
                                              weight: FontWeight.w600
                                            )
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        // Add Income Button
        Expanded(
          child: _buildTypeButton(
            context: context,
            title: 'Add Income',
            isSelected: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddIncomeScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: SizeConstants.width(2)),
        
        // Add Expense Button (Selected)
        Expanded(
          child: _buildTypeButton(
            context: context,
            title: 'Add Expense',
            isSelected: true,
            onTap: () {
              // Already on expense screen, do nothing
            },
          ),
        ),
        SizedBox(width: SizeConstants.width(2)),
        
        // Add Loan Button
        Expanded(
          child: _buildTypeButton(
            context: context,
            title: 'Add Loan',
            isSelected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => LoanController(),
                    child: const AddLoanScreen(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: SizeConstants.height(1.5),
          horizontal: SizeConstants.width(2),
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorTheme.secondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(SizeConstants.width(3)),
          border: Border.all(
            color: ColorTheme.secondaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyles.smallText(
            color: isSelected ? Colors.white : ColorTheme.secondaryColor,
            size: SizeConstants.font(3.2),
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: TextStyles.smallText(size: SizeConstants.font(3.4), color: ColorTheme.mainColor, weight: FontWeight.w600));
  }

  Widget _dateField(BuildContext context, ExpenseAddingController controller) {
    return Builder(
      builder: (context) => _roundedField(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _formatDate(controller.date),
                style: TextStyles.smallText(size: SizeConstants.font(3.2), color: ColorTheme.mainColor),
              ),
            ),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) controller.setDate(picked);
              },
              child: Container(
                padding: EdgeInsets.all(SizeConstants.width(1.5)),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.calendar_today, color: ColorTheme.secondaryColor, size: SizeConstants.font(3.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryField(ExpenseAddingController controller, CategoryController categoryController, BuildContext context) {
    return Builder(
      builder: (context) => _roundedField(
        child: Row(
          children: [
            Expanded(
              child: categoryController.isLoading || categoryController.getCategoryNames().isEmpty
                ? Row(
                    children: [
                      SizedBox(
                        width: SizeConstants.width(4),
                        height: SizeConstants.width(4),
                        child: CircularProgressIndicator(
                          color: ColorTheme.secondaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: SizeConstants.width(2)),
                      Text(
                        'Loading categories...',
                        style: TextStyles.smallText(
                          size: SizeConstants.font(3.2),
                          color: ColorTheme.mainColor,
                        ),
                      ),
                    ],
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.category,
                      isExpanded: true,
                      hint: const Text('Select the category'),
                      items: [
                        // Regular categories from API
                        ...categoryController.getCategoryNames()
                            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e))),
                        // Fallback categories if API fails
                        if (categoryController.getCategoryNames().isEmpty) ...[
                          DropdownMenuItem<String>(value: 'food', child: Text('Food')),
                          DropdownMenuItem<String>(value: 'health', child: Text('Health')),
                          DropdownMenuItem<String>(value: 'home', child: Text('Home')),
                          DropdownMenuItem<String>(value: 'travel', child: Text('Travel')),
                          DropdownMenuItem<String>(value: 'other', child: Text('Other')),
                        ],
                      ],
                      onChanged: (val) {
                        controller.setCategory(val ?? '');
                        // Load titles for the selected category asynchronously
                        if (val != null && val.isNotEmpty) {
                          controller.loadTitlesForCategory(val, false); // false for expense
                        }
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundedField({required Widget child, double? minHeight}) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? SizeConstants.height(5.5)),
      padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(4), vertical: SizeConstants.height(1.2)),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  String _formatDate(DateTime d) {
    return '${_month(d.month)} ${d.day}, ${d.year}';
  }

  String _month(int m) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return months[m - 1];
  }
}
