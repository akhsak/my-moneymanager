// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:monaymanagment/core/constants/color_constants.dart';
// import 'package:monaymanagment/core/constants/size_constatnts.dart';
// import 'package:monaymanagment/core/constants/text_styles.dart';
// import 'package:monaymanagment/presentation/saving_category_screen/controller/savings_controller.dart';

// class SavingCategoryScreen extends StatelessWidget {
//   const SavingCategoryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SizeConstants.init(context);
//     return ChangeNotifierProvider(
//       create: (_) => SavingsController(),
//       child: Scaffold(
//         backgroundColor: ColorTheme.secondaryColor,
//         appBar: AppBar(
//           backgroundColor: ColorTheme.secondaryColor,
//           leading: IconButton(
//             onPressed: () => Navigator.pop(context),
//             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
//             padding: EdgeInsets.zero,
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.white,
//               size: SizeConstants.width(3.5),
//             ),
//           ),
//           centerTitle: true,
//           title: Text(
//             'Savings',
//             textAlign: TextAlign.center,
//             style: TextStyles.bodyText(
//               color: Colors.white,
//               size: SizeConstants.font(4.5),
//               weight: FontWeight.bold,
//             ),
//           ),
//           actions: [
//             IconButton(
//               onPressed: () {},
//               constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
//               padding: EdgeInsets.zero,
//               icon: Icon(
//                 Icons.notifications_outlined,
//                 color: Colors.white,
//                 size: SizeConstants.width(3.5),
//               ),
//             ),
//           ],
//         ),
//         body: Consumer<SavingsController>(
//           builder: (context, controller, _) {
//             return Column(
//               children: [
//                 _buildBalanceOverview(controller),
//                 Expanded(
//                   child: _buildMainContent(controller),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }


//   Widget _buildBalanceOverview(SavingsController controller) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: SizeConstants.width(5),
//         vertical: SizeConstants.height(2),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildBalanceItem(
//               icon: Icons.trending_up,
//               label: 'Total Balance',
//               amount: '\$${controller.totalBalance.toStringAsFixed(2)}',
//               amountColor: Colors.white,
//             ),
//           ),
//           Container(
//             width: 1,
//             height: SizeConstants.height(8),
//             color: Colors.white.withOpacity(0.3),
//           ),
//           Expanded(
//             child: _buildBalanceItem(
//               icon: Icons.trending_down,
//               label: 'Total Expense',
//               amount: '-\$${controller.totalExpense.toStringAsFixed(2)}',
//               amountColor: const Color(0xFF87CEEB), // Light blue
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBalanceItem({
//     required IconData icon,
//     required String label,
//     required String amount,
//     required Color amountColor,
//   }) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: Colors.white,
//               size: SizeConstants.font(3.5),
//             ),
//             SizedBox(width: SizeConstants.width(1)),
//             Text(
//               label,
//               style: TextStyles.smallText(
//                 color: Colors.white,
//                 size: SizeConstants.font(3),
//                 weight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: SizeConstants.height(1)),
//         Text(
//           amount,
//           style: TextStyles.bodyText(
//             color: amountColor,
//             size: SizeConstants.font(4.5),
//             weight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }


//   Widget _buildMainContent(SavingsController controller) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFFF0F8F0), // Light green/off-white
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(SizeConstants.width(5)),
//         child: Column(
//           children: [
//             SizedBox(height: SizeConstants.height(2)),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 15,
//                   mainAxisSpacing: 15,
//                   childAspectRatio: 1,
//                 ),
//                 itemCount: controller.categories.length,
//                 itemBuilder: (context, index) {
//                   final category = controller.categories[index];
//                   return _buildCategoryCard(category, controller, index);
//                 },
//               ),
//             ),
//             SizedBox(height: SizeConstants.height(2)),
//             _buildAddMoreButton(),
//             SizedBox(height: SizeConstants.height(2)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryCard(SavingsCategory category, SavingsController controller, int index) {
//     final isSelected = controller.isSelected(index);
    
//     return GestureDetector(
//       onTap: () {
//         controller.selectCategory(index);
//         // TODO: Navigate to savings detail screen for this category
//         print('Tapped on ${category.title}');
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: isSelected ? ColorTheme.secondaryColor : Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               category.icon,
//               color: isSelected ? Colors.white : const Color(0xFF87CEEB),
//               size: SizeConstants.font(6),
//             ),
//             SizedBox(height: SizeConstants.height(1)),
//             Text(
//               category.title,
//               style: TextStyles.smallText(
//                 color: isSelected ? Colors.white : ColorTheme.mainColor,
//                 size: SizeConstants.font(3),
//                 weight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAddMoreButton() {
//     return Builder(
//       builder: (context) => GestureDetector(
//         onTap: () {
//           _showNewCategoryDialog(context);
//         },
//       child: Container(
//         width: SizeConstants.width(60),
//         padding: EdgeInsets.symmetric(
//           vertical: SizeConstants.height(1.8),
//         ),
//         decoration: BoxDecoration(
//           color: ColorTheme.secondaryColor,
//           borderRadius: BorderRadius.circular(25),
//         ),
//         child: Center(
//           child: Text(
//             'Add More',
//             style: TextStyles.buttonText(
//               color: Colors.white,
//               size: SizeConstants.font(4),
//               weight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     ),
//     );
//   }

//   void _showNewCategoryDialog(BuildContext context) {
//     final TextEditingController categoryController = TextEditingController();
    
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFFF5F5F5), // Light grey background
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//             side: const BorderSide(
//               color: Color(0xFFE0E0E0), // Slightly darker grey border
//               width: 1,
//             ),
//           ),
//           contentPadding: EdgeInsets.all(SizeConstants.width(6)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Title
//               Text(
//                 'New Category',
//                 style: TextStyles.bodyText(
//                   color: ColorTheme.mainColor,
//                   size: SizeConstants.font(4.5),
//                   weight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: SizeConstants.height(3)),
              
//               // Input Field
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: SizeConstants.width(4),
//                   vertical: SizeConstants.height(1.5),
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE8E8E8), // Light purple-grey background
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   controller: categoryController,
//                   decoration: InputDecoration(
//                     hintText: 'Write...',
//                     hintStyle: TextStyles.smallText(
//                       color: const Color(0xFFB0B0B0),
//                       size: SizeConstants.font(3.5),
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                   style: TextStyles.smallText(
//                     color: ColorTheme.mainColor,
//                     size: SizeConstants.font(3.5),
//                   ),
//                 ),
//               ),
//               SizedBox(height: SizeConstants.height(3)),
              
//               // Save Button
//               GestureDetector(
//                 onTap: () {
//                   if (categoryController.text.trim().isNotEmpty) {
//                     // TODO: Add new category to controller
//                     print('New category: ${categoryController.text.trim()}');
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(
//                     vertical: SizeConstants.height(1.8),
//                   ),
//                   decoration: BoxDecoration(
//                     color: ColorTheme.secondaryColor, // Dark blue
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Save',
//                       style: TextStyles.buttonText(
//                         color: Colors.white,
//                         size: SizeConstants.font(3.8),
//                         weight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: SizeConstants.height(1.5)),
              
//               // Cancel Button
//               GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(
//                     vertical: SizeConstants.height(1.8),
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE8E8E8), // Light purple-grey
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Cancel',
//                       style: TextStyles.buttonText(
//                         color: ColorTheme.mainColor,
//                         size: SizeConstants.font(3.8),
//                         weight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
