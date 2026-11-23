import 'package:flutter/material.dart';
import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';
import 'package:monaymanagment/repository/reminder/service/notification_manager.dart';
import 'package:monaymanagment/repository/reminder/service/reminder_service.dart';
import 'package:monaymanagment/repository/target/service/target_service.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/add_target_screen/controller/add_target_controller.dart';
import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';

class AddTargetScreen extends StatelessWidget {
  const AddTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AddTargetController()),
        ChangeNotifierProvider(create: (_) => CategoryController()..loadCategories()),
      ],
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: CustomAppBar(
          title: 'Add Target',
          showProfileAvatar: false,
          showBackButton: true,
          showNotification: false,
           
          
        ),
        body: Consumer2<AddTargetController, CategoryController>(
          builder: (context, controller, categoryController, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeConstants.width(8)),
                  topRight: Radius.circular(SizeConstants.width(8)),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConstants.width(6)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConstants.height(4)),
                    
                    // Category Field
                    Text(
                      'Add Category',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(3.8),
                        weight: FontWeight.w500,
                        color: ColorTheme.mainColor,
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(1)),
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
                    
                    SizedBox(height: SizeConstants.height(3)),
                    
                    // Target Amount Field
                    Text(
                      'Target Amount',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(3.8),
                        weight: FontWeight.w500,
                        color: ColorTheme.mainColor,
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(1)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConstants.width(4),
                        vertical: SizeConstants.height(0.5),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD), // Light blue background
                        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
                      ),
                      child: TextField(
                        controller: controller.amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyles.bodyText(
                          size: SizeConstants.font(3.5),
                          weight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Target Amount',
                          hintStyle: TextStyles.bodyText(
                            size: SizeConstants.font(3.5),
                            color: Colors.grey[500],
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    //SizedBox(height: SizeConstants.height(6)),
                    
                    // Show validation errors
                    // if (controller.validationErrors.isNotEmpty)
                    //   Container(
                    //     width: double.infinity,
                    //     padding: EdgeInsets.all(SizeConstants.width(3)),
                    //     margin: EdgeInsets.only(bottom: SizeConstants.height(2)),
                    //     decoration: BoxDecoration(
                    //       color: Colors.orange.withOpacity(0.1),
                    //       borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                    //       border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           'Please fix the following issues:',
                    //           style: TextStyles.smallText(
                    //             color: Colors.orange[800],
                    //             size: SizeConstants.font(3),
                    //             weight: FontWeight.w500,
                    //           ),
                    //         ),
                    //         SizedBox(height: SizeConstants.height(0.5)),
                    //         ...controller.validationErrors.map((error) => 
                    //           Padding(
                    //             padding: EdgeInsets.only(top: SizeConstants.height(0.3)),
                    //             child: Row(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: [
                    //                 Text(
                    //                   '• ',
                    //                   style: TextStyles.smallText(
                    //                     color: Colors.orange[800],
                    //                     size: SizeConstants.font(2.8),
                    //                     weight: FontWeight.w500,
                    //                   ),
                    //                 ),
                    //                 Expanded(
                    //                   child: Text(
                    //                     error,
                    //                     style: TextStyles.smallText(
                    //                       color: Colors.orange[800],
                    //                       size: SizeConstants.font(2.8),
                    //                       weight: FontWeight.w500,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    
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
                    
                    SizedBox(height: SizeConstants.height(6)),
                    
                    // Save Button
                    Center(
                      child: SizedBox(
                        width: SizeConstants.width(50),
                        height: SizeConstants.height(6),
                        child: ElevatedButton(
                          onPressed: controller.isValid && !controller.isLoading && !categoryController.isLoading
                              ? () async {
                                  // Clear any previous errors
                                  controller.clearErrorMessage();
                                  
                                  final amount = double.parse(controller.amountController.text.replaceAll(',', '.'));
                                  final selectedCategory = categoryController.apiCategories.firstWhere(
                                    (cat) => cat.id == controller.selectedCategoryId,
                                  );
                                  
                                  final targetService = TargetService();
                                  final reminderService = ReminderService();
                                  final isGuestMode = GuestStorageService.instance.isGuestMode;
                                  try {
                                    // Create the target first
                                    await targetService.createTarget(
                                      categoryId: selectedCategory.id,
                                      category: selectedCategory.name,
                                      amount: amount,
                                    );
                                    
                                    if (!isGuestMode) {
                                      // Create a reminder notification for the new target
                                      try {
                                        final now = DateTime.now();
                                        final response = await reminderService.createReminder(
                                          reminder: 'My Target added: ${selectedCategory.name} - ₹${amount.toStringAsFixed(0)}',
                                          date: _formatDateForAPI(now),
                                          time: _formatTimeForAPI(now),
                                          type: 'my target',
                                        );
                                        print('Reminder created for new target: ${selectedCategory.name}');
                                        
                                        // Add the new reminder to notification manager
                                        final notificationManager = NotificationManager();
                                        notificationManager.addNotification(response.reminder);
                                      } catch (reminderError) {
                                        print('Failed to create reminder for target: $reminderError');
                                        // Don't fail the entire operation if reminder creation fails
                                      }
                                    }
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Target created successfully!'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to create target: $e'),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(SizeConstants.width(6)),
                            ),
                          ),
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
                                  'Submit',
                                  style: TextStyles.buttonText(
                                    size: SizeConstants.font(4),
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
    );
  }

  Widget _categoryField(AddTargetController controller, CategoryController categoryController, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.width(4),
        vertical: SizeConstants.height(0.5),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
      ),
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
                    size: SizeConstants.font(4),
                  ),
                ),
              ],
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedCategoryId,
                isExpanded: true,
                hint: Text(
                  'Add Category',
                  style: TextStyles.smallText(
                    size: SizeConstants.font(4),
                    color: Colors.grey[500],
                  ),
                ),
                items: categoryController.apiCategories
                    .map((category) => DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(
                            category.name,
                            style: TextStyles.smallText(
                              size: SizeConstants.font(4),
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  controller.setCategory(val ?? '');
                },
              ),
            ),
    );
  }

  // Helper methods for date/time formatting
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeForAPI(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}