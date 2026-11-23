// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:monaymanagment/core/constants/color_constants.dart';
// import 'package:monaymanagment/core/constants/size_constatnts.dart';
// import 'package:monaymanagment/core/constants/text_styles.dart';
// import 'package:monaymanagment/presentation/expense_adding_screen/controller/expense_adding_controller.dart';
// import 'package:monaymanagment/presentation/category_screen/widgets/add_category_dialog.dart';
// import 'package:monaymanagment/presentation/category_screen/controller/category_controller.dart';
// import 'package:monaymanagment/presentation/loan_adding_screen/view/loan_adding_screen.dart';

// class ExpenseAddingScreen extends StatelessWidget {
//   final List<String> categories;
//   final bool isIncome;
//   const ExpenseAddingScreen({super.key, required this.categories, this.isIncome = false});

//   @override
//   Widget build(BuildContext context) {
//     SizeConstants.init(context);
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ExpenseAddingController()),
//         ChangeNotifierProvider(create: (_) => CategoryController()..loadCategories()),
//       ],
//       child: Scaffold(
//         backgroundColor: ColorTheme.secondaryColor,
//         appBar: AppBar(
//           backgroundColor: ColorTheme.secondaryColor,
//           centerTitle: true,
//           leading: IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConstants.width(3.5)),
//           ),
//           title: Text(
//             isIncome ? 'Add Income' : 'Add Expenses', 
//             style: TextStyles.bodyText(color: Colors.white, size: SizeConstants.font(4.5), weight: FontWeight.bold)
//           ),
//           actions: [
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.notifications_outlined, color: Colors.white, size: SizeConstants.width(3.5)),
//             )
//           ],
//         ),
//         body: Container(
//           decoration: const BoxDecoration(
//             color: Color(0xFFF0F8F0),
//             borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
//           ),
//           child: Column(
//             children: [
//               // Transaction Type Selection Buttons
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: SizeConstants.width(5), 
//                   vertical: SizeConstants.height(2)
//                 ),
//                 child: _buildTransactionTypeButtons(context),
//               ),
//               Expanded(
//                 child: Consumer2<ExpenseAddingController, CategoryController>(
//                   builder: (context, controller, categoryController, _) {
//                     return RefreshIndicator(
//                       onRefresh: () async {
//                         await categoryController.loadCategories();
//                       },
//                       child: SingleChildScrollView(
//                         padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(5), vertical: SizeConstants.height(1)),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _label('Date'),
//                             _dateField(context, controller),
//                             SizedBox(height: SizeConstants.height(2.5)),
//                             _label('Category *'),
//                             _categoryField(controller, categoryController, context),
//                             // Show error message if category loading failed
//                             if (categoryController.errorMessage != null)
//                               Padding(
//                                 padding: EdgeInsets.only(top: SizeConstants.height(1)),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         categoryController.errorMessage!,
//                                         style: TextStyles.smallText(
//                                           color: Colors.red,
//                                           size: SizeConstants.font(3),
//                                         ),
//                                       ),
//                                     ),
//                                     TextButton(
//                                       onPressed: () {
//                                         categoryController.loadCategories();
//                                       },
//                                       child: Text(
//                                         'Retry',
//                                         style: TextStyles.smallText(
//                                           color: ColorTheme.secondaryColor,
//                                           size: SizeConstants.font(3),
//                                           weight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             SizedBox(height: SizeConstants.height(2.5)),
//                             _label('Sub-Category'),
//                             _roundedField(
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       'Add Sub-Category',
//                                       style: TextStyles.smallText(size: SizeConstants.font(3.2), color: ColorTheme.mainColor),
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: controller.addSubCategoryField,
//                                     child: Icon(Icons.add, color: ColorTheme.secondaryColor, size: SizeConstants.font(3.6)),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             ...List.generate(controller.subCategoryControllers.length, (i) {
//                               return Padding(
//                                 padding: EdgeInsets.only(top: SizeConstants.height(1.2)),
//                                 child: _roundedField(
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextField(
//                                           controller: controller.subCategoryControllers[i],
//                                           decoration: const InputDecoration(
//                                             border: InputBorder.none,
//                                             hintText: 'Enter Sub-Category',
//                                           ),
//                                         ),
//                                       ),
//                                       if (controller.subCategoryControllers.length > 1)
//                                         InkWell(
//                                           onTap: () => controller.removeSubCategoryField(i),
//                                           child: Icon(
//                                             Icons.remove_circle_outline,
//                                             color: Colors.red,
//                                             size: SizeConstants.font(3.6),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }),
//                             SizedBox(height: SizeConstants.height(2.5)),
//                             _label('Amount *'),
//                             _roundedField(
//                               child: TextField(
//                                 controller: controller.amountController,
//                                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                                 decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter Amount'),
//                               ),
//                             ),
//                             SizedBox(height: SizeConstants.height(2.5)),
//                             _label('${isIncome ? 'Income' : 'Expense'} Title *'),
//                             _roundedField(
//                               child: TextField(
//                                 controller: controller.titleController,
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none, 
//                                   hintText: isIncome ? 'Enter Title' : 'Enter Title'
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: SizeConstants.height(2.5)),
//                             _roundedField(
//                               minHeight: SizeConstants.height(18),
//                               child: TextField(
//                                 controller: controller.notesController,
//                                 maxLines: 6,
//                                 decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter Message'),
//                               ),
//                             ),
//                             SizedBox(height: SizeConstants.height(2)),
                            
//                             // Show error message if saving failed
//                             if (controller.errorMessage != null)
//                               Container(
//                                 width: double.infinity,
//                                 padding: EdgeInsets.all(SizeConstants.width(3)),
//                                 margin: EdgeInsets.only(bottom: SizeConstants.height(2)),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(SizeConstants.width(2)),
//                                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                                 ),
//                                 child: Text(
//                                   controller.errorMessage!,
//                                   style: TextStyles.smallText(
//                                     color: Colors.red,
//                                     size: SizeConstants.font(3.2),
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             SizedBox(height: SizeConstants.height(2)),
//                             Center(
//                               child: GestureDetector(
//                                 onTap: controller.isValid && !controller.isLoading && !categoryController.isLoading
//                                     ? () async {
//                                         // Clear any previous errors
//                                         controller.clearErrorMessage();
                                        
//                                         final success = await controller.saveExpense(isIncome: isIncome);
//                                         if (success) {
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                               content: Text('${isIncome ? 'Income' : 'Expense'} saved successfully!'),
//                                               backgroundColor: Colors.green,
//                                               duration: Duration(seconds: 2),
//                                             ),
//                                           );
//                                           Navigator.pop(context, true);
//                                         } else {
//                                           // Error message is already set in controller
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                               content: Text(controller.errorMessage ?? 'Failed to save ${isIncome ? 'income' : 'expense'}'),
//                                               backgroundColor: Colors.red,
//                                               duration: Duration(seconds: 3),
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     : () {
//                                         // Show validation errors when button is tapped but form is invalid
//                                         if (!controller.isValid) {
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                               content: Text('Please fill all required fields'),
//                                               backgroundColor: Colors.orange,
//                                               duration: Duration(seconds: 2),
//                                             ),
//                                           );
//                                         }
//                                       },
//                                 child: Container(
//                                   width: SizeConstants.width(50),
//                                   padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.6)),
//                                   decoration: BoxDecoration(
//                                     color: controller.isValid && !controller.isLoading && !categoryController.isLoading 
//                                         ? ColorTheme.secondaryColor 
//                                         : ColorTheme.secondaryColor.withOpacity(0.4),
//                                     borderRadius: BorderRadius.circular(28),
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: controller.isLoading
//                                       ? SizedBox(
//                                           width: SizeConstants.width(5),
//                                           height: SizeConstants.width(5),
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text(
//                                           controller.isLoading 
//                                               ? 'Saving...' 
//                                               : controller.isValid 
//                                                   ? (isIncome ? 'Save Income' : 'Save Expense')
//                                                   : 'save', 
//                                           style: TextStyles.buttonText(
//                                             size: SizeConstants.font(3.6), 
//                                             color: Colors.white, 
//                                             weight: FontWeight.w600
//                                           )
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionTypeButtons(BuildContext context) {
//     return Row(
//       children: [
//         // Add Income Button
//         Expanded(
//           child: _buildTypeButton(
//             context: context,
//             title: 'Add Income',
//             isSelected: isIncome,
//             onTap: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ExpenseAddingScreen(
//                     categories: [],
//                     isIncome: true,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         SizedBox(width: SizeConstants.width(2)),
        
//         // Add Expense Button (Primary/Selected)
//         Expanded(
//           child: _buildTypeButton(
//             context: context,
//             title: 'Add Expense',
//             isSelected: !isIncome,
//             onTap: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ExpenseAddingScreen(
//                     categories: [],
//                     isIncome: false,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         SizedBox(width: SizeConstants.width(2)),
        
//         // Add Loan Button
//         Expanded(
//           child: _buildTypeButton(
//             context: context,
//             title: 'Add Loan',
//             isSelected: false,
//             onTap: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const LoanAddingScreen(),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTypeButton({
//     required BuildContext context,
//     required String title,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           vertical: SizeConstants.height(1.5),
//           horizontal: SizeConstants.width(2),
//         ),
//         decoration: BoxDecoration(
//           color: isSelected ? ColorTheme.secondaryColor : Colors.white,
//           borderRadius: BorderRadius.circular(SizeConstants.width(3)),
//           border: Border.all(
//             color: ColorTheme.secondaryColor.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Text(
//           title,
//           textAlign: TextAlign.center,
//           style: TextStyles.smallText(
//             color: isSelected ? Colors.white : ColorTheme.secondaryColor,
//             size: SizeConstants.font(3.2),
//             weight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _label(String text) {
//     return Text(text, style: TextStyles.smallText(size: SizeConstants.font(3.4), color: ColorTheme.mainColor, weight: FontWeight.w600));
//   }

//   Widget _dateField(BuildContext context, ExpenseAddingController controller) {
//     return _roundedField(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(
//               _formatDate(controller.date),
//               style: TextStyles.smallText(size: SizeConstants.font(3.2), color: ColorTheme.mainColor),
//             ),
//           ),
//           InkWell(
//             onTap: () async {
//               final picked = await showDatePicker(
//                 context: context,
//                 initialDate: controller.date,
//                 firstDate: DateTime(2000),
//                 lastDate: DateTime(2100),
//               );
//               if (picked != null) controller.setDate(picked);
//             },
//             child: Container(
//               padding: EdgeInsets.all(SizeConstants.width(1.5)),
//               decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
//               child: Icon(Icons.calendar_today, color: ColorTheme.secondaryColor, size: SizeConstants.font(3.4)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _categoryField(ExpenseAddingController controller, CategoryController categoryController, BuildContext context) {
//     return _roundedField(
//       child: Row(
//         children: [
//           Expanded(
//             child: categoryController.isLoading
//                 ? Row(
//                     children: [
//                       SizedBox(
//                         width: SizeConstants.width(4),
//                         height: SizeConstants.width(4),
//                         child: CircularProgressIndicator(
//                           color: ColorTheme.secondaryColor,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                       SizedBox(width: SizeConstants.width(2)),
//                       Text(
//                         'Loading categories...',
//                         style: TextStyles.smallText(
//                           size: SizeConstants.font(3.2),
//                           color: ColorTheme.mainColor,
//                         ),
//                       ),
//                     ],
//                   )
//                 : DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: controller.category,
//                       isExpanded: true,
//                       hint: const Text('Select the category'),
//                       items: [
//                         // Regular categories from API
//                         ...categoryController.getCategoryNames()
//                             .map((e) => DropdownMenuItem<String>(value: e, child: Text(e))),
//                         // Add More option
//                         DropdownMenuItem<String>(
//                           value: 'add_more',
//                           child: Row(
//                             children: [
//                               Icon(Icons.add, color: ColorTheme.secondaryColor, size: SizeConstants.font(3.5)),
//                               SizedBox(width: SizeConstants.width(2)),
//                               Text('Add More', style: TextStyle(color: ColorTheme.secondaryColor)),
//                             ],
//                           ),
//                         ),
//                       ],
//                       onChanged: (val) {
//                         if (val == 'add_more') {
//                           // Show Add Category Dialog
//                           showDialog(
//                             context: context,
//                             builder: (context) => AddCategoryDialog(
//                               onSave: (name, icon) async {
//                                 final success = await categoryController.createCategory(name, icon);
//                                 if (success) {
//                                   // Set the newly added category as selected
//                                   controller.setCategory(name);
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('Category added successfully!'),
//                                       backgroundColor: Colors.green,
//                                     ),
//                                   );
//                                 } else if (categoryController.errorMessage != null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(categoryController.errorMessage!),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                           );
//                         } else {
//                           controller.setCategory(val ?? '');
//                         }
//                       },
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _roundedField({required Widget child, double? minHeight}) {
//     return Container(
//       constraints: BoxConstraints(minHeight: minHeight ?? SizeConstants.height(5.5)),
//       padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(4), vertical: SizeConstants.height(1.2)),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE3F2FD),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: child,
//     );
//   }

//   String _formatDate(DateTime d) {
//     return '${_month(d.month)} ${d.day}, ${d.year}';
//   }

//   String _month(int m) {
//     const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
//     return months[m - 1];
//   }
// }

