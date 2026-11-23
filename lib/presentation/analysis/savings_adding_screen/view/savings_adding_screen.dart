// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:monaymanagment/core/constants/color_constants.dart';
// import 'package:monaymanagment/core/constants/size_constatnts.dart';
// import 'package:monaymanagment/core/constants/text_styles.dart';
// import 'package:monaymanagment/presentation/savings_adding_screen/controller/savings_adding_controller.dart';

// class SavingsAddingScreen extends StatelessWidget {
//   const SavingsAddingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SizeConstants.init(context);
//     return ChangeNotifierProvider(
//       create: (_) => SavingsAddingController(),
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
//             'Add Savings',
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
//         body: Consumer<SavingsAddingController>(
//           builder: (context, controller, _) {
//             return Container(
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF0F8F0), // Light green/off-white
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: SizeConstants.width(5),
//                   vertical: SizeConstants.height(3),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _label('Date'),
//                     _dateField(context, controller),
//                     SizedBox(height: SizeConstants.height(2.5)),
//                     _label('Category'),
//                     _categoryField(controller),
//                     SizedBox(height: SizeConstants.height(2.5)),
//                     _label('Amount'),
//                     _roundedField(
//                       child: TextField(
//                         controller: controller.amountController,
//                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           hintText: '217.77',
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: SizeConstants.height(2.5)),
//                     _label('Expense Title'),
//                     _roundedField(
//                       child: TextField(
//                         controller: controller.titleController,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           hintText: 'Travel Deposit',
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: SizeConstants.height(2.5)),
//                     _label('Enter Message'),
//                     _roundedField(
//                       minHeight: SizeConstants.height(18),
//                       child: TextField(
//                         controller: controller.messageController,
//                         maxLines: 6,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           hintText: 'Enter your message here...',
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: SizeConstants.height(4)),
//                     Center(
//                       child: GestureDetector(
//                         onTap: controller.isValid
//                             ? () {
//                                 Navigator.pop(context, controller.buildSavingsPayload());
//                               }
//                             : null,
//                         child: Container(
//                           width: SizeConstants.width(50),
//                           padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.6)),
//                           decoration: BoxDecoration(
//                             color: controller.isValid ? ColorTheme.secondaryColor : ColorTheme.secondaryColor.withOpacity(0.4),
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           alignment: Alignment.center,
//                           child: Text(
//                             'Save',
//                             style: TextStyles.buttonText(
//                               size: SizeConstants.font(3.6),
//                               color: Colors.white,
//                               weight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
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

//   Widget _label(String text) {
//     return Text(
//       text,
//       style: TextStyles.smallText(
//         size: SizeConstants.font(3.4),
//         color: ColorTheme.mainColor,
//         weight: FontWeight.w600,
//       ),
//     );
//   }

//   Widget _dateField(BuildContext context, SavingsAddingController controller) {
//     return _roundedField(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(
//               _formatDate(controller.date),
//               style: TextStyles.smallText(
//                 size: SizeConstants.font(3.2),
//                 color: ColorTheme.mainColor,
//               ),
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
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 Icons.calendar_today,
//                 color: ColorTheme.secondaryColor,
//                 size: SizeConstants.font(3.4),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _categoryField(SavingsAddingController controller) {
//     return _roundedField(
//       child: Row(
//         children: [
//           Expanded(
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: controller.category,
//                 isExpanded: true,
//                 hint: const Text('Select the category'),
//                 items: controller.categories
//                     .map((e) => DropdownMenuItem<String>(
//                           value: e,
//                           child: Text(e),
//                         ))
//                     .toList(),
//                 onChanged: (val) => controller.setCategory(val ?? ''),
//               ),
//             ),
//           ),
//           Icon(
//             Icons.keyboard_arrow_down,
//             color: ColorTheme.secondaryColor,
//             size: SizeConstants.font(3.6),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _roundedField({required Widget child, double? minHeight}) {
//     return Container(
//       constraints: BoxConstraints(minHeight: minHeight ?? SizeConstants.height(5.5)),
//       padding: EdgeInsets.symmetric(
//         horizontal: SizeConstants.width(4),
//         vertical: SizeConstants.height(1.2),
//       ),
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
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December'
//     ];
//     return months[m - 1];
//   }
// }
