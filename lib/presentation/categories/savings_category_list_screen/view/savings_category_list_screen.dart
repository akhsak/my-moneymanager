// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:monaymanagment/core/constants/color_constants.dart';
// import 'package:monaymanagment/core/constants/size_constatnts.dart';
// import 'package:monaymanagment/core/constants/text_styles.dart';
// import 'package:monaymanagment/presentation/savings_category_list_screen/controller/savings_category_list_controller.dart';

// class SavingsCategoryListScreen extends StatelessWidget {
//   const SavingsCategoryListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SizeConstants.init(context);
//     return ChangeNotifierProvider(
//       create: (_) => SavingsCategoryListController(),
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
//           title: Consumer<SavingsCategoryListController>(
//             builder: (context, controller, _) {
//               return Text(
//                 controller.categoryName,
//                 textAlign: TextAlign.center,
//                 style: TextStyles.bodyText(
//                   color: Colors.white,
//                   size: SizeConstants.font(4.5),
//                   weight: FontWeight.bold,
//                 ),
//               );
//             },
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
//         body: Consumer<SavingsCategoryListController>(
//           builder: (context, controller, _) {
//             return Container(
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF0F8F0), // Light green/off-white
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: EdgeInsets.all(SizeConstants.width(5)),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: SizeConstants.height(2)),
//                             _buildSavingsSummary(controller),
//                             SizedBox(height: SizeConstants.height(3)),
//                             _buildTransactionHistory(controller),
//                             SizedBox(height: SizeConstants.height(3)),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Fixed bottom button
//                     Container(
//                       padding: EdgeInsets.all(SizeConstants.width(5)),
//                       child: _buildAddSavingsButton(),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSavingsSummary(SavingsCategoryListController controller) {
//     return Container(
//       padding: EdgeInsets.all(SizeConstants.width(4)),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Left side - Savings details
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Goal
//                 Text(
//                   'Goal',
//                   style: TextStyles.smallText(
//                     color: ColorTheme.mainColor,
//                     size: SizeConstants.font(3.2),
//                     weight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: SizeConstants.height(0.5)),
//                 Text(
//                   '\$${controller.goal.toStringAsFixed(2)}',
//                   style: TextStyles.bodyText(
//                     color: ColorTheme.mainColor,
//                     size: SizeConstants.font(4.5),
//                     weight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: SizeConstants.height(2)),
                
//                 // Amount Saved
//                 Text(
//                   'Amount Saved',
//                   style: TextStyles.smallText(
//                     color: ColorTheme.mainColor,
//                     size: SizeConstants.font(3.2),
//                     weight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: SizeConstants.height(0.5)),
//                 Text(
//                   '\$${controller.amountSaved.toStringAsFixed(2)}',
//                   style: TextStyles.bodyText(
//                     color: ColorTheme.mainColor,
//                     size: SizeConstants.font(4.5),
//                     weight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: SizeConstants.height(2)),
                
//                 // Progress percentage
//                 Text(
//                   '${controller.progressPercentage.toInt()}% Complete',
//                   style: TextStyles.smallText(
//                     color: const Color(0xFF87CEEB),
//                     size: SizeConstants.font(3.2),
//                     weight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           SizedBox(width: SizeConstants.width(4)),
          
//           // Right side - Circular progress indicator
//           Expanded(
//             flex: 1,
//             child: _buildCircularProgress(controller),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCircularProgress(SavingsCategoryListController controller) {
//     return Column(
//       children: [
//         Container(
//           width: SizeConstants.width(25),
//           height: SizeConstants.width(25),
//           decoration: BoxDecoration(
//             color: const Color(0xFFE3F2FD), // Light blue
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Circular progress indicator
//               SizedBox(
//                 width: SizeConstants.width(20),
//                 height: SizeConstants.width(20),
//                 child: CircularProgressIndicator(
//                   value: controller.progressPercentage / 100,
//                   strokeWidth: 4,
//                   backgroundColor: Colors.white,
//                   valueColor: AlwaysStoppedAnimation<Color>(ColorTheme.secondaryColor),
//                 ),
//               ),
//               // Category icon
//               Container(
//                 width: SizeConstants.width(12),
//                 height: SizeConstants.width(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: const Color(0xFFE3F2FD),
//                     width: 2,
//                   ),
//                 ),
//                 child: Icon(
//                   controller.categoryIcon,
//                   color: const Color(0xFF87CEEB),
//                   size: SizeConstants.font(4),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: SizeConstants.height(1)),
//         Text(
//           controller.categoryName,
//           style: TextStyles.smallText(
//             color: ColorTheme.mainColor,
//             size: SizeConstants.font(3.2),
//             weight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransactionHistory(SavingsCategoryListController controller) {
//     final transactionsByMonth = controller.transactionsByMonth;
    
//     if (transactionsByMonth.isEmpty) {
//       return Container(
//         padding: EdgeInsets.all(SizeConstants.width(4)),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Column(
//             children: [
//               Icon(
//                 Icons.receipt_long,
//                 color: Colors.grey,
//                 size: SizeConstants.font(8),
//               ),
//               SizedBox(height: SizeConstants.height(2)),
//               Text(
//                 'No transactions yet',
//                 style: TextStyles.smallText(
//                   color: Colors.grey,
//                   size: SizeConstants.font(3.5),
//                   weight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: transactionsByMonth.entries.map((entry) {
//         return Container(
//           margin: EdgeInsets.only(bottom: SizeConstants.height(2)),
//           padding: EdgeInsets.all(SizeConstants.width(4)),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Month header
//               Row(
//                 children: [
//                   Text(
//                     entry.key,
//                     style: TextStyles.bodyText(
//                       color: ColorTheme.mainColor,
//                       size: SizeConstants.font(4),
//                       weight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: SizeConstants.width(2)),
//                   Icon(
//                     Icons.calendar_today,
//                     color: ColorTheme.secondaryColor,
//                     size: SizeConstants.font(3.5),
//                   ),
//                 ],
//               ),
//               SizedBox(height: SizeConstants.height(1.5)),
              
//               // Transactions for this month
//               ...entry.value.map((transaction) => _buildTransactionItem(transaction)),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildTransactionItem(SavingsTransaction transaction) {
//     return Container(
//       margin: EdgeInsets.only(bottom: SizeConstants.height(1)),
//       padding: EdgeInsets.symmetric(
//         vertical: SizeConstants.height(1.2),
//         horizontal: SizeConstants.width(2),
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: const Color(0xFFE3F2FD),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           // Icon
//           Container(
//             width: SizeConstants.width(10),
//             height: SizeConstants.width(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE3F2FD),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.flight,
//               color: Colors.white,
//               size: SizeConstants.font(3),
//             ),
//           ),
//           SizedBox(width: SizeConstants.width(3)),
          
//           // Transaction details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   transaction.title,
//                   style: TextStyles.smallText(
//                     color: ColorTheme.mainColor,
//                     size: SizeConstants.font(3.2),
//                     weight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   '${transaction.formattedTime} - ${transaction.formattedDate}',
//                   style: TextStyles.smallText(
//                     color: const Color(0xFF87CEEB),
//                     size: SizeConstants.font(2.8),
//                     weight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Amount
//           Text(
//             '\$${transaction.amount.toStringAsFixed(2)}',
//             style: TextStyles.smallText(
//               color: transaction.isCancelled ? Colors.grey : ColorTheme.mainColor,
//               size: SizeConstants.font(3.2),
//               weight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddSavingsButton() {
//     return GestureDetector(
//       onTap: () {
//         // TODO: Navigate to add savings screen or show dialog
//         print('Add Savings tapped');
//       },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(
//           vertical: SizeConstants.height(2),
//         ),
//         decoration: BoxDecoration(
//           color: ColorTheme.secondaryColor,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: ColorTheme.secondaryColor.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             'Add Savings',
//             style: TextStyles.buttonText(
//               color: Colors.white,
//               size: SizeConstants.font(4.2),
//               weight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
