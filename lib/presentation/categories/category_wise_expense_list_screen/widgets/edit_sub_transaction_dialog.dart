import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/categories/category_wise_expense_list_screen/controller/edit_sub_transaction_controller.dart';

class EditSubTransactionDialog extends StatelessWidget {
  final String name;
  final double amount;
  final DateTime date;
  final String time;
  final String description;
  final Function(
    String name,
    double amount,
    DateTime date,
    String time,
    String description,
  )
  onSave;
  final Future<void> Function() onDelete;

  const EditSubTransactionDialog({
    super.key,
    required this.name,
    required this.amount,
    required this.date,
    required this.time,
    required this.description,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (context) => EditSubTransactionController(
        name: name,
        amount: amount,
        date: date,
        time: time,
        description: description,
      ),
      child: _EditSubTransactionDialogContent(
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }
}

class _EditSubTransactionDialogContent extends StatelessWidget {
  final Function(
    String name,
    double amount,
    DateTime date,
    String time,
    String description,
  )
  onSave;
  final Future<void> Function() onDelete;

  const _EditSubTransactionDialogContent({
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EditSubTransactionController>(
      builder: (context, controller, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: SizeConstants.screenHeight * 0.8,
              maxWidth: SizeConstants.screenWidth * 0.9,
            ),
            padding: EdgeInsets.all(SizeConstants.width(4)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Edit Sub-transaction',
                          style: TextStyles.bodyText(
                            color: ColorTheme.darkBlue,
                            size: SizeConstants.font(4.2),
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(
                          Icons.close,
                          color: ColorTheme.darkBlue,
                          size: SizeConstants.font(4),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: SizeConstants.height(2)),

                  // Name Field
                  _buildField(
                    context: context,
                    controller: controller,
                    label: 'Name',
                    controllerType: 'name',
                    hintText: 'Enter transaction name',
                  ),

                  SizedBox(height: SizeConstants.height(1.5)),

                  // Amount Field
                  _buildField(
                    context: context,
                    controller: controller,
                    label: 'Amount',
                    controllerType: 'amount',
                    hintText: 'Enter amount',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  SizedBox(height: SizeConstants.height(1.5)),

                  // Date and Time Row
                  Row(
                    children: [
                      // Date Field
                      Expanded(child: _buildDateField(context, controller)),
                      SizedBox(width: SizeConstants.width(2)),
                      // Time Field
                      Expanded(child: _buildTimeField(context, controller)),
                    ],
                  ),

                  SizedBox(height: SizeConstants.height(1.5)),

                  // Description Field
                  _buildDescriptionField(context, controller),

                  SizedBox(height: SizeConstants.height(2.5)),

                  // Action Buttons
                  _buildActionButtons(context, controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required BuildContext context,
    required EditSubTransactionController controller,
    required String label,
    required String controllerType,
    required String hintText,
    TextInputType? keyboardType,
    IconData? suffixIcon,
  }) {
    TextEditingController textController;
    switch (controllerType) {
      case 'name':
        textController = controller.nameController;
        break;
      case 'amount':
        textController = controller.amountController;
        break;
      case 'time':
        textController = controller.timeController;
        break;
      default:
        textController = controller.nameController;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.smallText(
            color: ColorTheme.darkBlue,
            size: SizeConstants.font(3.2),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(0.8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConstants.width(3),
            vertical: SizeConstants.height(1),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextField(
            controller: textController,
            keyboardType: keyboardType,
            style: TextStyles.smallText(
              color: ColorTheme.darkBlue,
              size: SizeConstants.font(3.2),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyles.smallText(
                color: Colors.grey,
                size: SizeConstants.font(3.2),
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: ColorTheme.darkBlue,
                      size: SizeConstants.font(3.2),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    EditSubTransactionController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyles.smallText(
            color: ColorTheme.darkBlue,
            size: SizeConstants.font(3.2),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(0.8)),
        GestureDetector(
          onTap: () => _selectDate(context, controller),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(3),
              vertical: SizeConstants.height(1),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(controller.selectedDate),
                    style: TextStyles.smallText(
                      color: ColorTheme.darkBlue,
                      size: SizeConstants.font(3.2),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: ColorTheme.darkBlue,
                  size: SizeConstants.font(3.2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    EditSubTransactionController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyles.smallText(
            color: ColorTheme.darkBlue,
            size: SizeConstants.font(3.2),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(0.8)),
        GestureDetector(
          onTap: () => _selectTime(context, controller),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(3),
              vertical: SizeConstants.height(1),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.timeController.text.isEmpty
                        ? '--:-- --'
                        : controller.timeController.text,
                    style: TextStyles.smallText(
                      color: controller.timeController.text.isEmpty
                          ? Colors.grey
                          : ColorTheme.darkBlue,
                      size: SizeConstants.font(3.2),
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: ColorTheme.darkBlue,
                  size: SizeConstants.font(3.2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(
    BuildContext context,
    EditSubTransactionController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyles.smallText(
            color: ColorTheme.darkBlue,
            size: SizeConstants.font(3.2),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(0.8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConstants.width(3),
            vertical: SizeConstants.height(1),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller.descriptionController,
            maxLines: 3,
            style: TextStyles.smallText(
              color: ColorTheme.darkBlue,
              size: SizeConstants.font(3.2),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Optional description',
              hintStyle: TextStyles.smallText(
                color: Colors.grey,
                size: SizeConstants.font(3.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    EditSubTransactionController controller,
  ) {
    return Column(
      children: [
        // Delete Button
        GestureDetector(
          onTap: controller.isLoading
              ? null
              : () => _showDeleteConfirmation(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.2)),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              'Delete Transaction',
              textAlign: TextAlign.center,
              style: TextStyles.smallText(
                color: Colors.red,
                size: SizeConstants.font(3.2),
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: SizeConstants.height(1.5)),

        // Cancel and Save Buttons Row
        Row(
          children: [
            // Cancel Button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConstants.height(1.2),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyles.smallText(
                      color: Colors.grey,
                      size: SizeConstants.font(3.2),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: SizeConstants.width(2)),

            // Save Button
            Expanded(
              child: GestureDetector(
                onTap: controller.isLoading
                    ? null
                    : () => _saveSubTransaction(context, controller),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConstants.height(1.2),
                  ),
                  decoration: BoxDecoration(
                    color: controller.isLoading
                        ? ColorTheme.secondaryColor.withOpacity(0.5)
                        : ColorTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: controller.isLoading
                      ? SizedBox(
                          width: SizeConstants.width(4),
                          height: SizeConstants.width(4),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          textAlign: TextAlign.center,
                          style: TextStyles.smallText(
                            color: Colors.white,
                            size: SizeConstants.font(3.2),
                            weight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Store the navigator before showing the dialog to ensure we have a valid reference
    final navigator = Navigator.of(context, rootNavigator: false);

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog first
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.pop(dialogContext);
              }

              // Wait a tiny bit to ensure dialog is closed
              await Future.delayed(Duration(milliseconds: 150));

              // Call delete function and wait for it
              try {
                await onDelete();

                // Close edit dialog after delete completes successfully
                // Use the stored navigator and check if we can pop
                if (navigator.canPop()) {
                  navigator.pop();
                }
              } catch (e) {
                // If delete fails, show error but don't close dialog
                // Try to get a fresh context from the navigator
                try {
                  final currentContext = navigator.context;
                  if (currentContext.mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (_) {
                  // If context is invalid, ignore the error
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _selectDate(
    BuildContext context,
    EditSubTransactionController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.updateSelectedDate(picked);
    }
  }

  void _selectTime(
    BuildContext context,
    EditSubTransactionController controller,
  ) async {
    // Parse current time or use current time as default
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.timeController.text.isNotEmpty) {
      try {
        final timeParts = controller.timeController.text.split(' ');
        final timeStr = timeParts[0];
        final period = timeParts.length > 1 ? timeParts[1] : 'AM';
        final hourMinute = timeStr.split(':');
        final hour = int.parse(hourMinute[0]);
        final minute = int.parse(hourMinute[1]);

        // Convert to 24-hour format for TimeOfDay
        int hour24 = hour;
        if (period == 'PM' && hour != 12) {
          hour24 = hour + 12;
        } else if (period == 'AM' && hour == 12) {
          hour24 = 0;
        }

        initialTime = TimeOfDay(hour: hour24, minute: minute);
      } catch (e) {
        // If parsing fails, use current time
        initialTime = TimeOfDay.now();
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      // Convert to 12-hour format with AM/PM
      final hour = picked.hour;
      final minute = picked.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final timeString =
          '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

      controller.timeController.text = timeString;
    }
  }

  String _formatDate(DateTime date) {
    return '${_month(date.month)} ${date.day}, ${date.year}';
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

  void _saveSubTransaction(
    BuildContext context,
    EditSubTransactionController controller,
  ) async {
    if (controller.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a transaction name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (controller.amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (controller.timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amountValue = double.tryParse(
      controller.amountController.text.trim(),
    );
    if (amountValue == null || amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Preserve the original sign (positive for income, negative for expenses)
    final finalAmount = controller.originalAmount >= 0
        ? amountValue
        : -amountValue;

    controller.setLoading(true);

    try {
      await onSave(
        controller.nameController.text.trim(),
        finalAmount,
        controller.selectedDate,
        controller.timeController.text.trim(),
        controller.descriptionController.text.trim(),
      );
      // Dialog close and success message are handled by the parent component
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update sub-transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        controller.setLoading(false);
      }
    }
  }
}
