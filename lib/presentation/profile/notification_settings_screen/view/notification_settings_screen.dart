import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/notification_screen/view/notification_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/presentation/profile/notification_settings_screen/controller/notification_settings_controller.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return ChangeNotifierProvider(
      create: (_) => NotificationSettingsController()..loadReminders(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        body: Consumer<NotificationSettingsController>(
          builder: (context, controller, _) {
            return CustomScrollView(
              slivers: [
                // Custom Curved Header
                _buildCustomHeader(context),

                // Main Content
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8F0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(SizeConstants.width(8)),
                        topRight: Radius.circular(SizeConstants.width(8)),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(SizeConstants.width(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConstants.height(2)),

                          // Set Reminder Section
                          _buildSetReminderSection(context, controller),

                          SizedBox(height: SizeConstants.height(3)),

                          // Settings Options
                          _buildSettingsSection(context, controller),

                          SizedBox(height: SizeConstants.height(3)),

                          // Set Reminder Button
                          _buildSetReminderButton(context, controller),

                          SizedBox(height: SizeConstants.height(2)),

                          // Error Message
                          if (controller.errorMessage != null)
                            _buildErrorMessage(controller.errorMessage!),

                          SizedBox(height: SizeConstants.height(3)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Recent Reminders Section
                if (controller.reminders.isNotEmpty)
                  _buildRecentRemindersSliver(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  // Custom Curved Header
  Widget _buildCustomHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: SizeConstants.height(8),
      floating: false,
      pinned: true,
      backgroundColor: ColorTheme.secondaryColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: SizeConstants.width(4),
        ),
      ),
      title: Text(
        'Notification Settings',
        style: TextStyles.bodyText(
          color: Colors.white,
          size: SizeConstants.font(4.5),
          weight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          },
          icon: Icon(
            MyFlutterApp.vector__8_,
            color: Colors.white,
            size: SizeConstants.width(5),
          ),
        ),
      ],
    );
  }

  // Set Reminder Section
  Widget _buildSetReminderSection(
    BuildContext context,
    NotificationSettingsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(SizeConstants.width(4)),
      decoration: BoxDecoration(
        color: ColorTheme.mainColor2,
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.grey.withOpacity(0.1),
            blurRadius: SizeConstants.width(2),
            offset: Offset(0, SizeConstants.height(0.5)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Row(
            children: [
              Text(
                'Set Reminder',
                style: TextStyles.bodyText(
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.bold,
                  color: ColorTheme.mainColor,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConstants.height(2)),

          // Date and Time Selection Fields
          Row(
            children: [
              // Date Field
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDatePicker(context, controller),
                  child: Container(
                    padding: EdgeInsets.all(SizeConstants.width(3)),
                    decoration: BoxDecoration(
                      color: ColorTheme.mainColor2,
                      borderRadius: BorderRadius.circular(
                        SizeConstants.width(3),
                      ),
                      border: Border.all(
                        color: ColorTheme.secondaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: ColorTheme.secondaryColor,
                          size: SizeConstants.font(3.5),
                        ),
                        SizedBox(width: SizeConstants.width(2)),
                        Expanded(
                          child: Text(
                            controller.selectedDate != null
                                ? controller.formattedDate
                                : 'Select Date',
                            style: TextStyles.smallText(
                              size: SizeConstants.font(3.5),
                              color: controller.selectedDate != null
                                  ? ColorTheme.mainColor
                                  : ColorTheme.grey,
                              weight: controller.selectedDate != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: SizeConstants.width(2)),

              // Time Field
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTimePicker(context, controller),
                  child: Container(
                    padding: EdgeInsets.all(SizeConstants.width(3)),
                    decoration: BoxDecoration(
                      color: ColorTheme.mainColor2,
                      borderRadius: BorderRadius.circular(
                        SizeConstants.width(3),
                      ),
                      border: Border.all(
                        color: ColorTheme.secondaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: ColorTheme.secondaryColor,
                          size: SizeConstants.font(3.5),
                        ),
                        SizedBox(width: SizeConstants.width(2)),
                        Expanded(
                          child: Text(
                            controller.selectedTime != null
                                ? controller.formattedTime
                                : 'Select Time',
                            style: TextStyles.smallText(
                              size: SizeConstants.font(3.5),
                              color: controller.selectedTime != null
                                  ? ColorTheme.mainColor
                                  : ColorTheme.grey,
                              weight: controller.selectedTime != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConstants.height(2)),

          // Description field
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorTheme.mainColor2,
              borderRadius: BorderRadius.circular(SizeConstants.width(3)),
            ),
            child: TextField(
              controller: controller.descriptionController,
              maxLines: 4,
              onChanged: (value) {
                controller.onDescriptionChanged(value);
              },
              style: TextStyles.smallText(
                size: SizeConstants.font(3.2),
                color: ColorTheme.mainColor,
              ),
              decoration: InputDecoration(
                hintText: 'Enter reminder description...',
                hintStyle: TextStyles.smallText(
                  size: SizeConstants.font(3.2),
                  color: ColorTheme.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(SizeConstants.width(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Settings Section
  Widget _buildSettingsSection(
    BuildContext context,
    NotificationSettingsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(SizeConstants.width(4)),
      decoration: BoxDecoration(
        color: ColorTheme.mainColor2,
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.grey.withOpacity(0.1),
            blurRadius: SizeConstants.width(2),
            offset: Offset(0, SizeConstants.height(0.5)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Notification Settings',
                style: TextStyles.bodyText(
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.bold,
                  color: ColorTheme.mainColor,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConstants.height(2)),

          // Settings Items
          _buildReminderItem(
            icon: Icons.repeat,
            title: 'Repeat',
            hasToggle: true,
            value: controller.repeat,
            onChanged: controller.toggleRepeat,
          ),

          // SizedBox(height: SizeConstants.height(1.5)),

          // _buildReminderItem(
          //   icon: Icons.notifications_outlined,
          //   title: 'Alarm Sound',
          //   hasToggle: true,
          //   value: controller.alarmSound,
          //   onChanged: controller.toggleAlarmSound,
          // ),

          // SizedBox(height: SizeConstants.height(1.5)),

          // _buildReminderItem(
          //   icon: Icons.vibration,
          //   title: 'Vibrate',
          //   hasToggle: true,
          //   value: controller.vibrate,
          //   onChanged: controller.toggleVibrate,
          // ),
          SizedBox(height: SizeConstants.height(1.5)),

          _buildReminderItem(
            icon: Icons.schedule,
            title: 'Remind Me Later',
            hasToggle: false,
            value: false,
            onChanged: null,
            onTap: () => _showRemindMeLaterDialog(context),
          ),
        ],
      ),
    );
  }

  // Recent Reminders as Sliver
  Widget _buildRecentRemindersSliver(
    NotificationSettingsController controller,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Reminders',
                  style: TextStyles.bodyText(
                    size: SizeConstants.font(3.5),
                    weight: FontWeight.bold,
                    color: ColorTheme.mainColor2,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConstants.height(2)),

            // Beautiful Reminder Cards
            ...controller.reminders
                .take(5)
                .map(
                  (reminder) => Container(
                    margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [ColorTheme.mainColor2, ColorTheme.mainColor2],
                      ),
                      borderRadius: BorderRadius.circular(
                        SizeConstants.width(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorTheme.grey.withOpacity(0.15),
                          blurRadius: SizeConstants.width(2),
                          offset: Offset(0, SizeConstants.height(0.5)),
                        ),
                      ],
                      border: Border.all(
                        color: ColorTheme.secondaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(SizeConstants.width(4)),
                      child: Row(
                        children: [
                          // Status Icon
                          Container(
                            width: SizeConstants.width(8),
                            height: SizeConstants.width(8),
                            decoration: BoxDecoration(
                              color: _getReminderStatusColor(reminder),
                              borderRadius: BorderRadius.circular(
                                SizeConstants.width(6),
                              ),
                            ),
                            child: Icon(
                              _getReminderStatusIcon(reminder),
                              color: ColorTheme.mainColor2,
                              size: SizeConstants.font(4),
                            ),
                          ),

                          SizedBox(width: SizeConstants.width(3)),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.reminder,
                                  style: TextStyles.bodyText(
                                    size: SizeConstants.font(3.2),
                                    weight: FontWeight.w600,
                                    color: ColorTheme.mainColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: SizeConstants.height(0.8)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: SizeConstants.font(2.8),
                                      color: ColorTheme.grey,
                                    ),
                                    SizedBox(width: SizeConstants.width(1)),
                                    Text(
                                      '${reminder.date} at ${reminder.time}',
                                      style: TextStyles.smallText(
                                        size: SizeConstants.font(2.8),
                                        color: ColorTheme.grey,
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: SizeConstants.width(2.5),
                                        vertical: SizeConstants.height(0.5),
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getReminderStatusColor(
                                          reminder,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          SizeConstants.width(2),
                                        ),
                                      ),
                                      child: Text(
                                        _getReminderStatusText(reminder),
                                        style: TextStyles.smallText(
                                          size: SizeConstants.font(2.8),
                                          color: _getReminderStatusColor(
                                            reminder,
                                          ),
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),

            SizedBox(height: SizeConstants.height(3)),
          ],
        ),
      ),
    );
  }

  // Helper methods for reminder status
  Color _getReminderStatusColor(dynamic reminder) {
    // You can customize this based on your reminder status logic
    return ColorTheme.secondaryColor;
  }

  IconData _getReminderStatusIcon(dynamic reminder) {
    // You can customize this based on your reminder status logic
    return MyFlutterApp.vector__8_;
  }

  String _getReminderStatusText(dynamic reminder) {
    // You can customize this based on your reminder status logic
    return 'Active';
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String title,
    required bool hasToggle,
    required bool value,
    required Function(bool)? onChanged,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConstants.width(3.5),
          vertical: SizeConstants.height(1.5),
        ),
        decoration: BoxDecoration(
          color: ColorTheme.mainColor2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: SizeConstants.width(7),
              height: SizeConstants.width(7),
              decoration: BoxDecoration(
                color: ColorTheme.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: ColorTheme.mainColor2,
                size: SizeConstants.font(3),
              ),
            ),

            SizedBox(width: SizeConstants.width(3)),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyles.smallText(
                  size: SizeConstants.font(3),
                  weight: FontWeight.w500,
                  color: ColorTheme.mainColor,
                ),
              ),
            ),

            // Toggle Switch (if applicable)
            if (hasToggle)
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: ColorTheme.secondaryColor,
                inactiveThumbColor: ColorTheme.grey,
                inactiveTrackColor: ColorTheme.grey.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetReminderButton(
    BuildContext context,
    NotificationSettingsController controller,
  ) {
    return Center(
      child: SizedBox(
        width: SizeConstants.width(40),
        height: SizeConstants.height(4.5),
        child: ElevatedButton(
          onPressed:
              controller.isLoading ||
                  controller.descriptionController.text.trim().isEmpty ||
                  controller.selectedDate == null ||
                  controller.selectedTime == null
              ? null
              : () async {
                  final success = await controller.createCustomReminder();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reminder created successfully!'),
                        backgroundColor: ColorTheme.green,
                      ),
                    );
                    controller.descriptionController.clear();
                  } else if (controller.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(controller.errorMessage!),
                        backgroundColor: ColorTheme.red,
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                controller.descriptionController.text.trim().isEmpty ||
                    controller.selectedDate == null ||
                    controller.selectedTime == null
                ? ColorTheme.grey.withOpacity(0.3)
                : ColorTheme.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConstants.width(3)),
            ),
            elevation: 0,
          ),
          child: controller.isLoading
              ? SizedBox(
                  width: SizeConstants.width(5),
                  height: SizeConstants.width(5),
                  child: CircularProgressIndicator(
                    color: ColorTheme.mainColor2,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Set Reminder',
                  style: TextStyles.buttonText(
                    color: ColorTheme.mainColor2,
                    size: SizeConstants.font(3.2),
                    weight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConstants.width(3)),
      decoration: BoxDecoration(
        color: ColorTheme.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeConstants.width(2)),
        border: Border.all(color: ColorTheme.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: ColorTheme.red,
            size: SizeConstants.font(4),
          ),
          SizedBox(width: SizeConstants.width(2)),
          Expanded(
            child: Text(
              message,
              style: TextStyles.smallText(
                color: ColorTheme.red,
                size: SizeConstants.font(3.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemindMeLaterDialog(BuildContext context) {
    final controller = Provider.of<NotificationSettingsController>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: ColorTheme.secondaryColor,
          child: Padding(
            padding: EdgeInsets.all(SizeConstants.width(5)),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Remind Me Later',
                        style: TextStyles.bodyText(
                          color: ColorTheme.mainColor2,
                          size: SizeConstants.font(4),
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(1.5)),
                    ...controller.remindDaysOptions.map((days) {
                      final selected = controller.selectedRemindDays == days;
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              controller.setSelectedRemindDays(days);
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '$days Days',
                                    style: TextStyles.smallText(
                                      color: ColorTheme.mainColor2,
                                      size: SizeConstants.font(3.5),
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: SizeConstants.width(5),
                                  height: SizeConstants.width(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ColorTheme.mainColor2,
                                      width: 2,
                                    ),
                                  ),
                                  child: selected
                                      ? Center(
                                          child: Container(
                                            width: SizeConstants.width(3.2),
                                            height: SizeConstants.width(3.2),
                                            decoration: BoxDecoration(
                                              color: ColorTheme.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SizeConstants.height(0.8)),
                          Container(
                            height: 1,
                            color: ColorTheme.mainColor2.withOpacity(0.6),
                          ),
                          SizedBox(height: SizeConstants.height(1.2)),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: SizeConstants.height(2)),
                    Center(
                      child: SizedBox(
                        width: SizeConstants.width(50),
                        height: SizeConstants.height(5.5),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyles.buttonText(
                              color: ColorTheme.secondaryColor,
                              size: SizeConstants.font(3.5),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Separate Date Picker
  void _showDatePicker(
    BuildContext context,
    NotificationSettingsController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorTheme.secondaryColor,
              onPrimary: ColorTheme.mainColor2,
              surface: ColorTheme.mainColor2,
              onSurface: ColorTheme.mainColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != controller.selectedDate) {
      controller.setSelectedDate(picked);
    }
  }

  // Separate Time Picker
  void _showTimePicker(
    BuildContext context,
    NotificationSettingsController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorTheme.secondaryColor,
              onPrimary: ColorTheme.mainColor2,
              surface: ColorTheme.mainColor2,
              onSurface: ColorTheme.mainColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != controller.selectedTime) {
      controller.setSelectedTime(picked);
    }
  }
}
