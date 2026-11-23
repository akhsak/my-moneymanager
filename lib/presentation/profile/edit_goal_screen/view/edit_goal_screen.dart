import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';
import 'package:monaymanagment/repository/target/service/target_service.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';

import 'package:monaymanagment/presentation/profile/edit_goal_screen/controller/edit_goal_controller.dart';
import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';

class EditGoalScreen extends StatelessWidget {
  final Target target;
  
  const EditGoalScreen({
    super.key,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditGoalController(target)),
        ChangeNotifierProvider(create: (_) => CategoryController()..loadCategories()),
      ],
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: SizeConstants.width(5),
            ),
          ),
          title: Text(
            'Edit Target',
            style: TextStyles.bodyText(
              color: Colors.white,
              size: SizeConstants.font(4.5),
              weight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showDeleteConfirmationDialog(context, target),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: SizeConstants.width(5),
              ),
            ),
          ],
        ),
        body: Consumer2<EditGoalController, CategoryController>(
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
                    
                    // Add Category Field
                    Text(
                      'Add Category',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(4),
                        weight: FontWeight.w600,
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
                                  style: TextStyles.bodyText(
                                    size: SizeConstants.font(4),
                                  ),
                                ),
                              ],
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedCategoryId ?? target.categoryId,
                                isExpanded: true,
                                hint: Text(
                                  'Add Category',
                                  style: TextStyles.bodyText(
                                    size: SizeConstants.font(4),
                                    color: Colors.grey[500],
                                  ),
                                ),
                                items: categoryController.apiCategories
                                    .map((category) => DropdownMenuItem<String>(
                                          value: category.id,
                                          child: Text(
                                            category.name,
                                            style: TextStyles.bodyText(
                                              size: SizeConstants.font(4),
                                              color: ColorTheme.mainColor,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  controller.setCategory(val ?? '');
                                },
                              ),
                            ),
                    ),
                    
                    SizedBox(height: SizeConstants.height(3)),
                    
                    // Target Amount Field
                    Text(
                      'Target Amount',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(4),
                        weight: FontWeight.w600,
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
                        controller: controller.targetAmountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyles.bodyText(
                          size: SizeConstants.font(4),
                          color: ColorTheme.mainColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Target Amount',
                          hintStyle: TextStyles.bodyText(
                            size: SizeConstants.font(4),
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: SizeConstants.height(6)),
                    
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
                    
                    SizedBox(height: SizeConstants.height(3)),
                    
                    // Save Button
                    Center(
                      child: SizedBox(
                        width: SizeConstants.width(50),
                        height: SizeConstants.height(6),
                        child: ElevatedButton(
                          onPressed: controller.isLoading 
                              ? null 
                              : () => controller.saveChanges(context, categoryController),
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
                                  'Update Target',
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

  void _showDeleteConfirmationDialog(BuildContext context, Target target) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConstants.width(4)),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: SizeConstants.width(6),
              ),
              SizedBox(width: SizeConstants.width(2)),
              Text(
                'Delete Target',
                style: TextStyles.bodyText(
                  size: SizeConstants.font(4.5),
                  weight: FontWeight.bold,
                  color: ColorTheme.mainColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this target?',
                style: TextStyles.bodyText(
                  size: SizeConstants.font(3.5),
                  color: ColorTheme.mainColor,
                ),
              ),
              SizedBox(height: SizeConstants.height(1)),
              Container(
                padding: EdgeInsets.all(SizeConstants.width(3)),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target: ${target.category}',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(3.2),
                        weight: FontWeight.w600,
                        color: ColorTheme.mainColor,
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(0.5)),
                    Text(
                      'Amount: ₹${target.amount.toStringAsFixed(2)}',
                      style: TextStyles.smallText(
                        size: SizeConstants.font(3),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Progress: ${target.progressPercentage.toInt()}%',
                      style: TextStyles.smallText(
                        size: SizeConstants.font(3),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConstants.height(1.5)),
              Text(
                'This action cannot be undone.',
                style: TextStyles.smallText(
                  size: SizeConstants.font(3),
                  color: Colors.red,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyles.buttonText(
                  size: SizeConstants.font(3.5),
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(
                            color: ColorTheme.secondaryColor,
                          ),
                          SizedBox(width: SizeConstants.width(3)),
                          Text(
                            'Deleting target...',
                            style: TextStyles.bodyText(
                              size: SizeConstants.font(3.5),
                              color: ColorTheme.mainColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
                
                // Delete target using TargetService
                try {
                  final targetService = TargetService();
                  final success = await targetService.deleteTarget(target.id);
                  
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Target deleted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop(true); // Return to previous screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete target. Please try again.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete target: $e'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyles.buttonText(
                  size: SizeConstants.font(3.5),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
