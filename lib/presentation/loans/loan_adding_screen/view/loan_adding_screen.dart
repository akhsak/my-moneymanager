import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/loans/loan_adding_screen/controller/loan_adding_controller.dart';
import 'package:monaymanagment/presentation/categories/category_screen/widgets/add_category_dialog.dart';
import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';

class LoanAddingScreen extends StatelessWidget {
  const LoanAddingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoanAddingController()),
        ChangeNotifierProvider(
          create: (_) => CategoryController()..loadCategories(),
        ),
      ],
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: SizeConstants.width(3.5),
            ),
          ),
          title: Text(
            'Add Loan',
            style: TextStyles.bodyText(
              color: Colors.white,
              size: SizeConstants.font(4.5),
              weight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                MyFlutterApp.vector__8_,
                color: Colors.white,
                size: SizeConstants.width(3.5),
              ),
            ),
          ],
        ),
        body: Consumer2<LoanAddingController, CategoryController>(
          builder: (context, controller, categoryController, _) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  await categoryController.loadCategories();
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConstants.width(5),
                    vertical: SizeConstants.height(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Loan Name *'),
                      _roundedField(
                        child: TextField(
                          controller: controller.loanNameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Enter loan name (e.g., Home Loan, Car Loan)',
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(2.5)),
                      _label('Category *'),
                      _categoryField(controller, categoryController, context),
                      // Show error message if category loading failed
                      if (categoryController.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(
                            top: SizeConstants.height(1),
                          ),
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
                      _label('Principal Amount *'),
                      _roundedField(
                        child: TextField(
                          controller: controller.principalController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter principal amount',
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(2.5)),
                      _label('Interest Rate (%)'),
                      _roundedField(
                        child: TextField(
                          controller: controller.interestRateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter interest rate (optional)',
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(2.5)),
                      _label('Deadline *'),
                      _dateField(context, controller),
                      SizedBox(height: SizeConstants.height(2.5)),
                      _label('Notes'),
                      _roundedField(
                        minHeight: SizeConstants.height(12),
                        child: TextField(
                          controller: controller.notesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Enter any additional notes about this loan',
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(2)),

                      // Show error message if saving failed
                      if (controller.errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(SizeConstants.width(3)),
                          margin: EdgeInsets.only(
                            bottom: SizeConstants.height(2),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              SizeConstants.width(2),
                            ),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
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
                        child: GestureDetector(
                          onTap:
                              controller.isValid &&
                                  !controller.isLoading &&
                                  !categoryController.isLoading
                              ? () async {
                                  // Clear any previous errors
                                  controller.clearErrorMessage();

                                  final success = await controller.saveLoan();
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Loan saved successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    Navigator.pop(context, true);
                                  } else {
                                    // Error message is already set in controller
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          controller.errorMessage ??
                                              'Failed to save loan',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              : () {
                                  // Show validation errors when button is tapped but form is invalid
                                  if (!controller.isValid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please fill all required fields',
                                        ),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                          child: Container(
                            width: SizeConstants.width(50),
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConstants.height(1.6),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  controller.isValid &&
                                      !controller.isLoading &&
                                      !categoryController.isLoading
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
                                        ? 'Save Loan'
                                        : 'Save',
                                    style: TextStyles.buttonText(
                                      size: SizeConstants.font(3.6),
                                      color: Colors.white,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyles.smallText(
        size: SizeConstants.font(3.4),
        color: ColorTheme.mainColor,
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _dateField(BuildContext context, LoanAddingController controller) {
    return _roundedField(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _formatDate(controller.deadline),
              style: TextStyles.smallText(
                size: SizeConstants.font(3.2),
                color: ColorTheme.mainColor,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.deadline,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) controller.setDeadline(picked);
            },
            child: Container(
              padding: EdgeInsets.all(SizeConstants.width(1.5)),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today,
                color: ColorTheme.secondaryColor,
                size: SizeConstants.font(3.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryField(
    LoanAddingController controller,
    CategoryController categoryController,
    BuildContext context,
  ) {
    return _roundedField(
      child: Row(
        children: [
          Expanded(
            child: categoryController.isLoading
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
                        ...categoryController.getCategoryNames().map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        ),
                        // Add More option
                        DropdownMenuItem<String>(
                          value: 'add_more',
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: ColorTheme.secondaryColor,
                                size: SizeConstants.font(3.5),
                              ),
                              SizedBox(width: SizeConstants.width(2)),
                              Text(
                                'Add More',
                                style: TextStyle(
                                  color: ColorTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == 'add_more') {
                          // Show Add Category Dialog
                          showDialog(
                            context: context,
                            builder: (context) => AddCategoryDialog(
                              onSave: (name, icon) async {
                                final success = await categoryController
                                    .createCategory(name, icon);
                                if (success) {
                                  // Set the newly added category as selected
                                  controller.setCategory(name);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Category added successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else if (categoryController.errorMessage !=
                                    null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        categoryController.errorMessage!,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        } else {
                          controller.setCategory(val ?? '');
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _roundedField({required Widget child, double? minHeight}) {
    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight ?? SizeConstants.height(5.5),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.width(4),
        vertical: SizeConstants.height(1.2),
      ),
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
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[m - 1];
  }
}
