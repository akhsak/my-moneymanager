import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/my_target_screen/controller/my_target_controller.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';

class MyTargetScreen extends StatelessWidget {
  const MyTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
    return ChangeNotifierProvider(
      create: (_) => MyTargetController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorTheme.mainColor2,
              size: SizeConstants.width(5),
            ),
          ),
          title: Text(
            'My Targets',
            style: TextStyles.bodyText(
              color: ColorTheme.mainColor2,
              size: SizeConstants.font(4),
            ),
          ),
          centerTitle: true,
          actions: [
            NotificationIconButton(
              iconColor: ColorTheme.mainColor2,
              iconSize: SizeConstants.font(6),
              showBadge: true,
              badgeCount: 5,
            ),
            SizedBox(width: SizeConstants.width(2)),
          ],
        ),
        body: Consumer<MyTargetController>(
          builder: (context, controller, _) {
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
                padding: EdgeInsets.all(SizeConstants.width(5)),
                child: Column(
                  children: [
                    // Show error message if loading failed
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.errorMessage!,
                                style: TextStyles.smallText(
                                  color: Colors.red,
                                  size: SizeConstants.font(3.2),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.refreshTargets();
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
                    
                    Expanded(
                      child: controller.isLoading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: ColorTheme.secondaryColor,
                                  ),
                                  SizedBox(height: SizeConstants.height(2)),
                                  Text(
                                    'Loading targets...',
                                    style: TextStyles.bodyText(
                                      color: ColorTheme.mainColor,
                                      size: SizeConstants.font(3.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : controller.targets.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: SizeConstants.width(20),
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: SizeConstants.height(2)),
                                      Text(
                                        'No targets yet',
                                        style: TextStyles.bodyText(
                                          color: Colors.grey[600],
                                          size: SizeConstants.font(4),
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: SizeConstants.height(1)),
                                      Text(
                                        'Add your first target to start saving!',
                                        style: TextStyles.smallText(
                                          color: Colors.grey[500],
                                          size: SizeConstants.font(3.2),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: controller.targets.length,
                                  itemBuilder: (context, index) {
                                    final target = controller.targets[index];
                                    final isExpanded = controller.expandedTargetId == target.id;
                                    
                                    return _buildTargetCard(context, controller, target, isExpanded);
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: Consumer<MyTargetController>(
          builder: (context, controller, _) {
            return FloatingActionButton(
              onPressed: () => controller.navigateToAddTarget(context),
              backgroundColor: ColorTheme.secondaryColor,
              child: Icon(
                Icons.add,
                color: ColorTheme.mainColor2,
                size: SizeConstants.width(6),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTargetCard(BuildContext context, MyTargetController controller, Target target, bool isExpanded) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(1.2)),
      decoration: BoxDecoration(
        color: ColorTheme.mainColor2,
        borderRadius: BorderRadius.circular(SizeConstants.width(2.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: SizeConstants.width(1.2),
            offset: Offset(0, SizeConstants.height(0.3)),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Target Card
          GestureDetector(
            onTap: () => controller.toggleTargetExpansion(target.id),
            child: Padding(
              padding: EdgeInsets.all(SizeConstants.width(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    target.name,
                    style: TextStyles.bodyText(
                      size: SizeConstants.font(3.5),
                      weight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeConstants.height(1.2)),
                  _buildProgressBar(target),
                ],
              ),
            ),
          ),
          
          // Expanded Details
          if (isExpanded) _buildExpandedDetails(context, controller, target),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Target target) {
    return Container(
      height: SizeConstants.height(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeConstants.width(4)),
              gradient: LinearGradient(
                colors: [
                  ColorTheme.secondaryColor.withOpacity(0.3),
                  ColorTheme.secondaryColor,
                ],
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: target.progressPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                  gradient: LinearGradient(
                    colors: [
                      ColorTheme.secondaryColor,
                      ColorTheme.secondaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: SizeConstants.width(2.5),
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '${target.progressPercentage.toInt()}%',
                style: TextStyles.smallText(
                  color: ColorTheme.mainColor2,
                  weight: FontWeight.bold,
                  size: SizeConstants.font(2.2),
                ),
              ),
            ),
          ),
          Positioned(
            right: SizeConstants.width(2.5),
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '₹${target.amount.toStringAsFixed(2)}',
                style: TextStyles.smallText(
                  color: ColorTheme.mainColor2,
                  weight: FontWeight.bold,
                  size: SizeConstants.font(2.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(BuildContext context, MyTargetController controller, Target target) {
    return Container(
      padding: EdgeInsets.all(SizeConstants.width(3)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeConstants.width(2.5)),
          bottomRight: Radius.circular(SizeConstants.width(2.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved: ₹${target.savedAmount.toStringAsFixed(0)}',
                  style: TextStyles.bodyText(
                    size: SizeConstants.font(3),
                    weight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConstants.height(0.8)),
                Text(
                  'Remaining: ₹${target.remainingAmount.toStringAsFixed(0)}',
                  style: TextStyles.bodyText(
                    size: SizeConstants.font(3),
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (target.imageAsset != null)
            Container(
              width: SizeConstants.width(16),
              height: SizeConstants.width(12),
              margin: EdgeInsets.only(right: SizeConstants.width(2.5)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConstants.width(1.5)),
                color: Colors.grey[200],
              ),
              child: Icon(
                _getIconForCategory(target.category),
                size: SizeConstants.width(6),
                color: ColorTheme.secondaryColor,
              ),
            ),
          
          // Action Buttons Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button
              ElevatedButton(
                onPressed: () => controller.navigateToEditGoal(context, target),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConstants.width(2.5)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConstants.width(3),
                    vertical: SizeConstants.height(0.8),
                  ),
                ),
                child: Text(
                  'Edit',
                  style: TextStyles.buttonText(
                    size: SizeConstants.font(2.5),
                  ),
                ),
              ),
              
              SizedBox(width: SizeConstants.width(2)),
              
              // Delete Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeConstants.width(2.5)),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SizeConstants.width(2.5)),
                    onTap: () => _showDeleteConfirmationDialog(context, controller, target),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConstants.width(3),
                        vertical: SizeConstants.height(0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: SizeConstants.width(4),
                          ),
                          SizedBox(width: SizeConstants.width(1)),
                          Text(
                            'Delete',
                            style: TextStyles.buttonText(
                              size: SizeConstants.font(2.5),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, MyTargetController controller, Target target) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConstants.width(4)),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeConstants.width(1.5)),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: SizeConstants.width(5),
                ),
              ),
              SizedBox(width: SizeConstants.width(2)),
              Expanded(
                child: Text(
                  'Delete Target',
                  style: TextStyles.bodyText(
                    size: SizeConstants.font(4.5),
                    weight: FontWeight.bold,
                    color: ColorTheme.mainColor,
                  ),
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
                  size: SizeConstants.font(3.8),
                  color: ColorTheme.mainColor,
                ),
              ),
              SizedBox(height: SizeConstants.height(2)),
              Container(
                padding: EdgeInsets.all(SizeConstants.width(3)),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category, size: SizeConstants.width(3.5), color: ColorTheme.mainColor),
                        SizedBox(width: SizeConstants.width(1.5)),
                        Expanded(
                          child: Text(
                            '${target.category}',
                            style: TextStyles.bodyText(
                              size: SizeConstants.font(3.5),
                              weight: FontWeight.w600,
                              color: ColorTheme.mainColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConstants.height(1)),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: SizeConstants.width(3.5), color: Colors.green[600]),
                        SizedBox(width: SizeConstants.width(1.5)),
                        Text(
                          '₹${target.amount.toStringAsFixed(2)}',
                          style: TextStyles.bodyText(
                            size: SizeConstants.font(3.2),
                            color: Colors.green[600],
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConstants.height(1)),
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: SizeConstants.width(3.5), color: Colors.blue[600]),
                        SizedBox(width: SizeConstants.width(1.5)),
                        Text(
                          '${target.progressPercentage.toInt()}% Complete',
                          style: TextStyles.bodyText(
                            size: SizeConstants.font(3.2),
                            color: Colors.blue[600],
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(4),
                  vertical: SizeConstants.height(1.5),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyles.buttonText(
                  size: SizeConstants.font(3.5),
                  color: Colors.grey[600],
                  weight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(4),
                  vertical: SizeConstants.height(1.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
                elevation: 2,
              ),
              child: Text(
                'Delete',
                style: TextStyles.buttonText(
                  size: SizeConstants.font(3.5),
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (confirmed == true && context.mounted) {
      try {
        // Delete target
        final success = await controller.removeTarget(target.id);
        
        // Show result message
        if (context.mounted) {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          if (success) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: SizeConstants.width(2)),
                    Text('Target deleted successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
              ),
            );
          } else {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: SizeConstants.width(2)),
                    Text('Failed to delete target. Please try again.'),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
              ),
            );
          }
        }
      } catch (e) {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: SizeConstants.width(2)),
                  Text('An error occurred. Please try again.'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConstants.width(2)),
              ),
            ),
          );
        }
      }
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'vehicle':
        return Icons.directions_car;
      case 'travel':
        return Icons.flight;
      case 'electronics':
        return Icons.phone_android;
      case 'home':
        return Icons.home;
      case 'education':
        return Icons.school;
      case 'health':
        return Icons.health_and_safety;
      case 'investment':
        return Icons.trending_up;
      case 'emergency fund':
        return Icons.emergency;
      default:
        return Icons.savings;
    }
  }
}
